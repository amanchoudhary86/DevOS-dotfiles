#!/bin/bash
# Cycles through all wallpapers in ~/Wallpapers/

WALLPAPER_DIR="$HOME/Wallpapers"
ACTIVE="$WALLPAPER_DIR/active_wallpaper"

# Start swww-daemon if not running
if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 1 # wait for daemon to start
fi

# Get all valid wallpapers (excluding the symlink itself)
mapfile -t WALLS < <(find "$WALLPAPER_DIR" -maxdepth 1 \( -name "*.mp4" -o -name "*.webm" -o -name "*.gif" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | sort)

if [ ${#WALLS[@]} -eq 0 ]; then
    notify-send "Wallpaper" "No wallpapers found in ~/Wallpapers/"
    exit 1
fi

# Find current wallpaper
CURRENT=$(readlink "$ACTIVE" 2>/dev/null)

# Find index of current + pick next
NEXT="${WALLS[0]}"
for i in "${!WALLS[@]}"; do
    if [ "${WALLS[$i]}" = "$CURRENT" ]; then
        NEXT="${WALLS[$(( (i + 1) % ${#WALLS[@]} ))]}"
        break
    fi
done

# Switch wallpaper symlink
ln -sf "$NEXT" "$ACTIVE"

# Determine file type and apply wallpaper
MIME=$(file --mime-type -b "$NEXT")

if [[ "$MIME" == video/* ]] || [[ "$MIME" == image/gif ]]; then
    # It's an animated wallpaper/video
    pkill mpvpaper 2>/dev/null
    mpvpaper '*' "$NEXT" -o "loop no-audio no-sub hwdec=auto panscan=1.0 vf=fps=30" &
else
    # It's a static image
    pkill mpvpaper 2>/dev/null
    swww img "$NEXT" --transition-type grow --transition-pos 0.5,0.5 --transition-step 90 --filter Nearest
fi

# notify-send "Wallpaper" "Switched to: $(basename "$NEXT")"
