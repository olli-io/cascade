echo "Applying profile to Firefox..."
cp -r ~/git/cascade/chrome ~/Library/Application\ Support/Firefox/Profiles/*.default-release/
echo "Restarting Firefox..."
osascript -e 'tell application "Firefox" to quit' 2>/dev/null || killall Firefox 2>/dev/null || true
sleep 1
open -a Firefox
echo "Done!"
