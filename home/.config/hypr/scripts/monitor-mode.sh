#!/usr/bin/env bash

set -u

MODE="${1:-}"

# =====================================================
# Monitors
#
# External monitors are found by the EDID the kernel reads
# (/sys/class/drm/*/edid), not by connector name:
#  - DisplayLink (Dell D6000 / evdi) names change on every
#    replug (DVI-I-1, DVI-I-2, ...)
#  - after a hotplug Hyprland can keep a stale description
#    for a connector, so desc: matching is not reliable either
#
# Mode B's top monitor is the exception: it is whatever is
# plugged into the laptop HDMI port.
# =====================================================

LAPTOP="eDP-1"
MAIN_EDID="27GL850"   # LG 27GL850
SIDE_EDID="S24R35x"   # Samsung S24R35x
TOP="HDMI-A-2"        # mode B top

find_connector() {
    local product="$1"
    local c

    for c in /sys/class/drm/card*-*; do
        [ "$(cat "$c/status" 2>/dev/null)" = "connected" ] || continue

        if grep -aq "$product" "$c/edid" 2>/dev/null; then
            basename "$c" | sed 's/^card[0-9]*-//'
            return
        fi
    done
}

# Best mode a monitor advertises as "<width> <height> <refresh>":
# most pixels, and among those the highest refresh rate.
# DisplayLink (DVI-I-*) is capped at 60Hz (flicker above that).
# Prints nothing when the monitor is not connected.
best_mode() {
    local max_r=1000

    case "$1" in
        DVI-I-*) max_r=61 ;;
    esac

    hyprctl monitors all -j | jq -r --arg name "$1" --argjson max "$max_r" '
        [ .[] | select(.name == $name) | .availableModes[]
          | capture("^(?<w>[0-9]+)x(?<h>[0-9]+)@(?<r>[0-9.]+)")
          | { w: (.w | tonumber), h: (.h | tonumber), r: (.r | tonumber) }
          | select(.r <= $max) ]
        | sort_by(.w * .h, .r)
        | last
        | if . then "\(.w) \(.h) \(.r)" else empty end
    '
}

# Every monitor Hyprland knows except the laptop panel,
# enabled or not, in Hyprland's order.
list_externals() {
    hyprctl monitors all | awk -v laptop="$LAPTOP" \
        '/^Monitor / && $2 != laptop {print $2}'
}

MAIN=""
SIDE=""

# Only modes A-D call this. Mode E never scans connectors / EDID.
detect_monitors() {
    MAIN="$(find_connector "$MAIN_EDID")"
    SIDE="$(find_connector "$SIDE_EDID")"

    case "$MAIN" in
        DVI-I-*) MAIN_FAST_RES="1920x1080@60" ;;
        *)       MAIN_FAST_RES="1920x1080@120" ;;
    esac
}

# =====================================================
# Resolutions
#
# DisplayLink cannot keep up above 60Hz (flicker), so
# anything on DVI-I-* stays at 60Hz.
# =====================================================

LAPTOP_RES="1920x1080@60"
SIDE_RES="1920x1080@60"

MAIN_NATIVE_RES="2560x1440@59.95"
MAIN_FAST_RES="1920x1080@120"

SCALE="1"


# =====================================================
# Helpers
#
# All monitor rules of a mode are sent in one hyprctl
# --batch, and monitors that stay on are never disabled
# first: every extra modeset on DisplayLink is a visible
# freeze/flicker.
# =====================================================

BATCH=()
WORKSPACE_MAP=()

set_monitor() {
    local name="$1"
    local config="$2"

    [ -n "$name" ] || return 0

    echo "[monitor] $name -> $config"

    BATCH+=("keyword monitor $name,$config")
}

set_workspace_monitor() {
    local workspace="$1"
    local monitor="$2"
    local default_workspace="$3"

    [ -n "$monitor" ] || return 0

    echo "[workspace] $workspace -> $monitor"

    BATCH+=("keyword workspace ${workspace}, monitor:${monitor}, default:${default_workspace}, persistent:false")
    WORKSPACE_MAP+=("$workspace $monitor")
}

set_workspace_group() {
    local monitor="$1"
    local default_workspace="$2"
    local workspace default

    shift 2

    for workspace in "$@"; do
        default=false
        [ "$workspace" = "$default_workspace" ] && default=true
        set_workspace_monitor "$workspace" "$monitor" "$default"
    done
}

apply_workspace_map() {
    local workspaces mapping workspace monitor

    workspaces="$(hyprctl workspaces -j)"

    for mapping in "${WORKSPACE_MAP[@]}"; do
        read -r workspace monitor <<<"$mapping"

        if jq -e --argjson id "$workspace" 'any(.[]; .id == $id)' <<<"$workspaces" >/dev/null 2>&1; then
            hyprctl dispatch moveworkspacetomonitor "$workspace $monitor" >/dev/null
        fi
    done
}

disable_monitor() {
    local name="$1"

    [ -n "$name" ] || return 0

    echo "[monitor] $name -> disabled"

    BATCH+=("keyword monitor $name,disable")
}

apply_layout() {
    local focus="$1"
    local cmds

    cmds="$(printf '%s ; ' "${BATCH[@]}")"
    hyprctl --batch "$cmds" >/dev/null

    [ -n "$focus" ] && hyprctl dispatch focusmonitor "$focus" >/dev/null
}

notify_mode() {
    local mode="$1"
    local description="$2"

    if command -v notify-send >/dev/null 2>&1; then
        notify-send \
            -a "Hyprland" \
            -t 1500 \
            "Monitor Mode $mode" \
            "$description"
    fi
}

# Rules that mode E overrides with "disable" so hotplugged
# monitors stay off. Modes A-D put them back to the
# monitors.conf defaults before adding their own rules
# (later rules win over earlier ones).
MAIN_DESC="desc:LG Electronics 27GL850 009INRC1C502"
SIDE_DESC="desc:Samsung Electric Company S24R35x H4TMA01205"

restore_default_rules() {
    local name

    BATCH+=("keyword monitor ,preferred,auto,1")

    # Mode E also disables every other monitor by connector
    # name (e.g. a USB-C DP-1 monitor). Those named rules win
    # over the fallback, so replace them with the fallback
    # config to turn such monitors back on.
    for name in $(hyprctl monitors all | awk '/^Monitor /{print $2}'); do
        case "$name" in
            "$LAPTOP"|"$MAIN"|"$SIDE") continue ;;
        esac
        BATCH+=("keyword monitor ${name},preferred,auto,${SCALE}")
    done

    BATCH+=("keyword monitor ${MAIN_DESC},${MAIN_NATIVE_RES},0x0,${SCALE}")
    BATCH+=("keyword monitor ${SIDE_DESC},preferred,auto,${SCALE}")
}

header() {
    echo
    echo "========================================"
    echo "MODE $1  (LG=${MAIN:-none}, Samsung=${SIDE:-none})"
    echo "========================================"
}

# detect + reset rules, shared by modes A-D
begin_mode() {
    detect_monitors
    header "$1"
    restore_default_rules
}


# =====================================================
# MODE A
#
# Samsung = LEFT + VERTICAL
# LG      = MAIN / 2560x1440 @ 59.95Hz
# eDP-1   = RIGHT
#
# ┌──────┐ ┌──────────────────────────┐ ┌────────────────┐
# │      │ │                          │ │                │
# │ S24  │ │        LG 27GL850        │ │     eDP-1      │
# │  ↕   │ │     2560x1440 @ 60       │ │    1920x1080   │
# │      │ │          MAIN            │ │                │
# └──────┘ └──────────────────────────┘ └────────────────┘
#
# Samsung = -1080x0
# LG      = 0x0
# eDP     = 2560x0
# Workspaces: LG = 1,8,9,10 • Samsung = 2,3,4 • eDP-1 = 5,6,7
# =====================================================

mode_a() {
    local lg_monitor side_monitor
    local lg_default=1
    local side_default=2

    begin_mode "A"

    lg_monitor="$MAIN"
    side_monitor="$SIDE"
    [ -n "$lg_monitor" ] || { lg_monitor="$LAPTOP"; lg_default=""; }
    [ -n "$side_monitor" ] || { side_monitor="$LAPTOP"; side_default=""; }

    set_monitor "$LAPTOP" "${LAPTOP_RES},2560x0,${SCALE}"
    set_monitor "$MAIN"   "${MAIN_NATIVE_RES},0x0,${SCALE}"
    # transform 1 = 90° rotation, 1920x1080 becomes logical 1080x1920
    set_monitor "$SIDE"   "${SIDE_RES},-1080x0,${SCALE},transform,1"

    set_workspace_group "$lg_monitor" "$lg_default" 1 8 9 10
    set_workspace_group "$side_monitor" "$side_default" 2 3 4
    set_workspace_group "$LAPTOP" 5 5 6 7

    apply_layout "$MAIN"
    apply_workspace_map
    [ -n "$MAIN" ] && hyprctl dispatch focusmonitor "$MAIN" >/dev/null

    notify_mode \
        "A" \
        "LG 1440p main • Samsung left vertical • eDP right"
}


# =====================================================
# MODE B
#
# HDMI-A-2 = TOP, at its best mode
# eDP-1    = MAIN / bottom, focused
# every other external monitor = OFF
#
# ┌────────────────┐
# │    HDMI-A-2    │   0x-<height>
# └────────────────┘
# ┌────────────────┐
# │     eDP-1      │   0x0   MAIN
# │   1920x1080    │
# └────────────────┘
# =====================================================

mode_b() {

    local w h r name
    local top_res="preferred"
    local top_h=1080
    local top_workspace_monitor="$TOP"
    local top_default=6

    begin_mode "B"

    read -r w h r <<<"$(best_mode "$TOP")"

    if [ -n "${w:-}" ]; then
        top_res="${w}x${h}@${r}"
        top_h="$h"
    else
        top_workspace_monitor="$LAPTOP"
        top_default=""
    fi

    for name in $(list_externals); do
        [ "$name" = "$TOP" ] || disable_monitor "$name"
    done
    set_monitor "$LAPTOP" "${LAPTOP_RES},0x0,${SCALE}"
    set_monitor "$TOP"    "${top_res},0x-${top_h},${SCALE}"

    set_workspace_group "$LAPTOP" 1 1 2 3 4 5
    set_workspace_group "$top_workspace_monitor" "$top_default" 6 7 8 9 10

    apply_layout "$LAPTOP"
    apply_workspace_map
    hyprctl dispatch focusmonitor "$LAPTOP" >/dev/null

    notify_mode \
        "B" \
        "eDP main • ${TOP} top"
}


# =====================================================
# MODES C / D
#
# eDP-1 = MAIN + one external monitor, whichever it is
# (Samsung, Arzopa over USB-C, anything). The first one
# Hyprland lists is used at its best mode; any other
# external monitor is turned OFF.
#
# C: external on TOP      D: external on the RIGHT
#
# ┌────────────────┐
# │    external    │      ┌────────────┐ ┌──────────┐
# └────────────────┘      │   eDP-1    │ │ external │
# ┌────────────────┐      │    MAIN    │ │          │
# │  eDP-1  MAIN   │      └────────────┘ └──────────┘
# └────────────────┘
# =====================================================

mode_single_external() {

    local mode="$1"
    local side="$2"
    local ext="" name w h r
    local ext_res="preferred"
    local ext_h=1080
    local pos
    local ext_workspace_monitor
    local ext_default=6

    begin_mode "$mode"

    for name in $(list_externals); do
        if [ -z "$ext" ]; then
            ext="$name"
        else
            disable_monitor "$name"
        fi
    done

    read -r w h r <<<"$(best_mode "$ext")"

    if [ -n "${w:-}" ]; then
        ext_res="${w}x${h}@${r}"
        ext_h="$h"
    fi

    case "$side" in
        top)   pos="0x-${ext_h}" ;;
        right) pos="1920x0" ;;
    esac

    set_monitor "$LAPTOP" "${LAPTOP_RES},0x0,${SCALE}"
    set_monitor "$ext"    "${ext_res},${pos},${SCALE}"

    ext_workspace_monitor="${ext:-$LAPTOP}"
    [ -n "$ext" ] || ext_default=""
    set_workspace_group "$LAPTOP" 1 1 2 3 4 5
    set_workspace_group "$ext_workspace_monitor" "$ext_default" 6 7 8 9 10

    apply_layout "$LAPTOP"
    apply_workspace_map
    hyprctl dispatch focusmonitor "$LAPTOP" >/dev/null

    notify_mode \
        "$mode" \
        "eDP main • ${ext:-no external} ${side}"
}

mode_c() {
    mode_single_external "C" "top"
}

mode_d() {
    mode_single_external "D" "right"
}


# =====================================================
# MODE E
#
# eDP-1 = ONLY
# every other monitor = OFF
#
# No detection at all: no EDID / sysfs scan. Monitors are
# disabled by the names Hyprland already knows, and the
# fallback + desc: rules are set to "disable" so anything
# hotplugged afterwards is not auto-enabled either.
# Switch to A-D (or reload Hyprland) to undo.
#
# ┌────────────────┐
# │     eDP-1      │
# │   1920x1080    │
# └────────────────┘
# =====================================================

mode_e() {

    local name

    echo
    echo "========================================"
    echo "MODE E  (eDP-1 only)"
    echo "========================================"

    BATCH+=("keyword monitor ,disable")
    BATCH+=("keyword monitor ${MAIN_DESC},disable")
    BATCH+=("keyword monitor ${SIDE_DESC},disable")

    for name in $(hyprctl monitors all | awk '/^Monitor /{print $2}'); do
        [ "$name" = "$LAPTOP" ] || disable_monitor "$name"
    done

    # added last so it wins over the rules above
    set_monitor "$LAPTOP" "${LAPTOP_RES},0x0,${SCALE}"
    set_workspace_group "$LAPTOP" 1 1 2 3 4 5 6 7 8 9 10

    apply_layout "$LAPTOP"
    apply_workspace_map
    hyprctl dispatch focusmonitor "$LAPTOP" >/dev/null

    notify_mode \
        "E" \
        "eDP only • external monitors off"
}


# =====================================================
# Main
# =====================================================

case "${MODE^^}" in

    A)
        mode_a
        ;;

    B)
        mode_b
        ;;

    C)
        mode_c
        ;;

    D)
        mode_d
        ;;

    E)
        mode_e
        ;;

    *)
        echo
        echo "Usage:"
        echo "  $0 A"
        echo "  $0 B"
        echo "  $0 C"
        echo "  $0 D"
        echo "  $0 E"
        echo
        exit 1
        ;;

esac
