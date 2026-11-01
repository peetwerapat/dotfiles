-- Keyboard, mouse, touchpad, and gesture settings.
hl.config({
    input = {
        kb_layout = "us,th",
        kb_options = "grp:ctrl_space_toggle",
        numlock_by_default = true,
        follow_mouse = 1,
        sensitivity = 1,
        repeat_rate = 50,
        repeat_delay = 200,

        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            tap_and_drag = true,
            drag_lock = true,
            disable_while_typing = false,
            clickfinger_behavior = true,
            middle_button_emulation = false,
            scroll_factor = 1.2,
        },
    },

    gestures = {
        workspace_swipe_distance = 300,
        workspace_swipe_invert = true,
        workspace_swipe_cancel_ratio = 0.2,
        workspace_swipe_min_speed_to_force = 5,
        workspace_swipe_direction_lock = true,
        workspace_swipe_forever = true,
        workspace_swipe_use_r = true,
        workspace_swipe_create_new = true,
    },
})

-- Silakka54 mouse keys are already accelerated in firmware.
hl.device({
    name = "squalius-cephalus-silakka54-mouse",
    accel_profile = "flat",
    sensitivity = -0.5,
})

-- Apple Magic Trackpad.
hl.device({
    name = "apple-inc.-magic-trackpad",
    enabled = true,
    accel_profile = "adaptive",
    sensitivity = 0.3,
    scroll_factor = 1.0,
    natural_scroll = true,
    tap_to_click = true,
    tap_and_drag = true,
    drag_lock = true,
    clickfinger_behavior = true,
    middle_button_emulation = false,
    disable_while_typing = false,
})

-- Three fingers: switch workspaces, show the window switcher, or notifications.
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({
    fingers = 3,
    direction = "up",
    action = function()
        hl.exec_cmd("pkill -x rofi || rofi -show window -replace -i")
    end,
})
hl.gesture({
    fingers = 3,
    direction = "down",
    action = function()
        hl.exec_cmd("swaync-client -t -sw")
    end,
})

-- Four fingers: launcher, empty workspace, move, and fullscreen.
hl.gesture({
    fingers = 4,
    direction = "pinchin",
    action = function()
        hl.exec_cmd("pkill -x rofi || rofi -show drun -replace -i")
    end,
})
hl.gesture({
    fingers = 4,
    direction = "pinchout",
    action = function()
        hl.dispatch(hl.dsp.focus({ workspace = "empty" }))
    end,
})
hl.gesture({ fingers = 4, direction = "horizontal", action = "move" })
hl.gesture({ fingers = 4, direction = "up", action = "fullscreen" })

-- Optional gestures, kept disabled:
-- hl.gesture({ fingers = 4, direction = "down", action = "close" })
-- hl.gesture({ fingers = 3, direction = "pinchin", action = "float" })
-- hl.gesture({ fingers = 4, direction = "vertical", action = "special", workspace_name = "magic" })
-- hl.gesture({ fingers = 2, direction = "pinch", action = "cursor_zoom", zoom_level = 1, mode = "live" })

-- Built-in Synaptics touchpad.
hl.device({
    name = "ps/2-synaptics-touchpad",
    accel_profile = "flat",
    sensitivity = 1.0,
    scroll_factor = 3.0,
})
