#!/usr/bin/env bash

# Check if yt-dlp is installed
if ! command -v yt-dlp &> /dev/null; then
    echo "Error: yt-dlp is not installed"
    echo "Please install it with either:"
    echo "  - sudo apt install yt-dlp"
    echo "  - pip install -U yt-dlp"
    exit 1
fi

# Function to print menu
print_menu() {
    clear
    echo
    echo "======= YouTube Downloader ======="
    echo
    echo "1. Download video (best quality)"
    echo "2. Download audio only (MP3)"
    echo "3. Download playlist (video)"
    echo "4. Download playlist (audio)"
    echo "5. Download with subtitles"
    echo "6. Download vertical video (for mobile)"
    echo "7. Update yt-dlp"
    echo "8. Exit"
    echo
}

# Function to get video URL
get_url() {
    echo
    read -r -p "Enter YouTube URL: " url
    if [ -z "$url" ]; then
        echo "Error: URL cannot be empty"
        exit 1
    fi
}

# Function to get output directory
get_output_dir() {
    echo
    echo "Choose download location:"
    echo
    echo "1. Downloads (default: ~/Downloads)"
    echo "2. Videos (~/Videos)"
    echo "3. Music (~/Music)"
    echo "4. Custom path"
    echo
    read -r -p "Enter your choice (1-4): " dir_choice
    echo
    
    case $dir_choice in
        1)
            output_dir="$HOME/Downloads"
            ;;
        2)
            output_dir="$HOME/Videos"
            ;;
        3)
            output_dir="$HOME/Music"
            ;;
        4)
            read -r -p "Enter custom download path: " custom_path
            # Expand ~ if used in the custom path
            output_dir="${custom_path/#\~/$HOME}"
            ;;
        *)
            echo "Invalid choice, using default (~/Downloads)"
            output_dir="$HOME/Downloads"
            ;;
    esac
    
    # Create directory if it doesn't exist
    mkdir -p "$output_dir"
    cd "$output_dir" || exit 1
    echo
    echo "Downloading to: $output_dir"
    echo
}

# Function to print completion message
print_completion() {
    echo
    echo "===================================="
    echo "Download completed successfully!"
    echo "Files have been saved to: $output_dir"
    echo "===================================="
    echo
    read -r -p "Press Enter to continue..."
}

# Function to update yt-dlp based on installation method
update_ytdlp() {
    echo
    echo "Updating yt-dlp..."
    echo
    
    # Check if yt-dlp is installed via pip
    if pip list 2>/dev/null | grep -q "yt-dlp"; then
        echo "yt-dlp seems to be installed via pip. Updating with pip..."
        pip install -U yt-dlp
        update_status=$?
    else
        # Try system update method
        echo "Attempting system update method..."
        sudo yt-dlp -U
        update_status=$?
    fi
    
    if [ $update_status -eq 0 ]; then
        echo "yt-dlp updated successfully!"
    else
        echo "Update failed. Please try manually updating yt-dlp."
        echo "For pip: pip install -U yt-dlp"
        echo "For system: sudo yt-dlp -U"
    fi
    
    echo
    read -r -p "Press Enter to continue..."
}

while true; do
    print_menu
    read -r -p "Enter your choice (1-8): " choice
    
    case $choice in
        1)  # Best quality video
            get_url
            get_output_dir
            echo "Downloading best quality video..."
            echo
            yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" \
                   --embed-thumbnail \
                   --add-metadata \
                   "$url"
            print_completion
            ;;
            
        2)  # Audio only
            get_url
            get_output_dir
            echo "Downloading audio..."
            echo
            yt-dlp -x --audio-format mp3 \
                   --embed-thumbnail \
                   --add-metadata \
                   "$url"
            print_completion
            ;;
            
        3)  # Video playlist
            get_url
            get_output_dir
            echo "Downloading playlist (video)..."
            echo
            yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" \
                   --embed-thumbnail \
                   --add-metadata \
                   --yes-playlist \
                   "$url"
            print_completion
            ;;
            
        4)  # Audio playlist
            get_url
            get_output_dir
            echo "Downloading playlist (audio)..."
            echo
            yt-dlp -x --audio-format mp3 \
                   --embed-thumbnail \
                   --add-metadata \
                   --yes-playlist \
                   "$url"
            print_completion
            ;;
            
        5)  # Video with subtitles
            get_url
            get_output_dir
            echo "Downloading video with subtitles..."
            echo
            yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" \
                   --embed-thumbnail \
                   --add-metadata \
                   --write-sub \
                   --write-auto-sub \
                   --embed-subs \
                   "$url"
            print_completion
            ;;
            
        6)  # Vertical video (mobile)
            get_url
            get_output_dir
            echo "Downloading vertical video..."
            echo
            yt-dlp -f "bestvideo[ext=mp4][height<=1080]+bestaudio[ext=m4a]/best[ext=mp4]/best" \
                   --embed-thumbnail \
                   --add-metadata \
                   "$url"
            print_completion
            ;;
            
        7)  # Update yt-dlp
            update_ytdlp
            ;;

        8)  # Exit
            echo
            echo "Goodbye!"
            exit 0
            ;;
            
        *)  # Invalid option
            echo
            echo "Invalid option"
            echo
            read -r -p "Press Enter to continue..."
            ;;
    esac
done
