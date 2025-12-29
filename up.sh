# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    FIREFOX_PROFILE_PATH="$HOME/Library/Application Support/Firefox/Profiles/*.default-release"
    QUIT_FIREFOX="osascript -e 'tell application \"Firefox\" to quit' 2>/dev/null || killall Firefox 2>/dev/null || true"
    START_FIREFOX="open -a Firefox"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux (Ubuntu, etc.)
    FIREFOX_PROFILE_PATH="$HOME/.mozilla/firefox/*.default-release"
    QUIT_FIREFOX="killall firefox 2>/dev/null || pkill firefox 2>/dev/null || true"
    START_FIREFOX="firefox &"
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

if [ "$1" = "--uninstall" ]; then
    echo "Removing profile from Firefox..."
    rm -rf "$FIREFOX_PROFILE_PATH/chrome"
else
    echo "Applying profile to Firefox..."
    # Get the actual profile directory (handle wildcard)
    PROFILE_DIR=$(ls -d $FIREFOX_PROFILE_PATH 2>/dev/null | head -n 1)
    if [ -z "$PROFILE_DIR" ]; then
        echo "Error: Firefox profile not found. Make sure Firefox has been run at least once."
        exit 1
    fi
    cp -r "$(pwd)/chrome" "$PROFILE_DIR/"
fi
echo "Restarting Firefox..."
eval $QUIT_FIREFOX
sleep 1
eval $START_FIREFOX
echo "Done!"
