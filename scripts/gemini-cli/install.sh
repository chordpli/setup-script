#!/usr/bin/env bash
set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Locale detection
if [[ "$LANG" == ko* ]]; then
  MSG_START="Gemini CLI를 설치합니다..."
  MSG_ALREADY="Gemini CLI가 이미 설치되어 있습니다."
  MSG_NODE_MISSING="Node.js가 설치되어 있지 않습니다."
  MSG_NODE_VERSION="Node.js 버전이 너무 낮습니다 (18 이상 필요). 현재 버전:"
  MSG_BREW_INSTALL="Homebrew로 Node.js를 설치합니다..."
  MSG_NO_BREW="Homebrew가 없습니다. 먼저 설치해 주세요:"
  MSG_LINUX_APT="Node.js를 설치합니다 (sudo 권한이 필요합니다)..."
  MSG_LINUX_GUIDE="또는 nvm을 사용해 설치할 수 있습니다:"
  MSG_INSTALLING="Gemini CLI를 설치 중입니다..."
  MSG_DONE="설치가 완료되었습니다!"
  MSG_VERSION="설치된 버전:"
  MSG_PATH_BASH="터미널을 새로 열거나 아래 명령을 실행해 주세요:"
  MSG_VERIFY_FAIL="설치 확인에 실패했습니다. PATH를 새로 고친 후 다시 시도해 주세요."
else
  MSG_START="Installing Gemini CLI..."
  MSG_ALREADY="Gemini CLI is already installed."
  MSG_NODE_MISSING="Node.js is not installed."
  MSG_NODE_VERSION="Node.js version is too old (18+ required). Current version:"
  MSG_BREW_INSTALL="Installing Node.js via Homebrew..."
  MSG_NO_BREW="Homebrew is not installed. Please install it first:"
  MSG_LINUX_APT="Installing Node.js (sudo privileges required)..."
  MSG_LINUX_GUIDE="Alternatively, you can install via nvm:"
  MSG_INSTALLING="Installing Gemini CLI..."
  MSG_DONE="Installation complete!"
  MSG_VERSION="Installed version:"
  MSG_PATH_BASH="Open a new terminal or run the following command:"
  MSG_VERIFY_FAIL="Verification failed. Please refresh your PATH and try again."
fi

echo -e "${GREEN}${MSG_START}${NC}"

# Check if already installed
if command -v gemini &>/dev/null; then
  CURRENT_VER=$(gemini --version 2>/dev/null || true)
  echo -e "${GREEN}${MSG_ALREADY}${NC}"
  echo -e "${GREEN}${MSG_VERSION} ${CURRENT_VER}${NC}"
  exit 0
fi

# Helper: get Node.js major version
node_major_version() {
  node --version 2>/dev/null | sed 's/v//' | cut -d. -f1
}

# Check Node.js 18+
NODE_OK=false
if command -v node &>/dev/null; then
  MAJOR=$(node_major_version)
  if [ "$MAJOR" -ge 18 ] 2>/dev/null; then
    NODE_OK=true
  else
    echo -e "${YELLOW}${MSG_NODE_VERSION} $(node --version)${NC}"
  fi
else
  echo -e "${YELLOW}${MSG_NODE_MISSING}${NC}"
fi

# Install Node.js if needed
if [ "$NODE_OK" = false ]; then
  OS="$(uname -s)"
  case "$OS" in
    Darwin)
      if command -v brew &>/dev/null; then
        echo -e "${YELLOW}${MSG_BREW_INSTALL}${NC}"
        brew install node
      else
        echo -e "${RED}${MSG_NO_BREW}${NC}"
        echo "  https://brew.sh"
        echo ""
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
      fi
      ;;
    Linux)
      if command -v apt &>/dev/null; then
        echo -e "${YELLOW}${MSG_LINUX_APT}${NC}"
        sudo apt update -y
        sudo apt install -y nodejs npm
      else
        echo -e "${YELLOW}${MSG_LINUX_GUIDE}${NC}"
        echo "  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
        echo "  source ~/.bashrc"
        echo "  nvm install --lts"
        exit 1
      fi
      ;;
    *)
      echo -e "${RED}Unsupported OS: ${OS}${NC}"
      exit 1
      ;;
  esac
fi

# Install Gemini CLI
echo -e "${YELLOW}${MSG_INSTALLING}${NC}"
npm install -g @google/gemini-cli

# PATH refresh guidance
SHELL_NAME="$(basename "$SHELL")"
if [ "$SHELL_NAME" = "zsh" ]; then
  RC_FILE="~/.zshrc"
else
  RC_FILE="~/.bashrc"
fi
echo -e "${YELLOW}${MSG_PATH_BASH}${NC}"
echo "  source ${RC_FILE}"

# Verify installation
if command -v gemini &>/dev/null; then
  INSTALLED_VER=$(gemini --version 2>/dev/null || true)
  echo -e "${GREEN}${MSG_DONE}${NC}"
  echo -e "${GREEN}${MSG_VERSION} ${INSTALLED_VER}${NC}"
else
  echo -e "${YELLOW}${MSG_VERIFY_FAIL}${NC}"
fi
