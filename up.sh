# Detect OS and find Firefox profile
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    PROFILE_DIR=$(ls -d "$HOME/Library/Application Support/Firefox/Profiles"/*.default-release 2>/dev/null | head -n 1)
    QUIT_FIREFOX="osascript -e 'tell application \"Firefox\" to quit' 2>/dev/null || killall Firefox 2>/dev/null || true"
    START_FIREFOX="open -a Firefox"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux (Ubuntu, etc.)
    # Try to find default profile from profiles.ini
    PROFILES_INI="$HOME/.mozilla/firefox/profiles.ini"
    if [ -f "$PROFILES_INI" ]; then
        # Find profile with Default=1, then get its Path
        # Use awk to parse profiles.ini properly
        DEFAULT_PROFILE=$(awk '
            BEGIN { 
                profile_path = ""
                is_default = 0
            }
            /^\[Profile/ { 
                if (profile_path != "" && is_default == 1) {
                    print profile_path
                    exit
                }
                profile_path = ""
                is_default = 0
            }
            /^Path=/ { 
                profile_path = substr($0, 6)
            }
            /^Default=1/ { 
                is_default = 1
            }
            END {
                if (profile_path != "" && is_default == 1) {
                    print profile_path
                }
            }
        ' "$PROFILES_INI")
        
        # If no default found, use first profile
        if [ -z "$DEFAULT_PROFILE" ]; then
            DEFAULT_PROFILE=$(grep "^Path=" "$PROFILES_INI" | head -n 1 | cut -d'=' -f2)
        fi
        
        if [ -n "$DEFAULT_PROFILE" ]; then
            # Check if path is relative or absolute
            if [ "${DEFAULT_PROFILE#/}" != "$DEFAULT_PROFILE" ]; then
                # Absolute path
                PROFILE_DIR="$DEFAULT_PROFILE"
            else
                # Relative path
                PROFILE_DIR="$HOME/.mozilla/firefox/$DEFAULT_PROFILE"
            fi
        else
            # Last resort: try common profile names
            PROFILE_DIR=$(ls -d "$HOME/.mozilla/firefox"/*.default* 2>/dev/null | head -n 1)
        fi
    else
        # Fallback: try common profile names
        PROFILE_DIR=$(ls -d "$HOME/.mozilla/firefox"/*.default* 2>/dev/null | head -n 1)
    fi
    QUIT_FIREFOX="killall firefox 2>/dev/null || pkill firefox 2>/dev/null || true"
    START_FIREFOX="firefox &"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

if [ -z "$PROFILE_DIR" ] || [ ! -d "$PROFILE_DIR" ]; then
    echo "Error: Firefox profile not found. Make sure Firefox has been run at least once."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Searched in: $HOME/.mozilla/firefox/"
        echo "Available profiles:"
        ls -d "$HOME/.mozilla/firefox"/*/ 2>/dev/null | sed 's|.*/||' || echo "  (none found)"
    fi
    exit 1
fi

if [ "$1" = "--uninstall" ]; then
    echo "Removing profile from Firefox..."
    rm -rf "$PROFILE_DIR/chrome"
else
    echo "Applying profile to Firefox..."
    cp -r "$(pwd)/chrome" "$PROFILE_DIR/"
fi
echo "Restarting Firefox..."
eval $QUIT_FIREFOX
sleep 1
eval $START_FIREFOX
echo "Done!"
