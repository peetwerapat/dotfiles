-- Global window, layout, cursor, and misc settings.

hl.config({
    animations = {
        enabled = true,
    },

    general = {
        layout = "dwindle",
        gaps_in = 8,
        gaps_out = 14,
        border_size = 2,
        resize_on_border = true,
        allow_tearing = false,
    },

    dwindle = {
        preserve_split = true,
    },

    binds = {
        workspace_back_and_forth = true,
        allow_workspace_cycles = true,
        pass_mouse_when_bound = false,
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        initial_workspace_tracking = 1,
    },

    cursor = {
        no_hardware_cursors = 1,
    },
})
