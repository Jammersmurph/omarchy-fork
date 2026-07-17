# Set links for Nautilus action icons
sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-previous-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-previous-symbolic.svg
sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-next-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-next-symbolic.svg

# Setup user theme folder
mkdir -p ~/.config/omarchy/themes

# Install Brave browser (needs PTY for yay/AUR first-run init)
if ! command -v brave-browser &>/dev/null; then
  curl -fsS https://dl.brave.com/install.sh -o /tmp/brave-install.sh
  script -qec "sudo bash /tmp/brave-install.sh" /dev/null 2>/dev/null || \
    echo "Warning: Brave install failed, install manually with: yay -S brave-bin"
  rm -f /tmp/brave-install.sh
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
