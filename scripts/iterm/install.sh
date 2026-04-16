#!/usr/bin/env bash
set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Locale detection
if [[ "$LANG" == ko* ]]; then
  MSG_START="iTerm2를 설치합니다..."
  MSG_MACOS_ONLY="이 스크립트는 macOS에서만 사용할 수 있습니다."
  MSG_ALREADY="iTerm2가 이미 설치되어 있습니다."
  MSG_NO_BREW="Homebrew가 없습니다. 설치를 진행합니다..."
  MSG_BREW_INSTALL="Homebrew를 설치합니다..."
  MSG_BREW_DONE="Homebrew 설치가 완료되었습니다."
  MSG_INSTALLING="iTerm2를 설치 중입니다..."
  MSG_SHELL_INTEGRATION="Shell Integration을 설정합니다..."
  MSG_SHELL_ALREADY="Shell Integration이 이미 설정되어 있습니다."
  MSG_SHELL_ADDED="Shell Integration을 %s에 추가했습니다."
  MSG_DONE="설치가 완료되었습니다! iTerm2를 실행해 보세요."
  MSG_RESTART="변경 사항을 적용하려면 터미널을 새로 열거나 아래 명령을 실행해 주세요:"
else
  MSG_START="Installing iTerm2..."
  MSG_MACOS_ONLY="This script is for macOS only."
  MSG_ALREADY="iTerm2 is already installed."
  MSG_NO_BREW="Homebrew is not installed. Installing now..."
  MSG_BREW_INSTALL="Installing Homebrew..."
  MSG_BREW_DONE="Homebrew installation complete."
  MSG_INSTALLING="Installing iTerm2..."
  MSG_SHELL_INTEGRATION="Setting up Shell Integration..."
  MSG_SHELL_ALREADY="Shell Integration is already configured."
  MSG_SHELL_ADDED="Shell Integration added to %s."
  MSG_DONE="Installation complete! You can now open iTerm2."
  MSG_RESTART="To apply changes, open a new terminal or run:"
fi

echo -e "${GREEN}${MSG_START}${NC}"

# macOS only check
if [[ "$(uname -s)" != "Darwin" ]]; then
  echo -e "${RED}${MSG_MACOS_ONLY}${NC}"
  exit 1
fi

# Check if iTerm2 is already installed
ITERM_INSTALLED=false
if [[ -d "/Applications/iTerm.app" ]]; then
  echo -e "${GREEN}${MSG_ALREADY}${NC}"
  ITERM_INSTALLED=true
fi

# Check/install Homebrew
if ! command -v brew &>/dev/null; then
  echo -e "${YELLOW}${MSG_NO_BREW}${NC}"
  echo -e "${YELLOW}${MSG_BREW_INSTALL}${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add brew to PATH for the current session (Intel and Apple Silicon)
  if [[ -x "/opt/homebrew/bin/brew" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x "/usr/local/bin/brew" ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  echo -e "${GREEN}${MSG_BREW_DONE}${NC}"
fi

# Install iTerm2 if not already installed
if [[ "$ITERM_INSTALLED" = false ]]; then
  echo -e "${YELLOW}${MSG_INSTALLING}${NC}"
  brew install --cask iterm2
fi

# Shell Integration setup
echo -e "${YELLOW}${MSG_SHELL_INTEGRATION}${NC}"

SHELL_NAME="$(basename "$SHELL")"

if [[ "$SHELL_NAME" = "zsh" ]]; then
  INTEGRATION_FILE="$HOME/.iterm2_shell_integration.zsh"
  INTEGRATION_URL="https://iterm2.com/shell_integration/zsh"
  RC_FILE="$HOME/.zshrc"
  SOURCE_LINE="source \"\$HOME/.iterm2_shell_integration.zsh\""
else
  INTEGRATION_FILE="$HOME/.iterm2_shell_integration.bash"
  INTEGRATION_URL="https://iterm2.com/shell_integration/bash"
  RC_FILE="$HOME/.bashrc"
  SOURCE_LINE="source \"\$HOME/.iterm2_shell_integration.bash\""
fi

# Download shell integration script
curl -fsSL "$INTEGRATION_URL" -o "$INTEGRATION_FILE"

# Add source line to shell config if not already present
if grep -qF "iterm2_shell_integration" "$RC_FILE" 2>/dev/null; then
  echo -e "${GREEN}${MSG_SHELL_ALREADY}${NC}"
else
  echo "" >> "$RC_FILE"
  echo "$SOURCE_LINE" >> "$RC_FILE"
  printf "${GREEN}${MSG_SHELL_ADDED}${NC}\n" "$RC_FILE"
fi

# Done
echo -e "${GREEN}${MSG_DONE}${NC}"
echo -e "${YELLOW}${MSG_RESTART}${NC}"
echo "  source \"${RC_FILE}\""
