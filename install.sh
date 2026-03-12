#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "╔══════════════════════════════════════╗"
echo "║        DevOS — Setup Script          ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── 1. Install yay if missing ──────────────────────────────────────────────
if ! command -v yay &>/dev/null; then
    echo "==> Installing yay (AUR helper)..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay-install
    cd /tmp/yay-install && makepkg -si --noconfirm
    cd "$REPO_DIR"
    echo "✅ yay installed"
fi

# ── 2. Install all packages ────────────────────────────────────────────────
echo "==> Installing packages from packages.txt..."
yay -S --needed --noconfirm - < "$REPO_DIR/packages.txt"
echo "✅ Packages installed"

# ── 3. Create config directories ──────────────────────────────────────────
echo "==> Creating config directories..."
mkdir -p ~/.config/hypr
mkdir -p ~/.config/ghostty/shaders

# ── 4. Symlink all dotfiles ────────────────────────────────────────────────
echo "==> Linking dotfiles..."

link() {
    ln -sf "$REPO_DIR/$1" "$HOME/$1"
    echo "   Linked: ~/$1"
}

link .config/hypr/hyprland.conf
link .config/hypr/hyprlock.conf
link .config/ghostty/config

# Link each shader individually
for shader in "$REPO_DIR"/.config/ghostty/shaders/*.glsl; do
    fname=$(basename "$shader")
    ln -sf "$shader" ~/.config/ghostty/shaders/"$fname"
    echo "   Linked: shader/$fname"
done

# ── 5. Enable services ────────────────────────────────────────────────────
echo "==> Enabling system services..."
sudo systemctl enable sddm

# ── 6. Install GRUB + CyberRe theme ───────────────────────────────────────
echo "==> Installing GRUB and CyberRe theme..."
sudo pacman -S --needed --noconfirm grub os-prober
sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
yay -S --noconfirm grub-theme-cyberre

# Set CyberRe as the GRUB theme
sudo sed -i 's|.*GRUB_THEME.*|GRUB_THEME="/usr/share/grub/themes/CyberRe/theme.txt"|' /etc/default/grub
sudo sed -i 's|.*GRUB_TIMEOUT=.*|GRUB_TIMEOUT=10|' /etc/default/grub
sudo sed -i 's|.*GRUB_DISABLE_OS_PROBER.*|GRUB_DISABLE_OS_PROBER=false|' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
echo "✅ GRUB + CyberRe theme installed"

# ── 7. Install SDDM Cyberpunk theme ───────────────────────────────────────
echo "==> Installing SDDM Cyberpunk theme..."
sudo pacman -S --needed --noconfirm qt6-svg qt6-virtualkeyboard qt6-multimedia \
    gst-plugins-good gst-plugins-bad gst-libav

git clone https://github.com/Keyitdev/sddm-astronaut-theme.git /tmp/sddm-astronaut-theme
sudo cp -r /tmp/sddm-astronaut-theme /usr/share/sddm/themes/sddm-astronaut-theme

# Apply cyberpunk sub-theme
sudo cp /tmp/sddm-astronaut-theme/Themes/cyberpunk.conf \
        /usr/share/sddm/themes/sddm-astronaut-theme/theme.conf

# Set SDDM to use it
sudo mkdir -p /etc/sddm.conf.d
echo -e "[Theme]\nCurrent=sddm-astronaut-theme" | sudo tee /etc/sddm.conf.d/theme.conf
echo "✅ SDDM Cyberpunk theme installed"

# ── Done ───────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════╗"
echo "║      ✅ DevOS Setup Complete!        ║"
echo "║        Run: sudo reboot              ║"
echo "╚══════════════════════════════════════╝"
