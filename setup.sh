#!/bin/bash

set -euo pipefail

JAMMARCHY_PATH=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
OMARCHY_SYSTEM_PATH=${OMARCHY_SYSTEM_PATH:-/usr/share/omarchy}
REFRESH_ONLY=0
ROOT_AVAILABLE=0
SUDO_KEEPALIVE_PID=""

usage() {
  cat <<'USAGE'
Usage: setup.sh [--refresh]

Apply Jammarchy customizations to an existing Omarchy Quattro installation.

  --refresh  Reapply the overlay after an Omarchy update without prompting for sudo.
USAGE
}

while (($#)); do
  case $1 in
  --refresh)
    REFRESH_ONLY=1
    shift
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    echo "Unknown option: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
done

if (( EUID == 0 )); then
  echo "Run Jammarchy setup as your normal Omarchy user, not as root." >&2
  exit 1
fi

if ! command -v omarchy >/dev/null || [[ ! -d $OMARCHY_SYSTEM_PATH ]]; then
  echo "Install Omarchy Quattro before running Jammarchy setup." >&2
  exit 1
fi

cleanup() {
  if [[ -n $SUDO_KEEPALIVE_PID ]]; then
    kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    wait "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
  fi
  return 0
}
trap cleanup EXIT INT TERM

if (( REFRESH_ONLY )); then
  if sudo -n -v 2>/dev/null; then
    ROOT_AVAILABLE=1
  fi
else
  echo "Jammarchy needs administrator access once to install packages and system policies."
  sudo -v
  ROOT_AVAILABLE=1

  while sleep 30; do
    sudo -n -v || exit
  done &
  SUDO_KEEPALIVE_PID=$!
fi

as_root() {
  sudo -n "$@"
}

install_user_file() {
  local source=$1
  local destination=$2
  local backup

  mkdir -p "$(dirname -- "$destination")"
  if [[ -e $destination ]] && ! cmp -s "$source" "$destination"; then
    backup="${destination}.pre-jammarchy.$(date +%Y%m%d%H%M%S%N)"
    cp -a "$destination" "$backup"
  fi
  install -m 644 "$source" "$destination"
}

install_system_file() {
  local source=$1
  local destination=$2
  local backup

  as_root install -d -m 755 "$(dirname -- "$destination")"
  if as_root test -e "$destination" && ! as_root cmp -s "$source" "$destination"; then
    backup="${destination}.pre-jammarchy.$(date +%Y%m%d%H%M%S%N)"
    as_root cp -a "$destination" "$backup"
  fi
  as_root install -m 644 "$source" "$destination"
}

install_system_executable() {
  local source=$1
  local destination=$2

  as_root install -D -m 755 "$source" "$destination"
}

install_user_directory() {
  local source=$1
  local destination=$2
  local backup

  mkdir -p "$(dirname -- "$destination")"
  if [[ -d $destination ]] && ! diff -qr "$source" "$destination" >/dev/null; then
    backup="${destination}.pre-jammarchy.$(date +%Y%m%d%H%M%S%N)"
    cp -a "$destination" "$backup"
  fi
  rm -rf "$destination"
  cp -a "$source" "$destination"
}

install_packages() {
  if ! pacman -Q alacritty &>/dev/null; then
    as_root pacman -S --needed --noconfirm alacritty
  fi

  if ! pacman -Q brave-bin &>/dev/null; then
    command -v yay >/dev/null || { echo "Omarchy's yay package is required to install Brave." >&2; exit 1; }
    yay --sudoflags "-n" --sudoloop --answerclean None --answerdiff None --answeredit None -S --needed --noconfirm brave-bin
  fi
}

apply_user_overlay() {
  install_user_file "$JAMMARCHY_PATH/config/hypr/bindings.lua" "$HOME/.config/hypr/bindings.lua"
  install_user_file "$JAMMARCHY_PATH/config/hypr/looknfeel.lua" "$HOME/.config/hypr/looknfeel.lua"
  install_user_file "$JAMMARCHY_PATH/config/brave-flags.conf" "$HOME/.config/brave-flags.conf"
  install_user_file "$JAMMARCHY_PATH/default/xdg-terminal-exec/hyprland-xdg-terminals.list" "$HOME/.config/xdg-terminals.list"
  install_user_file "$JAMMARCHY_PATH/default/nvim/code-runner.lua" "$HOME/.config/nvim/lua/plugins/code-runner.lua"
  install_user_file "$JAMMARCHY_PATH/etc/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
  install_user_file "$JAMMARCHY_PATH/config/omarchy/extensions/omarchy-menu.jsonc" "$HOME/.config/omarchy/extensions/omarchy-menu.jsonc"
  install_user_file "$JAMMARCHY_PATH/logo.txt" "$HOME/.config/omarchy/branding/about.txt"
  install_user_file "$JAMMARCHY_PATH/logo.txt" "$HOME/.config/omarchy/branding/screensaver.txt"
  install_user_file "$JAMMARCHY_PATH/post-install/post-update.sh" "$HOME/.config/omarchy/hooks/post-update.d/jammarchy"
  install_user_directory "$JAMMARCHY_PATH/themes/aetheria" "$HOME/.config/omarchy/themes/aetheria"
}

apply_system_overlay() {
  if (( ! ROOT_AVAILABLE )); then
    return 0
  fi

  if (( ! REFRESH_ONLY )); then
    as_root systemctl enable --now NetworkManager.service
  fi

  install_system_file "$JAMMARCHY_PATH/etc/brave/policies/managed/extensions.json" "/usr/local/share/jammarchy/extensions.json"
  install_system_file "$JAMMARCHY_PATH/default/wayland-sessions/omarchy.desktop" "/usr/local/share/jammarchy/session.desktop"
  install_system_file "$JAMMARCHY_PATH/default/sddm/omarchy/metadata.desktop" "/usr/local/share/jammarchy/sddm-metadata.desktop"
  install_system_file "$JAMMARCHY_PATH/default/plymouth/omarchy.plymouth" "/usr/local/share/jammarchy/omarchy.plymouth"
  install_system_file "$JAMMARCHY_PATH/post-install/zz-jammarchy.conf" "/usr/local/share/jammarchy/zz-jammarchy.conf"
  install_system_file "$JAMMARCHY_PATH/post-install/jammarchy-overlay.hook" "/etc/pacman.d/hooks/jammarchy-overlay.hook"
  install_system_executable "$JAMMARCHY_PATH/post-install/refresh-system.sh" "/usr/local/bin/jammarchy-refresh-system"
  as_root /usr/local/bin/jammarchy-refresh-system
  as_root chown "$USER:$(id -gn)" /etc/brave/policies/managed/color.json
  as_root chmod 644 /etc/brave/policies/managed/color.json
}

if (( ! REFRESH_ONLY )); then
  install_packages
fi

apply_user_overlay
apply_system_overlay

if (( ! REFRESH_ONLY )); then
  omarchy-refresh-applications
  omarchy-default-browser brave
  omarchy-theme-set "Aetheria"
  nvim --headless "+Lazy! sync" "+qa!"
fi

hyprctl reload &>/dev/null || true
omarchy-shell -q shell reloadConfig &>/dev/null || true

echo "Jammarchy customization complete. Official Omarchy updates remain enabled."
