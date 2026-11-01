-- Read the Matugen palette shared with hyprlock from colors.conf.
local home = os.getenv("HOME") or ""
local config_home = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local path = config_home .. "/hypr/colors.conf"
local colors = {}
local file = io.open(path, "r")

if file then
    for line in file:lines() do
        local name, value = line:match("^%s*%$([%w_]+)%s*=%s*(.-)%s*$")
        if name and value then
            colors[name] = value
        end
    end
    file:close()
end

return colors
