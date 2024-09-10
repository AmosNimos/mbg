#!/bin/bash
################################################################################
# Name:        mbg.sh
# Date:        2024-09-10
# Author:      Amosnimos
# Description: Procedurally animate your wallpaper with a hacker/glitch effect, featuring random hue shifts and chromatic aberration for a striking boot-up display.
################################################################################

# ▙▗▌▛▀▖▞▀▖  ▞▀▖▌ ▌
# ▌▘▌▙▄▘▌▄▖  ▚▄ ▙▄▌
# ▌ ▌▌ ▌▌ ▌▗▖▖ ▌▌ ▌
# ▘ ▘▀▀ ▝▀ ▝▘▝▀ ▘ ▘


# Default values for parameters
SOURCE_IMG="/var/tmp/wallpaper.jpg"  # Ensure the correct path to your wallpaper
FRAME_DIR="/var/tmp/mbg/"
FRAME_COUNT=16                       # Number of frames to generate
HUE_MAX=10                          # Maximum hue shift range (0 to 360 degrees)
CHROM_SHIFT_MAX=10                   # Maximum chromatic aberration shift range
FPS=24                               # Frames per second
DURATION=16                          # Total duration in seconds

# Print help function
print_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -s <source>   Path to the source wallpaper image (default: /var/tmp/wallpaper.jpg)"
    echo "  -d <duration> Duration of the animation in seconds (default: 60)"
    echo "  -f <fps>      Frames per second (default: 24)"
    echo "  -h <hue>      Maximum hue shift range in degrees (default: 10)"
    echo "  -c <shift>    Maximum chromatic aberration shift (default: 10)"
    echo "  --help        Display this help message"
    exit 0
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s) SOURCE_IMG="$2"; shift ;;
        -d) DURATION="$2"; shift ;;
        -f) FPS="$2"; shift ;;
        -h) HUE_MAX="$2"; shift ;;
        -c) CHROM_SHIFT_MAX="$2"; shift ;;
        --help) print_help ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
    shift
done

# Ensure the source image exists
if [ ! -f "$SOURCE_IMG" ]; then
    echo "Error: Source image $SOURCE_IMG not found."
    exit 1
fi

# Make the directory to store frames if it doesn't exist
mkdir -p "$FRAME_DIR"

# Clean up any previously generated frames
rm -f ${FRAME_DIR}*

# Function to create frames with random offset and chromatic aberration
generate_frames() {
    for i in $(seq 0 $((FRAME_COUNT - 1))); do
        local hue_shift=$((RANDOM % HUE_MAX))
        local chrom_shift=$((RANDOM % CHROM_SHIFT_MAX))

        # Generate random x and y offsets between -10 and 10
        local x_offset=$((RANDOM % 21 - 10))
        local y_offset=$((RANDOM % 21 - 10))

        # Apply random hue shift and chromatic aberration
        convert "$SOURCE_IMG" \
            -modulate 100,100,$hue_shift \
            \( +clone -channel R -roll +${chrom_shift}+0 -separate +channel \) \
            \( +clone -channel G -roll -${chrom_shift}+0 -separate +channel \) \
            \( +clone -channel B -separate +channel \) \
            -combine \
            -roll ${x_offset}x${y_offset} \
            "$FRAME_DIR/frame_$i.jpg"
    done
}

# Generate the frames
generate_frames

# Loop through the frames for the specified duration
END_TIME=$((SECONDS + DURATION))
while [ $SECONDS -lt $END_TIME ]; do
    for i in $(seq 0 $((FRAME_COUNT - 1))); do
        feh --bg-fill "$FRAME_DIR/frame_$i.jpg" >/dev/null 2>&1
        sleep $(echo "scale=3; 1/$FPS" | bc)
    done
done

# Set the original wallpaper at the end
feh --bg-fill "$SOURCE_IMG"

# Clean up generated frames after the script ends
rm -f ${FRAME_DIR}*
