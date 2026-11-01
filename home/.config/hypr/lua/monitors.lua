-- Monitor layout.
-- The empty output is the fallback for unplugged displays and remote sessions.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- LG 27GL850 (center, main)
hl.monitor({
    output = "desc:LG Electronics 27GL850 009INRC1C502",
    mode = "2560x1440@59.95",
    position = "0x0",
    scale = 1,
})

-- Laptop panel (right), enable when needed:
-- hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "2560x0", scale = 1 })

-- Samsung S24R35x (left, vertical), enable when connected:
-- hl.monitor({
--     output = "desc:Samsung Electric Company S24R35x H4TMA01205",
--     mode = "1920x1080@60",
--     position = "-1080x0",
--     scale = 1,
--     transform = 1,
-- })
