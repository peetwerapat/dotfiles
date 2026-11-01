-- Window and layer behavior.
hl.window_rule({ match = { class = "^(pavucontrol)$" }, float = true })
hl.window_rule({ match = { class = "^(blueman-manager)$" }, float = true })
hl.window_rule({ match = { class = "^(nm-connection-editor)$" }, float = true })
hl.window_rule({
    match = { class = "^(gnome-calculator|org\\.gnome\\.Calculator)$" },
    float = true,
})

-- Popup terminals (htop / nmtui from waybar).
hl.window_rule({
    match = { class = "^(floating-term)$" },
    float = true,
    size = { 1000, 700 },
    center = true,
})

-- Picture-in-picture.
hl.window_rule({
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin = true,
    size = { 480, 270 },
    move = { "monitor_w-window_w-24", "monitor_h-window_h-24" },
})

-- Keep the screen awake while a window is fullscreen.
hl.window_rule({ match = { class = ".*" }, idle_inhibit = "fullscreen" })
