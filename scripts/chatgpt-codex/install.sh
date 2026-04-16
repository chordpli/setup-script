#!/usr/bin/env bash
set -e

# Locale detection
if [[ "$LANG" == ko* ]]; then
  MSG_CHECKING_NODE="Node.js 버전을 확인합니다..."
  MSG_NODE_NOT_FOUND="Node.js가 설치되어 있지 않습니다."
  MSG_NODE_REQUIRE="Codex는 Node.js 22 이상이 필요합니다. (다른 도구보다 높은 버전입니다)"
  MSG_NODE_OLD="Node.js 버전이 너무 낮습니다 (현재: %s, 필요: 22 이상)."
  MSG_MACOS_BREW="macOS에서 설치하는 방법:"
  MSG_MACOS_BREW_CMD="  brew install node@22"
  MSG_MACOS_NVM="또는 nvm을 사용하는 방법:"
  MSG_NVM_INSTALL="  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
  MSG_NVM_USE="  nvm install 22 && nvm use 22"
  MSG_LINUX_NOTE="Linux에서는 apt의 Node.js가 오래될 수 있으니 nvm 사용을 권장합니다:"
  MSG_ALREADY_INSTALLED="Codex가 이미 설치되어 있습니다."
  MSG_INSTALLING="Codex를 설치합니다..."
  MSG_DONE="설치가 완료되었습니다!"
  MSG_VERSION="설치된 버전:"
  MSG_PATH_BASH="터미널을 다시 열거나 아래 명령어를 실행하세요: source ~/.bashrc"
  MSG_PATH_ZSH="터미널을 다시 열거나 아래 명령어를 실행하세요: source ~/.zshrc"
  MSG_PATH_GENERIC="터미널을 다시 열거나 쉘 설정 파일을 다시 로드하세요."
  MSG_VERIFY_FAIL="설치 확인에 실패했습니다. 터미널을 다시 열고 'codex --version'을 실행해 보세요."
  MSG_ABORTED="설치를 중단합니다. 먼저 Node.js 22 이상을 설치해 주세요."
else
  MSG_CHECKING_NODE="Checking Node.js version..."
  MSG_NODE_NOT_FOUND="Node.js is not installed."
  MSG_NODE_REQUIRE="Codex requires Node.js 22 or higher. (This is higher than other tools in this project)"
  MSG_NODE_OLD="Node.js version is too old (current: %s, required: 22+)."
  MSG_MACOS_BREW="To install on macOS:"
  MSG_MACOS_BREW_CMD="  brew install node@22"
  MSG_MACOS_NVM="Or using nvm:"
  MSG_NVM_INSTALL="  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
  MSG_NVM_USE="  nvm install 22 && nvm use 22"
  MSG_LINUX_NOTE="On Linux, apt may have an older Node.js. We recommend using nvm:"
  MSG_ALREADY_INSTALLED="Codex is already installed."
  MSG_INSTALLING="Installing Codex..."
  MSG_DONE="Installation complete!"
  MSG_VERSION="Installed version:"
  MSG_PATH_BASH="Restart your terminal or run: source ~/.bashrc"
  MSG_PATH_ZSH="Restart your terminal or run: source ~/.zshrc"
  MSG_PATH_GENERIC="Restart your terminal or reload your shell config file."
  MSG_VERIFY_FAIL="Could not verify installation. Try restarting your terminal and running 'codex --version'."
  MSG_ABORTED="Installation aborted. Please install Node.js 22 or higher first."
fi

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()    { echo -e "${GREEN}$*${NC}"; }
warn()    { echo -e "${YELLOW}$*${NC}"; }
error()   { echo -e "${RED}$*${NC}"; }

# ── Node.js version check ──────────────────────────────────────────────────────
echo "$MSG_CHECKING_NODE"

NODE_MAJOR=0
if command -v node &>/dev/null; then
  NODE_VERSION=$(node --version 2>/dev/null | sed 's/v//')
  NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d. -f1)
fi

if [[ "$NODE_MAJOR" -eq 0 ]]; then
  error "$MSG_NODE_NOT_FOUND"
  warn "$MSG_NODE_REQUIRE"
  echo ""
  OS_TYPE="$(uname -s)"
  if [[ "$OS_TYPE" == "Darwin" ]]; then
    warn "$MSG_MACOS_BREW"
    echo "$MSG_MACOS_BREW_CMD"
    warn "$MSG_MACOS_NVM"
    echo "$MSG_NVM_INSTALL"
    echo "$MSG_NVM_USE"
  else
    warn "$MSG_LINUX_NOTE"
    echo "$MSG_NVM_INSTALL"
    echo "$MSG_NVM_USE"
  fi
  echo ""
  error "$MSG_ABORTED"
  exit 1
fi

if [[ "$NODE_MAJOR" -lt 22 ]]; then
  warn "$(printf "$MSG_NODE_OLD" "$NODE_VERSION")"
  warn "$MSG_NODE_REQUIRE"
  echo ""
  OS_TYPE="$(uname -s)"
  if [[ "$OS_TYPE" == "Darwin" ]]; then
    warn "$MSG_MACOS_BREW"
    echo "$MSG_MACOS_BREW_CMD"
    warn "$MSG_MACOS_NVM"
    echo "$MSG_NVM_INSTALL"
    echo "$MSG_NVM_USE"
  else
    warn "$MSG_LINUX_NOTE"
    echo "$MSG_NVM_INSTALL"
    echo "$MSG_NVM_USE"
  fi
  echo ""
  error "$MSG_ABORTED"
  exit 1
fi

# ── Idempotency check ──────────────────────────────────────────────────────────
if command -v codex &>/dev/null; then
  CURRENT_VER=$(codex --version 2>/dev/null || true)
  info "$MSG_ALREADY_INSTALLED"
  info "$MSG_VERSION $CURRENT_VER"
  exit 0
fi

# ── Install ────────────────────────────────────────────────────────────────────
info "$MSG_INSTALLING"
npm install -g @openai/codex

# ── Verify ────────────────────────────────────────────────────────────────────
if command -v codex &>/dev/null; then
  INSTALLED_VER=$(codex --version 2>/dev/null || true)
  info "$MSG_DONE"
  info "$MSG_VERSION $INSTALLED_VER"
else
  warn "$MSG_VERIFY_FAIL"
  # Offer PATH reload hint
  CURRENT_SHELL="$(basename "${SHELL:-}")"
  if [[ "$CURRENT_SHELL" == "zsh" ]]; then
    warn "$MSG_PATH_ZSH"
  elif [[ "$CURRENT_SHELL" == "bash" ]]; then
    warn "$MSG_PATH_BASH"
  else
    warn "$MSG_PATH_GENERIC"
  fi
fi
