-- Key bindings.
local main_mod = "SUPER"
local scripts = (os.getenv("HOME") or "") .. "/.config/hypr/scripts"

local function bind_exec(key, command, options)
    hl.bind(key, hl.dsp.exec_cmd(command), options)
end

-- Applications.
bind_exec(main_mod .. " + Return", "kitty")
bind_exec(main_mod .. " + B", "brave")
bind_exec(main_mod .. " + E", "nautilus --new-window")
bind_exec(main_mod .. " + CTRL + C", "gnome-calculator")

-- Windows.
hl.bind(main_mod .. " + Q", hl.dsp.window.close())
hl.bind(main_mod .. " + SHIFT + Q", hl.dsp.window.kill())
hl.bind(main_mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(main_mod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(main_mod .. " + T", hl.dsp.window.float())

local all_float_rules = {}
local all_float_enabled = {}
hl.bind(main_mod .. " + SHIFT + T", function()
    local workspace = hl.get_active_workspace()
    if workspace == nil then
        return
    end

    local enable = not all_float_enabled[workspace.id]
    all_float_enabled[workspace.id] = enable

    local rule = all_float_rules[workspace.id]
    if rule == nil then
        rule = hl.window_rule({
            name = "toggle-all-float-" .. workspace.id,
            match = { workspace = workspace.id },
            float = true,
            enabled = enable,
        })
        all_float_rules[workspace.id] = rule
    else
        rule:set_enabled(enable)
    end

    for _, window in ipairs(hl.get_workspace_windows(workspace.id)) do
        hl.dispatch(hl.dsp.window.float({
            window = window,
            action = enable and "set" or "unset",
        }))
    end
end)

hl.bind(main_mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(main_mod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(main_mod .. " + J", hl.dsp.focus({ direction = "up" }))
hl.bind(main_mod .. " + K", hl.dsp.focus({ direction = "down" }))

hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(main_mod .. " + SHIFT + L", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))
hl.bind(main_mod .. " + SHIFT + H", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
hl.bind(main_mod .. " + SHIFT + K", hl.dsp.window.resize({ x = 0, y = 100, relative = true }))
hl.bind(main_mod .. " + SHIFT + J", hl.dsp.window.resize({ x = 0, y = -100, relative = true }))

hl.bind(main_mod .. " + G", hl.dsp.group.toggle())
hl.bind(main_mod .. " + ALT + H", hl.dsp.window.swap({ direction = "left" }))
hl.bind(main_mod .. " + ALT + L", hl.dsp.window.swap({ direction = "right" }))
hl.bind(main_mod .. " + ALT + J", hl.dsp.window.swap({ direction = "up" }))
hl.bind(main_mod .. " + ALT + K", hl.dsp.window.swap({ direction = "down" }))

-- ALT+Tab cycles windows and raises the selected one, including while held.
hl.bind("ALT + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
end, { repeating = true })

-- Actions.
bind_exec(main_mod .. " + CTRL + R", "hyprctl reload")
bind_exec(main_mod .. " + SHIFT + A", scripts .. "/toggle-animations.sh")
bind_exec(main_mod .. " + Print", scripts .. "/screenshot.sh")
bind_exec(main_mod .. " + SHIFT + S", scripts .. "/screenshot.sh")
bind_exec(main_mod .. " + CTRL + Q", scripts .. "/wlogout.sh")
bind_exec(main_mod .. " + D", "pkill rofi || rofi -show drun -replace -i")
bind_exec(main_mod .. " + CTRL + K", scripts .. "/keybindings.sh")
bind_exec(main_mod .. " + SHIFT + B", (os.getenv("HOME") or "") .. "/.config/waybar/launch.sh")
bind_exec(main_mod .. " + CTRL + B", (os.getenv("HOME") or "") .. "/.config/waybar/toggle.sh")
bind_exec(main_mod .. " + SHIFT + R", scripts .. "/loadconfig.sh")
bind_exec(main_mod .. " + V", scripts .. "/cliphist.sh")
bind_exec(main_mod .. " + ALT + G", scripts .. "/gamemode.sh")
bind_exec(main_mod .. " + CTRL + L", scripts .. "/power.sh lock")
bind_exec(main_mod .. " + SHIFT + Delete", scripts .. "/power.sh suspend")

-- Workspaces.
for i = 1, 9 do
    local key = tostring(i)
    hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(main_mod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(main_mod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

hl.bind(main_mod .. " + Tab", hl.dsp.focus({ workspace = "m+1" }))
hl.bind(main_mod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(main_mod .. " + CTRL + Down", hl.dsp.focus({ workspace = "empty" }))

-- Function and media keys.
bind_exec("XF86MonBrightnessUp", "brightnessctl -q s +10%")
bind_exec("XF86MonBrightnessDown", "brightnessctl -q s 10%-")
bind_exec("XF86AudioRaiseVolume", "pactl set-sink-mute @DEFAULT_SINK@ 0 && pactl set-sink-volume @DEFAULT_SINK@ +5%")
bind_exec("XF86AudioLowerVolume", "pactl set-sink-mute @DEFAULT_SINK@ 0 && pactl set-sink-volume @DEFAULT_SINK@ -5%")
bind_exec("XF86AudioMute", "pactl set-sink-mute @DEFAULT_SINK@ toggle")
bind_exec("XF86AudioPlay", "playerctl play-pause")
bind_exec("XF86AudioPause", "playerctl pause")
bind_exec("XF86AudioNext", "playerctl next")
bind_exec("XF86AudioPrev", "playerctl previous")
bind_exec("XF86AudioMicMute", "pactl set-source-mute @DEFAULT_SOURCE@ toggle")
bind_exec("XF86Calculator", "gnome-calculator")
bind_exec("XF86ScreenSaver", "hyprlock")
bind_exec("code:238", "brightnessctl -d smc::kbd_backlight s +10")
bind_exec("code:237", "brightnessctl -d smc::kbd_backlight s 10-")

-- Monitor modes.
for i = 1, 5 do
    bind_exec(main_mod .. " + F" .. i, scripts .. "/monitor-mode.sh " .. string.char(64 + i))
end
