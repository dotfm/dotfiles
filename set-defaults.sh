!#/bin/sh
# Run ./set-defaults.sh and you'll be good to go.
if [ "$(uname -s)" != "Darwin" ]; then
	exit 0
fi

set +e

disable_agent() {
	mv "$1" "$1_DISABLED" >/dev/null 2>&1 ||
		sudo mv "$1" "$1_DISABLED" >/dev/null 2>&1
}

unload_agent() {
	launchctl unload -w "$1" >/dev/null 2>&1
}


chflags nohidden ~/Library
defaults write com.apple.dashboard mcx-disabled -bool true


defaults write com.apple.BezelServices kDimTime -int 300

defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
defaults write com.apple.dashboard mcx-disabled -bool true
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleAquaColorVariant -int 6
defaults write com.apple.menuextra.battery ShowPercent -bool true

/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
-kill -r -domain local -domain system -domain user

defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
defaults write com.apple.mail DisableInlineAttachmentViewing -bool true
defaults write com.apple.mail DisableReplyAnimations -bool true
defaults write com.apple.mail DisableSendAnimations -bool true

defaults write com.apple.finder QLEnableTextSelection -bool true

defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

##

sudo defaults write /.Spotlight-V100/VolumeConfiguration Exclusions -array "/Volumes"
sudo chmod 600 /System/Library/CoreServices/Search.bundle/Contents/MacOS/Search

# Load new settings before rebuilding the index
  killall mds > /dev/null 2>&1
  # Make sure indexing is enabled for the main volume
  sudo mdutil -i on / > /dev/null
  # Rebuild the index from scratch
sudo mdutil -E / > /dev/null

##

if [ -z "$KEEP_ITUNES" ]; then
	echo "  › Disable iTunes helper"
	disable_agent /Applications/iTunes.app/Contents/MacOS/iTunesHelper.app
	echo "  › Prevent play button from launching iTunes"
	unload_agent /System/Library/LaunchAgents/com.apple.rcd.plist
fi

echo "  › Disable Spotify web helper"
disable_agent ~/Applications/Spotify.app/Contents/MacOS/SpotifyWebHelper

##

echo ""
echo "› Kill related apps"
for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
	"Dock" "Finder" "Mail" "Messages" "Safari" "SystemUIServer" \
	"Terminal" "Photos"; do
	killall "$app" >/dev/null 2>&1
done
set -e
