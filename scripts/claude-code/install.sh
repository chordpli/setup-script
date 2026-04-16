#!/usr/bin/env bash
set -e

# ---------------------------------------------------------------------------
# Claude Code installer
# Supports macOS and Linux. Auto-detects Korean/English locale.
# ---------------------------------------------------------------------------

# --- Locale detection -------------------------------------------------------
if [[ "${LANG:-}" == ko* ]] || [[ "${LC_ALL:-}" == ko* ]]; then
  LANG_KO=1
else
  LANG_KO=0
fi

msg() {
  if [[ $LANG_KO -eq 1 ]]; then
    echo -e "$2"
  else
    echo -e "$3"
  fi
}

# --- Colors -----------------------------------------------------------------
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { echo -e "${GREEN}$1${NC}"; }
warn() { echo -e "${YELLOW}$1${NC}"; }
err()  { echo -e "${RED}$1${NC}" >&2; }

# ---------------------------------------------------------------------------
# Idempotency check — if claude is already installed, print version and exit
# ---------------------------------------------------------------------------
if command -v claude &>/dev/null; then
  VERSION=$(claude --version 2>/dev/null || echo "unknown")
  if [[ $LANG_KO -eq 1 ]]; then
    ok "Claude Code가 이미 설치되어 있습니다. (버전: ${VERSION})"
    echo "업데이트하려면: npm update -g @anthropic-ai/claude-code"
  else
    ok "Claude Code is already installed. (version: ${VERSION})"
    echo "To update: npm update -g @anthropic-ai/claude-code"
  fi
  exit 0
fi

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
if [[ $LANG_KO -eq 1 ]]; then
  echo ""
  echo "=================================================="
  echo "   Claude Code 설치를 시작합니다"
  echo "=================================================="
  echo ""
else
  echo ""
  echo "=================================================="
  echo "   Installing Claude Code"
  echo "=================================================="
  echo ""
fi

# ---------------------------------------------------------------------------
# OS detection
# ---------------------------------------------------------------------------
OS="$(uname -s)"

# ---------------------------------------------------------------------------
# Node.js 18+ check
# ---------------------------------------------------------------------------
need_node=0

if ! command -v node &>/dev/null; then
  need_node=1
else
  NODE_VER=$(node --version | sed 's/v//' | cut -d. -f1)
  if [[ "$NODE_VER" -lt 18 ]]; then
    need_node=1
    if [[ $LANG_KO -eq 1 ]]; then
      warn "Node.js ${NODE_VER}이 설치되어 있지만 버전 18 이상이 필요합니다."
    else
      warn "Node.js ${NODE_VER} is installed but version 18+ is required."
    fi
  fi
fi

if [[ $need_node -eq 1 ]]; then
  if [[ $LANG_KO -eq 1 ]]; then
    warn "Node.js 18 이상이 필요합니다. 설치를 시도합니다..."
  else
    warn "Node.js 18+ is required. Attempting to install..."
  fi

  case "$OS" in
    Darwin)
      # macOS — use Homebrew
      if command -v brew &>/dev/null; then
        if [[ $LANG_KO -eq 1 ]]; then
          echo "Homebrew를 사용해 Node.js를 설치합니다..."
        else
          echo "Installing Node.js via Homebrew..."
        fi
        brew install node
      else
        if [[ $LANG_KO -eq 1 ]]; then
          err "Homebrew가 설치되어 있지 않습니다."
          echo ""
          echo "Homebrew 설치 방법:"
          echo '  /bin/bash -c "$(curl -fsSL https://brew.sh/install.sh)"'
          echo ""
          echo "설치 후 다시 이 스크립트를 실행하거나,"
          echo "https://nodejs.org 에서 Node.js를 직접 내려받아 설치하세요."
        else
          err "Homebrew is not installed."
          echo ""
          echo "Install Homebrew first:"
          echo '  /bin/bash -c "$(curl -fsSL https://brew.sh/install.sh)"'
          echo ""
          echo "Then re-run this script, or download Node.js directly from:"
          echo "  https://nodejs.org"
        fi
        exit 1
      fi
      ;;

    Linux)
      # Linux — try apt, fall back to nvm guidance
      if command -v apt &>/dev/null; then
        if [[ $LANG_KO -eq 1 ]]; then
          echo "apt를 사용해 Node.js를 설치합니다 (sudo 권한이 필요합니다)..."
        else
          echo "Installing Node.js via apt (sudo required)..."
        fi
        sudo apt update -y
        sudo apt install -y nodejs npm
        # Verify version after apt install
        NODE_VER=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1)
        if [[ "$NODE_VER" -lt 18 ]]; then
          if [[ $LANG_KO -eq 1 ]]; then
            warn "apt로 설치된 Node.js 버전이 너무 낮습니다 (v${NODE_VER})."
            echo "nvm을 사용해 최신 Node.js를 설치하는 것을 권장합니다:"
            echo ""
            echo "  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
            echo "  source ~/.bashrc   # 또는 source ~/.zshrc"
            echo "  nvm install --lts"
            echo "  nvm use --lts"
            echo ""
            echo "완료 후 이 스크립트를 다시 실행하세요."
          else
            warn "Node.js installed via apt is too old (v${NODE_VER})."
            echo "We recommend using nvm to install a recent Node.js:"
            echo ""
            echo "  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
            echo "  source ~/.bashrc   # or source ~/.zshrc"
            echo "  nvm install --lts"
            echo "  nvm use --lts"
            echo ""
            echo "Then re-run this script."
          fi
          exit 1
        fi
      else
        if [[ $LANG_KO -eq 1 ]]; then
          warn "apt 패키지 관리자를 찾을 수 없습니다."
          echo "nvm을 사용해 Node.js를 설치하세요:"
          echo ""
          echo "  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
          echo "  source ~/.bashrc   # 또는 source ~/.zshrc"
          echo "  nvm install --lts"
          echo "  nvm use --lts"
          echo ""
          echo "완료 후 이 스크립트를 다시 실행하세요."
        else
          warn "apt package manager not found."
          echo "Install Node.js using nvm:"
          echo ""
          echo "  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash"
          echo "  source ~/.bashrc   # or source ~/.zshrc"
          echo "  nvm install --lts"
          echo "  nvm use --lts"
          echo ""
          echo "Then re-run this script."
        fi
        exit 1
      fi
      ;;

    *)
      if [[ $LANG_KO -eq 1 ]]; then
        err "지원하지 않는 운영체제입니다: $OS"
        echo "https://nodejs.org 에서 Node.js 18 이상을 직접 설치해 주세요."
      else
        err "Unsupported OS: $OS"
        echo "Please install Node.js 18+ manually from https://nodejs.org"
      fi
      exit 1
      ;;
  esac
fi

# Final Node version check
NODE_VER=$(node --version 2>/dev/null | sed 's/v//' | cut -d. -f1)
if [[ "$NODE_VER" -lt 18 ]]; then
  if [[ $LANG_KO -eq 1 ]]; then
    err "Node.js 18 이상이 필요합니다. 현재 버전: $(node --version)"
  else
    err "Node.js 18+ required. Current version: $(node --version)"
  fi
  exit 1
fi

if [[ $LANG_KO -eq 1 ]]; then
  ok "Node.js $(node --version) 확인 완료"
else
  ok "Node.js $(node --version) detected"
fi

# ---------------------------------------------------------------------------
# Install Claude Code
# ---------------------------------------------------------------------------
if [[ $LANG_KO -eq 1 ]]; then
  echo ""
  echo "Claude Code를 설치합니다..."
else
  echo ""
  echo "Installing Claude Code..."
fi

npm install -g @anthropic-ai/claude-code

# ---------------------------------------------------------------------------
# Verify installation
# ---------------------------------------------------------------------------
if ! command -v claude &>/dev/null; then
  if [[ $LANG_KO -eq 1 ]]; then
    err "설치 후에도 'claude' 명령을 찾을 수 없습니다."
    echo "아래 명령으로 PATH를 갱신한 뒤 다시 시도하세요:"
  else
    err "Installation succeeded but 'claude' command not found in PATH."
    echo "Refresh your PATH with one of the commands below and try again:"
  fi
  echo "  source ~/.bashrc"
  echo "  source ~/.zshrc"
  exit 1
fi

VERSION=$(claude --version 2>/dev/null || echo "unknown")

echo ""
if [[ $LANG_KO -eq 1 ]]; then
  ok "설치가 완료되었습니다! (버전: ${VERSION})"
  echo ""
  echo "새 터미널을 열거나 아래 명령으로 PATH를 갱신하세요:"
  echo "  source ~/.bashrc   # bash 사용 시"
  echo "  source ~/.zshrc    # zsh  사용 시"
  echo ""
  echo "시작하려면 'claude' 를 입력하세요."
else
  ok "Installation complete! (version: ${VERSION})"
  echo ""
  echo "Open a new terminal or refresh your PATH:"
  echo "  source ~/.bashrc   # if you use bash"
  echo "  source ~/.zshrc    # if you use zsh"
  echo ""
  echo "Run 'claude' to get started."
fi
echo ""
