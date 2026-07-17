# Set links for Nautilus action icons
sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-previous-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-previous-symbolic.svg
sudo ln -snf /usr/share/icons/Adwaita/symbolic/actions/go-next-symbolic.svg /usr/share/icons/Yaru/scalable/actions/go-next-symbolic.svg

# Setup user theme folder
mkdir -p ~/.config/omarchy/themes

# Brave policy directory for theme and extensions
sudo mkdir -p /etc/brave/policies/managed
sudo chmod a+rw /etc/brave/policies/managed

# Force-install extensions via Brave managed policy
cat <<'POLICY' | sudo tee /etc/brave/policies/managed/extensions.json >/dev/null
{
  "ExtensionInstallForcelist": [
    "aeblfdkhhhdcdjpifhhbdiojplfjncoa;https://clients2.google.com/service/update2/crx",
    "cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx"
  ]
}
POLICY

# Set initial theme
omarchy-theme-install https://github.com/JJDizz1L/aetheria.git
omarchy-theme-set "aetheria"

# Set specific app links for current theme
mkdir -p ~/.config/btop/themes
ln -snf ~/.config/omarchy/current/theme/btop.theme ~/.config/btop/themes/current.theme

mkdir -p ~/.config/mako
ln -snf ~/.config/omarchy/current/theme/mako.ini ~/.config/mako/config

# Set Brave as default browser
omarchy-default-browser brave
