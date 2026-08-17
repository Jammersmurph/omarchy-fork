# Set links for Nautilus action icons
sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-previous-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-previous-symbolic.svg
sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-next-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-next-symbolic.svg

# Setup user theme folder
mkdir -p ~/.config/omarchy/themes

# Install Brave browser (AUR only, needs PTY for yay first-run init)
# All install scripts run with stdin disconnected, so yay's internal sudo prompts
# get EOF and fail. Grant NOPASSWD for pacman temporarily, then remove it.
if ! command -v brave-browser &>/dev/null; then
  echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/pacman" | sudo tee /etc/sudoers.d/yay-pacman >/dev/null
  sudo chmod 440 /etc/sudoers.d/yay-pacman
  script -qec "yay -Sy --needed --noconfirm brave-bin" /dev/null 2>/dev/null || \
    echo "Warning: Brave install failed, install manually with: yay -S brave-bin"
  sudo rm -f /etc/sudoers.d/yay-pacman
fi

# Setup Brave policies and extensions if installed
if command -v brave-browser &>/dev/null; then
  sudo mkdir -p /etc/brave/policies/managed
  sudo chmod a+rw /etc/brave/policies/managed

  cat <<'POLICY' | sudo tee /etc/brave/policies/managed/extensions.json >/dev/null
{
  "ExtensionInstallForcelist": [
    "aeblfdkhhhdcdjpifhhbdiojplfjncoa;https://clients2.google.com/service/update2/crx",
    "cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx"
  ]
}
POLICY

  omarchy-default-browser brave || true
fi

# Set initial theme
omarchy-theme-install https://github.com/JJDizz1L/aetheria.git
omarchy-theme-set "aetheria"

# Set default wallpaper
WALLPAPER_SRC="$OMARCHY_PATH/themes/aetheria/backgrounds/titanfall-2-wp1.jpg"
WALLPAPER_DST="$HOME/.config/omarchy/current/theme/backgrounds/titanfall-2-wp1.jpg"
if [[ -f "$WALLPAPER_SRC" ]]; then
  mkdir -p "$HOME/.config/omarchy/current/theme/backgrounds"
  cp "$WALLPAPER_SRC" "$WALLPAPER_DST"
  omarchy-theme-bg-set "$WALLPAPER_DST"
fi

# Set specific app links for current theme
mkdir -p ~/.config/btop/themes
ln -snf ~/.config/omarchy/current/theme/btop.theme ~/.config/btop/themes/current.theme

mkdir -p ~/.config/mako
ln -snf ~/.config/omarchy/current/theme/mako.ini ~/.config/mako/config
