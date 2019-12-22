#!/bin/zsh
# https://stackoverflow.com/questions/6910901/how-do-i-print-a-list-of-build-settings-in-xcode-project
# https://help.apple.com/xcode/mac/8.0/#/itcaec37c2a6
# Use prefixes to inform Xcode: echo "warning: " or echo "error: "

set -e
cd $SRCROOT/..

# load NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! which node > /dev/null; then
  echo "error: node is not installed"
  exit 1
fi

npm run build
