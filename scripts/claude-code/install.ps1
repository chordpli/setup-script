# Claude Code Installer for Windows
# PowerShell 5.1 compatible
# UTF-8 with BOM

#Requires -Version 5.1

# ---------------------------------------------------------------------------
# Locale detection
# ---------------------------------------------------------------------------
$culture = (Get-Culture).Name
$isKorean = $culture -like "ko*"

function Write-Ok   { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Warn { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Err  { param($msg) Write-Host $msg -ForegroundColor Red }

function Get-Msg {
    param($ko, $en)
    if ($isKorean) { return $ko } else { return $en }
}

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "=================================================="
if ($isKorean) {
    Write-Host "   Claude Code 설치를 시작합니다"
} else {
    Write-Host "   Installing Claude Code"
}
Write-Host "=================================================="
Write-Host ""

# ---------------------------------------------------------------------------
# Idempotency check — if claude is already installed, print version and exit
# ---------------------------------------------------------------------------
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if ($claudeCmd) {
    $version = & claude --version 2>$null
    if ($isKorean) {
        Write-Ok "Claude Code가 이미 설치되어 있습니다. (버전: $version)"
        Write-Host "업데이트하려면: npm update -g @anthropic-ai/claude-code"
    } else {
        Write-Ok "Claude Code is already installed. (version: $version)"
        Write-Host "To update: npm update -g @anthropic-ai/claude-code"
    }
    exit 0
}

# ---------------------------------------------------------------------------
# Admin rights check (needed for winget system-wide installs)
# ---------------------------------------------------------------------------
$currentPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    if ($isKorean) {
        Write-Warn "관리자 권한 없이 실행 중입니다. winget 설치에 실패할 경우 관리자 권한으로 다시 실행하세요."
    } else {
        Write-Warn "Running without administrator rights. If winget install fails, re-run as Administrator."
    }
}

# ---------------------------------------------------------------------------
# Helper: refresh PATH from registry (Machine + User)
# ---------------------------------------------------------------------------
function Update-EnvPath {
    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath    = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path    = $machinePath + ";" + $userPath
}

# ---------------------------------------------------------------------------
# Node.js 18+ check
# ---------------------------------------------------------------------------
$needNode = $false

$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCmd) {
    $needNode = $true
} else {
    $rawVer   = & node --version 2>$null          # e.g. "v20.11.0"
    $major    = [int]($rawVer -replace '^v(\d+).*','$1')
    if ($major -lt 18) {
        $needNode = $true
        if ($isKorean) {
            Write-Warn "Node.js $rawVer 이 설치되어 있지만 버전 18 이상이 필요합니다."
        } else {
            Write-Warn "Node.js $rawVer is installed but version 18+ is required."
        }
    }
}

if ($needNode) {
    if ($isKorean) {
        Write-Warn "Node.js 18 이상이 필요합니다. 설치를 시도합니다..."
    } else {
        Write-Warn "Node.js 18+ is required. Attempting to install..."
    }

    $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
    $nodeInstalled = $false

    if ($wingetCmd) {
        if ($isKorean) {
            Write-Host "winget으로 Node.js LTS를 설치합니다..."
        } else {
            Write-Host "Installing Node.js LTS via winget..."
        }

        winget install --id OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -eq 0) {
            $nodeInstalled = $true
        } else {
            if ($isKorean) {
                Write-Warn "winget 설치에 실패했습니다."
            } else {
                Write-Warn "winget install failed."
            }
        }
    }

    if (-not $nodeInstalled) {
        if ($isKorean) {
            Write-Err "Node.js를 자동으로 설치하지 못했습니다."
            Write-Host ""
            Write-Host "아래 주소에서 Node.js 설치 프로그램을 내려받아 설치하세요:"
            Write-Host "  https://nodejs.org"
            Write-Host ""
            Write-Host "설치 완료 후 새 PowerShell 창을 열고 이 스크립트를 다시 실행하세요."
        } else {
            Write-Err "Could not install Node.js automatically."
            Write-Host ""
            Write-Host "Please download and install Node.js from:"
            Write-Host "  https://nodejs.org"
            Write-Host ""
            Write-Host "After installation, open a new PowerShell window and re-run this script."
        }
        exit 1
    }

    # Refresh PATH so node is visible in this session
    Update-EnvPath

    # Verify node is now available
    $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
    if (-not $nodeCmd) {
        if ($isKorean) {
            Write-Err "Node.js 설치 후에도 명령을 찾을 수 없습니다."
            Write-Host "새 PowerShell 창을 열고 이 스크립트를 다시 실행하세요."
        } else {
            Write-Err "Node.js was installed but the command is still not found."
            Write-Host "Please open a new PowerShell window and re-run this script."
        }
        exit 1
    }
}

$rawVer = & node --version 2>$null
$major  = [int]($rawVer -replace '^v(\d+).*','$1')
if ($major -lt 18) {
    if ($isKorean) {
        Write-Err "Node.js 18 이상이 필요합니다. 현재 버전: $rawVer"
    } else {
        Write-Err "Node.js 18+ required. Current version: $rawVer"
    }
    exit 1
}

Write-Ok (Get-Msg "Node.js $rawVer 확인 완료" "Node.js $rawVer detected")

# ---------------------------------------------------------------------------
# Install Claude Code
# ---------------------------------------------------------------------------
Write-Host ""
if ($isKorean) {
    Write-Host "Claude Code를 설치합니다..."
} else {
    Write-Host "Installing Claude Code..."
}

npm install -g @anthropic-ai/claude-code
if ($LASTEXITCODE -ne 0) {
    if ($isKorean) {
        Write-Err "npm 설치 중 오류가 발생했습니다."
    } else {
        Write-Err "An error occurred during npm install."
    }
    exit 1
}

# Refresh PATH after npm global install
Update-EnvPath

# ---------------------------------------------------------------------------
# Git Bash check (required by Claude Code on Windows)
# ---------------------------------------------------------------------------
Write-Host ""
if ($isKorean) {
    Write-Host "Git Bash 설치 여부를 확인합니다..."
} else {
    Write-Host "Checking for Git Bash (required by Claude Code on Windows)..."
}

$gitBashPaths = @(
    "C:\Program Files\Git\bin\bash.exe",
    "C:\Program Files (x86)\Git\bin\bash.exe",
    "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
)

$gitBashFound = $null
foreach ($p in $gitBashPaths) {
    if (Test-Path $p) {
        $gitBashFound = $p
        break
    }
}

if (-not $gitBashFound) {
    if ($isKorean) {
        Write-Warn "Git Bash를 찾을 수 없습니다. Claude Code 실행에 필요합니다."
    } else {
        Write-Warn "Git Bash not found. It is required for Claude Code to run on Windows."
    }

    $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
    $gitInstalled = $false

    if ($wingetCmd) {
        if ($isKorean) {
            Write-Host "winget으로 Git (Git Bash 포함)을 설치합니다..."
        } else {
            Write-Host "Installing Git (includes Git Bash) via winget..."
        }

        winget install --id Git.Git --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -eq 0) {
            $gitInstalled = $true
            Update-EnvPath
            # Re-check for git bash after install
            foreach ($p in $gitBashPaths) {
                if (Test-Path $p) {
                    $gitBashFound = $p
                    break
                }
            }
        } else {
            if ($isKorean) {
                Write-Warn "winget으로 Git 설치에 실패했습니다."
            } else {
                Write-Warn "Failed to install Git via winget."
            }
        }
    }

    if (-not $gitBashFound) {
        if ($isKorean) {
            Write-Warn "Git Bash를 자동으로 설치하지 못했습니다."
            Write-Host ""
            Write-Host "아래 주소에서 Git for Windows를 설치하세요:"
            Write-Host "  https://git-scm.com/download/win"
            Write-Host ""
            Write-Host "설치 후 환경 변수를 설정하세요:"
            Write-Host '  $env:CLAUDE_CODE_GIT_BASH_PATH = "C:\Program Files\Git\bin\bash.exe"'
            Write-Host "또는 시스템 환경 변수에 CLAUDE_CODE_GIT_BASH_PATH를 영구 등록하세요."
        } else {
            Write-Warn "Could not install Git Bash automatically."
            Write-Host ""
            Write-Host "Please install Git for Windows from:"
            Write-Host "  https://git-scm.com/download/win"
            Write-Host ""
            Write-Host "Then set the environment variable:"
            Write-Host '  $env:CLAUDE_CODE_GIT_BASH_PATH = "C:\Program Files\Git\bin\bash.exe"'
            Write-Host "Or add CLAUDE_CODE_GIT_BASH_PATH permanently via System Environment Variables."
        }
    } else {
        $env:CLAUDE_CODE_GIT_BASH_PATH = $gitBashFound
        [Environment]::SetEnvironmentVariable("CLAUDE_CODE_GIT_BASH_PATH", $gitBashFound, "User")
        Write-Ok (Get-Msg "Git Bash 경로가 설정되었습니다: $gitBashFound" "Git Bash path configured: $gitBashFound")
    }
} else {
    $env:CLAUDE_CODE_GIT_BASH_PATH = $gitBashFound
    [Environment]::SetEnvironmentVariable("CLAUDE_CODE_GIT_BASH_PATH", $gitBashFound, "User")
    Write-Ok (Get-Msg "Git Bash 확인 완료: $gitBashFound" "Git Bash found: $gitBashFound")
}

# ---------------------------------------------------------------------------
# Verify Claude Code installation
# ---------------------------------------------------------------------------
$claudeCmd = Get-Command claude -ErrorAction SilentlyContinue
if (-not $claudeCmd) {
    if ($isKorean) {
        Write-Err "설치 후에도 'claude' 명령을 찾을 수 없습니다."
        Write-Host "새 PowerShell 창을 열고 다시 시도하세요."
    } else {
        Write-Err "Installation succeeded but 'claude' command is not in PATH."
        Write-Host "Please open a new PowerShell window and try again."
    }
    exit 1
}

$version = & claude --version 2>$null

Write-Host ""
if ($isKorean) {
    Write-Ok "설치가 완료되었습니다! (버전: $version)"
    Write-Host ""
    Write-Host "새 PowerShell 창을 열고 'claude'를 입력해 시작하세요."
} else {
    Write-Ok "Installation complete! (version: $version)"
    Write-Host ""
    Write-Host "Open a new PowerShell window and run 'claude' to get started."
}
Write-Host ""
