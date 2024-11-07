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
DEFAULT_SOURCE_IMG="/var/tmp/wallpaper.jpg"  # Ensure the correct path to your wallpaper
SOURCE_IMG=$DEFAULT_SOURCE_IMG
FRAME_DIR="/var/tmp/mbg/"
FRAME_COUNT=16                       # Number of frames to generate
HUE_MAX=10                          # Maximum hue shift range (0 to 360 degrees)
CHROM_SHIFT_MAX=10                   # Maximum chromatic aberration shift range
FPS=24                               # Frames per second
DURATION=16                          # Total duration in seconds
MAX_OFFSET=10  # Set your desired max offset value

# Print help function
print_help() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -s <source>   Path to the source wallpaper image (default: /var/tmp/wallpaper.jpg)"
    echo "  -d <duration> Duration of the animation in seconds (default: 60) use 0 for infinite"
    echo "  -f <fps>      Frames per second (default: 24)"
    echo "  -u <hue>      Maximum hue shift range in degrees (default: 10)"
    echo "  -a <shift>    Maximum chromatic aberration shift (default: 10)"
    echo "  -o <offset>   Image position shift (default: 10)"
    echo "  -c            Clear frames directory ($FRAME_DIR)"
    echo "  -h, --help    Display this help message"
    exit 0
}

# Parse command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -s) SOURCE_IMG="$2"; shift ;;
        -d) DURATION="$2"; shift ;;
        -f) FPS="$2"; shift ;;
        -u) HUE_MAX="$2"; shift ;;
        -a) CHROM_SHIFT_MAX="$2"; shift ;;
        -o) MAX_OFFSET="$2"; shift ;;
        -c)
        rm -rf "${FRAME_DIR}" && echo "${FRAME_DIR} and it's content was deleted succesfully."
        exit 0
        ;;
        -h | --help) print_help ;;
        *) echo c"Unknown option: $1" >&2; exit 1 ;;
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

# Function to create frames with random offset and chromatic aberration
generate_frames() {
    # Get the extension of $SOURCE_IMG
    EXT="${SOURCE_IMG##*.}"

    # If the extension is .jpg, copy $SOURCE_IMG to $DEFAULT_SOURCE_IMG
    if [[ "$EXT" == "jpg" ]]; then
      cp "$SOURCE_IMG" "$DEFAULT_SOURCE_IMG"
    fi

    for i in $(seq 0 $((FRAME_COUNT - 1))); do
        local hue_shift=$((RANDOM % HUE_MAX))
        local chrom_shift=$((RANDOM % CHROM_SHIFT_MAX))

        # Generate random x and y offsets between -10 and 10
        local x_offset=$((RANDOM % (2 * MAX_OFFSET + 1) - MAX_OFFSET))
        local y_offset=$((RANDOM % (2 * MAX_OFFSET + 1) - MAX_OFFSET))

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
    echo "Frames Generated in ${FRAME_DIR}"
}

# Generate the frames if frame directory is empty
if [[ -z "$( ls -A $FRAME_DIR)" ]]; then
    generate_frames
fi

# Loop through the frames for the specified duration
END_TIME=$((SECONDS + DURATION))

if [[ $DURATION -gt 0 ]]; then
    while [ $SECONDS -lt $END_TIME ]; do
        for i in $(seq 0 $((FRAME_COUNT - 1))); do
            feh --bg-fill "$FRAME_DIR/frame_$i.jpg" >/dev/null 2>&1
            sleep $(echo "scale=3; 1/$FPS" | bc)
        done
    done
else
    # Run infinitly
    while :; do
        for i in $(seq 0 $((FRAME_COUNT - 1))); do
            feh --bg-fill "$FRAME_DIR/frame_$i.jpg" >/dev/null 2>&1
            sleep $(echo "scale=3; 1/$FPS" | bc)
        done
    done
fi



# Set the original wallpaper at the end
feh --bg-fill "$SOURCE_IMG"

# Clean up generated frames after the script ends
#rm -f ${FRAME_DIR}*
