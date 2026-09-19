#!/usr/bin/env bash
#
# install.sh — install these dotfiles by symlinking them into $HOME
#
# Usage:
#   ./install.sh            # real run (anything already there is backed up first)
#   ./install.sh --dry-run  # print what would happen, without touching any file
#   ./install.sh --force    # overwrite foreign symlinks without asking
#
set -euo pipefail

# ---- constants ----
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_ROOT="$DOTFILES_DIR/home"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
FORCE=0
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --force)   FORCE=1 ;;
    -h|--help) sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 1 ;;
  esac
done

# ---- log colors ----
if [ -t 1 ]; then
  C_OK=$'\e[32m'; C_INFO=$'\e[36m'; C_WARN=$'\e[33m'; C_SKIP=$'\e[90m'; C_RST=$'\e[0m'
else
  C_OK=""; C_INFO=""; C_WARN=""; C_SKIP=""; C_RST=""
fi
log()  { printf '%s%s%s\n' "$1" "$2" "$C_RST"; }

run() { # only executes for real when this is not a dry run
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '%s  (dry) %s%s\n' "$C_SKIP" "$*" "$C_RST"
  else
    "$@"
  fi
}

# Link a single entry: $1 = source inside this repo, $2 = destination in $HOME
link_one() {
  local src="$1" dest="$2"

  # already pointing at the right place -> nothing to do
  if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
    log "$C_SKIP" "= already linked: ${dest/#$HOME/~}"
    return
  fi

  # something else is there (real file, directory, or a foreign symlink) -> back it up
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local rel="${dest#$HOME/}"
    local bkp="$BACKUP_DIR/$rel"
    log "$C_WARN" "↩ backing up: ${dest/#$HOME/~}  ->  ${bkp/#$HOME/~}"
    run mkdir -p "$(dirname "$bkp")"
    run mv "$dest" "$bkp"
  fi

  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
  log "$C_OK" "→ linked: ${dest/#$HOME/~}"
}

log "$C_INFO" "Dotfiles: $DOTFILES_DIR"
[ "$DRY_RUN" -eq 1 ] && log "$C_WARN" "*** DRY-RUN: no files will be modified ***"

# ---- walk every entry in home/ ----
# Rule: top-level entries are symlinked whole, except .config / .local which are
# walked one level deeper so we never replace all of ~/.config (other apps live there).
shopt -s dotglob nullglob
for entry in "$SRC_ROOT"/*; do
  name="$(basename "$entry")"
  case "$name" in
    .config|.local)
      for sub in "$entry"/*; do
        link_one "$sub" "$HOME/$name/$(basename "$sub")"
      done
      ;;
    *)
      link_one "$entry" "$HOME/$name"
      ;;
  esac
done
shopt -u dotglob nullglob

echo
log "$C_OK" "Done ✓"
[ -d "$BACKUP_DIR" ] && log "$C_INFO" "Previous files were backed up to: ${BACKUP_DIR/#$HOME/~}"
log "$C_INFO" "Open a new terminal, or run:  exec zsh"
