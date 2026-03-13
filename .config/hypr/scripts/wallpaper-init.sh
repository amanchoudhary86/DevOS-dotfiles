#!/bin/bash
# Initializes wallpaper on boot/reload based on active_wallpaper symlink

WALLPAPER_DIR="$HOME/Wallpapers"
ACTIVE="$WALLPAPER_DIR/active_wallpaper"

# Always start swww-daemon in the background
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 1
fi

if [ -L "$ACTIVE" ] && [ -e "$ACTIVE" ]; then
    TARGET=$(readlink -f "$ACTIVE")
    MIME=$(file --mime-type -b "$TARGET")
    
    if [[ "$MIME" == video/* ]] || [[ "$MIME" == image/gif ]]; then
        mpvpaper '*' "$TARGET" -o "loop no-audio no-sub hwdec=auto panscan=1.0 vf=fps=30" &
    else
        swww img "$TARGET" --transition-type none --filter Nearest
    fi
else
    # Fallback if no active_wallpaper exists
    # Look for any valid wallpaper
    FALLBACK=$(find "$WALLPAPER_DIR" -maxdepth 1 \( -name "*.mp4" -o -name "*.webm" -o -name "*.gif" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | sort | head -n 1)
    if [ -n "$FALLBACK" ]; then
        ln -sf "$FALLBACK" "$ACTIVE"
        ~/.config/hypr/scripts/wallpaper-init.sh
    fi
fi
