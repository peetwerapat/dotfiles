-- Animations, borders, decoration, and translucent layer rules.
local palette = require("lua.colors")

local accent = palette.accent or "rgba(adc6ffff)"
local accent_container = palette.accent_container or "rgba(2b4678ff)"
local surface_container_high = palette.surface_container_high or "rgba(282a2fff)"

hl.config({
    general = {
        col = {
            active_border = {
                colors = { accent, accent_container },
                angle = 45,
            },
            inactive_border = surface_container_high,
        },
    },

    decoration = {
        rounding = 12,
        rounding_power = 3.0,

        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            new_optimizations = true,
            noise = 0.012,
            vibrancy = 0.20,
            vibrancy_darkness = 0.05,
            brightness = 1.0,
            contrast = 1.05,
        },

        shadow = {
            enabled = true,
            range = 24,
            render_power = 3,
            offset = { 0, 6 },
            color = "rgba(05080fbb)",
            color_inactive = "rgba(05080f66)",
        },

        active_opacity = 1.0,
        inactive_opacity = 1.0,
        dim_inactive = true,
        dim_strength = 0.08,
    },
})

hl.curve("smooth", {
    type = "bezier",
    points = { { 0.25, 1.0 }, { 0.3, 1.0 } },
})

hl.curve("overshoot", {
    type = "bezier",
    points = { { 0.2, 1.2 }, { 0.3, 1.0 } },
})

hl.curve("linear", {
    type = "bezier",
    points = { { 0.0, 0.0 }, { 1.0, 1.0 } },
})

hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "overshoot", style = "popin 90%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4, bezier = "overshoot", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "smooth", style = "popin 92%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "border", enabled = true, speed = 8, bezier = "smooth" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 60, bezier = "linear", style = "once" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "smooth" })
hl.animation({ leaf = "layers", enabled = true, speed = 4, bezier = "smooth", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "smooth", style = "slidefade 20%" })

for _, namespace in ipairs({
    "waybar",
    "swaync-control-center",
    "swaync-notification-window",
    "rofi",
}) do
    hl.layer_rule({
        match = { namespace = "^(" .. namespace .. ")$" },
        blur = true,
        ignore_alpha = 0.2,
    })
end
