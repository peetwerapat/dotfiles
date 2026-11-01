#!/bin/bash
#  ____        _   _                    ____                     _
# | __ )  __ _| |_| |_ ___ _ __ _   _  / ___|_   _  __ _ _ __ __| |
# |  _ \ / _` | __| __/ _ \ '__| | | || |  _| | | |/ _` | '__/ _` |
# | |_) | (_| | |_| ||  __/ |  | |_| || |_| | |_| | (_| | | | (_| |
# |____/ \__,_|\__|\__\___|_|   \__, | \____|\__,_|\__,_|_|  \__,_|
#                               |___/
#
# Power off when the battery is nearly empty and not actually gaining charge.
# The EC sometimes keeps reporting the USB-C charger as online after it is
# unplugged, so upower thinks we are on AC and never runs its critical action.
# This ignores the AC flag and trusts the battery's own energy reading instead.

BAT=/sys/class/power_supply/BAT0
THRESHOLD=3   # percent
INTERVAL=30   # seconds between checks
WINDOW=6      # checks; energy must rise over this span to count as charging
GRACE=60      # seconds of warning before power off

history=()

while true; do
    capacity=$(cat "$BAT/capacity" 2>/dev/null || echo 100)
    energy=$(cat "$BAT/energy_now" 2>/dev/null || echo 0)

    history+=("$energy")
    ((${#history[@]} > WINDOW)) && history=("${history[@]:1}")

    if ((capacity <= THRESHOLD && ${#history[@]} == WINDOW && energy <= history[0])); then
        notify-send -u critical "Battery ${capacity}%" "Not charging. Powering off in ${GRACE}s."
        sleep "$GRACE"
        # Abort if the battery started charging during the grace period
        if (($(cat "$BAT/energy_now") <= energy)); then
            systemctl poweroff
        fi
        history=()
    fi

    sleep "$INTERVAL"
done
