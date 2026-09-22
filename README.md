# Hyprland dotfiles

A complete, self-contained Arch Linux + Hyprland desktop: window manager, bar,
launcher, notifications, lock screen, terminal, editor and shell — all themed
from a single wallpaper, with one script to install it.

No framework underneath it. Every config here is hand-written and readable, so
forking it and changing one piece doesn't require understanding the other ten.

```
Hyprland · Waybar · Rofi · SwayNC · wlogout · hyprlock · nwg-dock
Kitty · Neovim · tmux · zsh (Oh My Zsh) · Matugen
```

## Highlights

**One wallpaper drives every color.** `hypr/scripts/wallpaper.sh` sets the
wallpaper and runs [Matugen](https://github.com/InioX/matugen), which renders a
Material You palette into Hyprland, Waybar, Rofi, Kitty, GTK 3/4, Qt6, SwayNC,
wlogout, the dock and terminal escape sequences — one command, everything
follows. The accent stays blue and is blended toward the wallpaper hue, so
palettes never clash no matter what image you pick.

**Waybar dropdown panels.** The Wi-Fi, volume and system modules open real Rofi
panels anchored under the bar (`hypr/scripts/wifi-menu.sh`,
`volume-menu.sh`, `lib-dropdown.sh`) — scan and join networks, switch sinks,
pick a power action, without leaving the bar.

**Monitor layout modes.** `SUPER+F1..F5` switch between saved multi-monitor
layouts. Monitors are matched by the EDID product string read from
`/sys/class/drm/*/edid`, not by connector name, so a DisplayLink dock that
renames its outputs on every replug still lands in the right place.

**Gamemode toggle.** `SUPER+ALT+G` strips blur, shadows and animations for
frames, and puts them back on the second press.

**Sensible fallbacks.** Waybar honours a `disabled` flag file, the dock can be
turned off the same way, wallpaper is restored at login without rebuilding the
palette, and scripts degrade quietly when optional hardware isn't there.

## What's inside

| Area | Config | Package |
|---|---|---|
| Compositor | `hypr/` — split into `conf/*.conf` by topic | `hyprland` |
| Lock / idle | `hypr/hyprlock.conf`, `hypr/hypridle.conf` | `hyprlock` `hypridle` |
| Wallpaper | `hypr/hyprpaper.conf`, `waypaper/` | `hyprpaper` `waypaper` |
| Bar | `waybar/config.jsonc` + `style.css` | `waybar` |
| Launcher / menus | `rofi/*.rasi` | `rofi-wayland` |
| Notifications | `hypr/swaync/` (`swaync/` is a symlink to it) | `swaync` |
| Power menu | `wlogout/` | `wlogout` |
| Dock | `nwg-dock-hyprland/` | `nwg-dock-hyprland` |
| Colors | `matugen/` — templates for every app above | `matugen` |
| Terminal | `kitty/` | `kitty` |
| Editor | `nvim/`, `vim/` | `neovim` `vim` |
| Multiplexer | `tmux/` | `tmux` |
| Shell | `.zshrc`, `.zprofile`, `.bashrc` | `zsh` + Oh My Zsh |
| GTK / Qt | `gtk-3.0/` `gtk-4.0/` `qt6ct/` `nwg-look/` `xsettingsd/` | `qt6ct` `nwg-look` `xsettingsd` |
| CLI tools | `git/` `htop/` `lazydocker/` `lazysql/` `fastfetch/` | — |

> `lazysql/config.toml` is tracked with only its `[application]` block — the live
> file also holds database URLs with passwords, so it is never synced back here.

## Requirements

Arch (or an Arch-based distro) with a working Hyprland session, plus:

```bash
sudo pacman -S hyprland hyprlock hypridle hyprpaper waybar rofi-wayland \
  swaync wlogout kitty neovim vim tmux zsh fastfetch htop jq \
  cliphist wl-clipboard brightnessctl playerctl networkmanager blueman \
  polkit-gnome qt6ct nautilus gnome-calculator

# AUR
yay -S matugen-bin waypaper nwg-dock-hyprland nwg-look grimblast
```

Shell setup — [Oh My Zsh](https://ohmyz.sh/) with the `fino-time` theme and four plugins:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions          $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions              $ZSH_CUSTOM/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-history-substring-search $ZSH_CUSTOM/plugins/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-syntax-highlighting      $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```

## Install

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles

./install.sh --dry-run   # print every action, change nothing
./install.sh             # do it
exec zsh                 # reload the shell
```

`install.sh` symlinks `home/` into `$HOME`. Anything already at a destination is
moved to `~/.dotfiles-backup/<timestamp>/` first — nothing is overwritten in
place, and nothing is deleted.

Top-level entries (`.zshrc`, `.gtkrc-2.0`, …) are linked whole. `.config/` is
walked one level deeper and linked per application, so your `~/.config` keeps
every config belonging to apps this repo doesn't manage.

| Flag | Effect |
|---|---|
| `--dry-run` | Print what would happen; touch nothing |
| `--force` | Don't prompt when an existing symlink points elsewhere |

Because the destinations are symlinks, editing a config in `~/.config/...` and
editing it in this repo are the same act — commit from the repo when you're done.

**Taking only part of it:** delete the directories you don't want from `home/`
before running `install.sh`, or link a single one by hand:

```bash
ln -s ~/dotfiles/home/.config/kitty ~/.config/kitty
```

**Reverting:** remove the symlink and move your file back:

```bash
rm ~/.config/waybar && mv ~/.dotfiles-backup/<timestamp>/.config/waybar ~/.config/
```

## Make it yours

Fork-and-go is close to working, but a few things describe *one specific
laptop*. Change these first:

| File | What to change |
|---|---|
| `hypr/conf/monitors.conf` | Your monitor names, resolutions and positions |
| `hypr/scripts/monitor-mode.sh` | The `MAIN_EDID` / `SIDE_EDID` product strings and the five layout functions — or drop the `SUPER+F1..F5` binds entirely |
| `hypr/conf/keyboard.conf` | Keyboard layout and options |
| `waypaper/config.ini` | Wallpaper directory (defaults to `~/wallpaper/`) |
| `hypr/scripts/wallpaper.sh` | `DEFAULT` wallpaper path |
| `.zprofile` | `AQ_NO_ATOMIC` / `AQ_MGPU_NO_EXPLICIT` exist for a DisplayLink dock. Remove them unless you have one |
| `.zshrc` | `OLLAMA_HOST` points at a private LAN address — change or delete |
| `.config/git/config` | `user.name` / `user.email` |
| `waybar/config.jsonc` | The `custom/trackpad-battery` module needs an Apple Magic Trackpad; remove it otherwise |
| `hypr/conf/keybinds.conf` | App launchers assume `kitty`, `brave`, `nautilus`, `gnome-calculator` |

Changing the look is mostly one file each: `waybar/style.css`,
`rofi/config.rasi`, `hypr/conf/{decoration,animation}.conf`. Color *values*
come from Matugen — edit `matugen/templates/*` rather than the generated
`colors.*` files, which are overwritten on the next wallpaper change.

## Keybindings

`SUPER` is the modifier. Press `SUPER+CTRL+K` for the in-session cheatsheet.

**Apps**

| Key | Action |
|---|---|
| `SUPER+RETURN` | Terminal (kitty) |
| `SUPER+B` | Browser |
| `SUPER+E` | File manager |
| `SUPER+D` | App launcher (rofi) |
| `SUPER+V` | Clipboard history |
| `SUPER+CTRL+C` | Calculator |

**Windows**

| Key | Action |
|---|---|
| `SUPER+Q` | Close window |
| `SUPER+F` / `SUPER+M` | Fullscreen / maximize |
| `SUPER+T` | Toggle floating |
| `SUPER+H/J/K/L` | Move focus |
| `SUPER+SHIFT+H/J/K/L` | Resize |
| `SUPER+ALT+H/J/K/L` | Swap windows |
| `SUPER+G` | Toggle group |
| `SUPER + drag` | Move (left button) / resize (right button) |
| `ALT+Tab` | Cycle windows |

**Workspaces**

| Key | Action |
|---|---|
| `SUPER+1..0` | Go to workspace |
| `SUPER+SHIFT+1..0` | Move window to workspace |
| `SUPER+Tab` / `SUPER+SHIFT+Tab` | Next / previous workspace |
| `SUPER+scroll` | Cycle workspaces |
| `SUPER+CTRL+↓` | First empty workspace |

**System**

| Key | Action |
|---|---|
| `SUPER+SHIFT+S` / `SUPER+PRINT` | Screenshot |
| `SUPER+CTRL+L` | Lock |
| `SUPER+CTRL+Q` | Power menu |
| `SUPER+SHIFT+DELETE` | Suspend |
| `SUPER+F1..F5` | Monitor layout A–E |
| `SUPER+CTRL+B` / `SUPER+SHIFT+B` | Toggle / restart waybar |
| `SUPER+CTRL+R` | Reload Hyprland |
| `SUPER+SHIFT+A` | Toggle animations |
| `SUPER+ALT+G` | Gamemode |

Media and brightness keys work as labelled. tmux uses `C-a` as its prefix.

## Theming pipeline

```
wallpaper image
      │
      ▼
hypr/scripts/wallpaper.sh ──► hyprpaper (sets it, caches the path)
      │
      ▼
   matugen  ──reads──►  matugen/templates/*
      │
      ├──► hypr/colors.conf            (+ hyprctl reload)
      ├──► waybar/colors.css
      ├──► rofi/colors.rasi
      ├──► kitty/colors-matugen.conf
      ├──► gtk-3.0 & gtk-4.0/colors.css
      ├──► qt6ct/colors/matugen.conf
      ├──► hypr/swaync/, wlogout/, nwg-dock/colors.css
      └──► ~/.cache/wal/{colors.json,sequences}
```

Apply a new wallpaper — and rebuild everything above — with:

```bash
~/.config/hypr/scripts/wallpaper.sh /path/to/image.jpg
```

## Repo layout

```
.
├── install.sh        # symlink installer with backup and --dry-run
├── .gitignore        # editor state, backups, nested repos
└── home/             # mirrors $HOME one-to-one
    ├── .zshrc .zprofile .bashrc .bash_profile
    ├── .gtkrc-2.0 .Xresources .yarnrc
    └── .config/
        ├── hypr/ waybar/ rofi/ wlogout/ nwg-dock-hyprland/
        │   └── swaync -> hypr/swaync
        ├── matugen/ waypaper/
        ├── gtk-3.0/ gtk-4.0/ qt6ct/ nwg-look/ xsettingsd/
        ├── kitty/ nvim/ vim/ tmux/ fastfetch/
        ├── git/ htop/ lazydocker/ lazysql/
        └── mimeapps.list
```

`~/.gitconfig` and `~/.tmux.conf` live at `~/.config/git/config` and
`~/.config/tmux/tmux.conf` here (XDG layout).
