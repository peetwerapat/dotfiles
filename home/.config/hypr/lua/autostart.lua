-- Start session services once per Hyprland launch.
local home = os.getenv("HOME") or ""
local hypr = (os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")) .. "/hypr"

hl.on("hyprland.start", function()
    -- Set a fallback cursor theme; gtk.sh applies the configured theme after this.
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 24")
    hl.exec_cmd(hypr .. "/scripts/xdg.sh")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd(hypr .. "/scripts/wallpaper-restore.sh")
    hl.exec_cmd("swaync")
    hl.exec_cmd(hypr .. "/scripts/gtk.sh")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd(hypr .. "/scripts/battery-guard.sh")
    hl.exec_cmd(hypr .. "/scripts/cleanup.sh")
    hl.exec_cmd(home .. "/.config/nwg-dock-hyprland/launch.sh")
end)
