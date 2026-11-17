#!/bin/sh
# macOS の設定のうち、初期値から変えているもの。
# 中身を変えると、次の chezmoi apply で実行される。
set -eu

# キーボード: キーリピートを速く、始まるまでを短く（ログインし直すと反映される）
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
# スペルの自動修正
defaults write -g NSAutomaticSpellingCorrectionEnabled -bool true
# 外観: ダーク（ログインし直すと反映される）
defaults write -g AppleInterfaceStyle -string Dark

# Finder: 拡張子を全部表示、パスバーを表示、リストで表示
defaults write -g AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv

# Dock: 自動で隠す、アイコンの大きさ
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -float 64

# トラックパッド: タップでクリック（内蔵、Magic Trackpad、今のユーザー）
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1

# Dock と Finder を再起動して反映する（動いていなくても止めない）
killall Dock Finder || true
