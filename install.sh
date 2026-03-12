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

# ── 6. Set up GRUB theme hint ─────────────────────────────────────────────
echo ""
echo "══════════════════════════════════════════"
echo "  ✅ DevOS setup complete!"
echo ""
echo "  Manual steps remaining:"
echo "  1. Install CyberRe GRUB theme:"
echo "     yay -S grub-theme-cyberre"
echo "     sudo sed -i 's|.*GRUB_THEME.*|GRUB_THEME=\"/usr/share/grub/themes/CyberRe/theme.txt\"|' /etc/default/grub"
echo "     sudo grub-mkconfig -o /boot/grub/grub.cfg"
echo ""
echo "  2. Install SDDM Cyberpunk theme:"
echo "     git clone https://github.com/Keyitdev/sddm-astronaut-theme.git /tmp/sddm-theme"
echo "     cd /tmp/sddm-theme && sudo bash setup.sh"
echo ""
echo "  Then reboot: sudo reboot"
echo "══════════════════════════════════════════"
