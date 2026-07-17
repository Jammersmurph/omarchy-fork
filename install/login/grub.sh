# Configure mkinitcpio for boot
sudo tee /etc/mkinitcpio.conf.d/omarchy_hooks.conf <<EOF >/dev/null
HOOKS=(base udev plymouth keyboard autodetect microcode modconf kms keymap consolefont block encrypt filesystems fsck)
EOF
sudo tee /etc/mkinitcpio.conf.d/thunderbolt_module.conf <<EOF >/dev/null
MODULES+=(thunderbolt)
EOF

# Install LiquidGlass Dark GRUB theme
sudo mkdir -p /boot/grub/themes/LiquidGlass
sudo cp -r "$OMARCHY_PATH/default/grub/themes/LiquidGlass(Dark)"/* /boot/grub/themes/LiquidGlass/

# Configure GRUB defaults
sudo tee /etc/default/grub >/dev/null <<'GRUBEOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Arch"
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
GRUB_CMDLINE_LINUX=""
GRUB_PRELOAD_MODULES="part_gpt part_msdos"
GRUB_TIMEOUT_STYLE=menu
GRUB_TERMINAL_INPUT=console
GRUB_GFXMODE=1920x1080
GRUB_GFXPAYLOAD_LINUX=keep
GRUB_DISABLE_RECOVERY=true
GRUB_THEME="/boot/grub/themes/LiquidGlass/theme.txt"
GRUB_DISABLE_SUBMENU=y
GRUBEOF

# Append any drop-in kernel cmdline configs (from hardware fix scripts, etc.)
for dropin in /etc/grub-entry-tool.d/*.conf; do
  [ -f "$dropin" ] && cat "$dropin" | sudo tee -a /etc/default/grub >/dev/null
done

# Detect boot mode and install GRUB
[[ -d /sys/firmware/efi ]] && EFI=true

if [[ -n $EFI ]]; then
  sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
else
  sudo grub-install --target=i386-pc "$(lsblk -no PKNAME "$(findmnt -n -o SOURCE /)")"
fi

# Generate GRUB config
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo "Re-enabling mkinitcpio hooks..."

# Restore the specific mkinitcpio pacman hooks
if [[ -f /usr/share/libalpm/hooks/90-mkinitcpio-install.hook.disabled ]]; then
  sudo mv /usr/share/libalpm/hooks/90-mkinitcpio-install.hook.disabled /usr/share/libalpm/hooks/90-mkinitcpio-install.hook
fi

if [[ -f /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook.disabled ]]; then
  sudo mv /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook.disabled /usr/share/libalpm/hooks/60-mkinitcpio-remove.hook
fi

echo "mkinitcpio hooks re-enabled"

# Remove any archinstall-created Limine EFI entries
if [[ -n $EFI ]] && efibootmgr &>/dev/null; then
  while IFS= read -r bootnum; do
    sudo efibootmgr -b "$bootnum" -B >/dev/null 2>&1
  done < <(efibootmgr | grep -E "^Boot[0-9]{4}\*? Arch Linux Limine" | sed 's/^Boot\([0-9]\{4\}\).*/\1/')
fi
