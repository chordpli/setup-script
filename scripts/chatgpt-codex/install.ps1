# OpenAI Codex CLI installer
# UTF-8 with BOM — PowerShell 5.1 compatible

# Locale detection
$culture = (Get-Culture).Name
if ($culture -like "ko*") {
    $MSG_CHECKING_NODE    = "Node.js 버전을 확인합니다..."
    $MSG_NODE_NOT_FOUND   = "Node.js가 설치되어 있지 않습니다."
    $MSG_NODE_REQUIRE     = "Codex는 Node.js 22 이상이 필요합니다. (다른 도구보다 높은 버전입니다)"
    $MSG_NODE_OLD         = "Node.js 버전이 너무 낮습니다 (현재: {0}, 필요: 22 이상)."
    $MSG_WINGET_TRY       = "winget으로 Node.js 22를 설치합니다..."
    $MSG_WINGET_DONE      = "Node.js 설치가 완료되었습니다. 경로(PATH)를 갱신합니다..."
    $MSG_WINGET_FAIL      = "winget 설치에 실패했습니다."
    $MSG_MANUAL           = "nodejs.org에서 직접 다운로드하여 설치해 주세요:"
    $MSG_MANUAL_URL       = "  https://nodejs.org/en/download/"
    $MSG_ALREADY          = "Codex가 이미 설치되어 있습니다."
    $MSG_VERSION          = "설치된 버전:"
    $MSG_INSTALLING       = "Codex를 설치합니다..."
    $MSG_DONE             = "설치가 완료되었습니다!"
    $MSG_VERIFY_FAIL      = "설치 확인에 실패했습니다. 새 PowerShell 창을 열고 'codex --version'을 실행해 보세요."
    $MSG_ABORTED          = "설치를 중단합니다. 먼저 Node.js 22 이상을 설치해 주세요."
    $MSG_UPGRADE_GUIDE    = "Node.js를 22 이상으로 업그레이드해 주세요:"
} else {
    $MSG_CHECKING_NODE    = "Checking Node.js version..."
    $MSG_NODE_NOT_FOUND   = "Node.js is not installed."
    $MSG_NODE_REQUIRE     = "Codex requires Node.js 22 or higher. (This is higher than other tools in this project)"
    $MSG_NODE_OLD         = "Node.js version is too old (current: {0}, required: 22+)."
    $MSG_WINGET_TRY       = "Installing Node.js 22 via winget..."
    $MSG_WINGET_DONE      = "Node.js installed. Refreshing PATH..."
    $MSG_WINGET_FAIL      = "winget installation failed."
    $MSG_MANUAL           = "Please download and install Node.js directly from:"
    $MSG_MANUAL_URL       = "  https://nodejs.org/en/download/"
    $MSG_ALREADY          = "Codex is already installed."
    $MSG_VERSION          = "Installed version:"
    $MSG_INSTALLING       = "Installing Codex..."
    $MSG_DONE             = "Installation complete!"
    $MSG_VERIFY_FAIL      = "Could not verify installation. Open a new PowerShell window and run 'codex --version'."
    $MSG_ABORTED          = "Installation aborted. Please install Node.js 22 or higher first."
    $MSG_UPGRADE_GUIDE    = "Please upgrade Node.js to version 22 or higher:"
}

function Write-Info  { param($msg) Write-Host $msg -ForegroundColor Green }
function Write-Warn  { param($msg) Write-Host $msg -ForegroundColor Yellow }
function Write-Err   { param($msg) Write-Host $msg -ForegroundColor Red }

# ── Node.js version check ──────────────────────────────────────────────────────
Write-Host $MSG_CHECKING_NODE

$nodeMajor = 0
$nodeVersion = ""
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCmd) {
    $nodeVersion = (node --version 2>$null) -replace "^v", ""
    $nodeMajor = [int]($nodeVersion -split "\.")[0]
}

if ($nodeMajor -eq 0) {
    Write-Err $MSG_NODE_NOT_FOUND
    Write-Warn $MSG_NODE_REQUIRE
    Write-Host ""
    Write-Warn $MSG_WINGET_TRY

    $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
    $wingetOk = $false
    if ($wingetCmd) {
        winget install --id OpenJS.NodeJS --exact --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            $wingetOk = $true
        }
    }

    if ($wingetOk) {
        Write-Info $MSG_WINGET_DONE
        # Refresh PATH
        $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")

        # Re-check node after install
        $nodeCmd2 = Get-Command node -ErrorAction SilentlyContinue
        if ($nodeCmd2) {
            $nodeVersion = (node --version 2>$null) -replace "^v", ""
            $nodeMajor = [int]($nodeVersion -split "\.")[0]
        }

        if ($nodeMajor -lt 22) {
            Write-Err ([string]::Format($MSG_NODE_OLD, $nodeVersion))
            Write-Warn $MSG_MANUAL
            Write-Host $MSG_MANUAL_URL
            Write-Host ""
            Write-Err $MSG_ABORTED
            exit 1
        }
    } else {
        Write-Err $MSG_WINGET_FAIL
        Write-Warn $MSG_MANUAL
        Write-Host $MSG_MANUAL_URL
        Write-Host ""
        Write-Err $MSG_ABORTED
        exit 1
    }
}

if ($nodeMajor -lt 22) {
    Write-Err ([string]::Format($MSG_NODE_OLD, $nodeVersion))
    Write-Warn $MSG_NODE_REQUIRE
    Write-Host ""
    Write-Warn $MSG_UPGRADE_GUIDE
    Write-Warn $MSG_WINGET_TRY
    Write-Host "  winget install --id OpenJS.NodeJS --exact"
    Write-Warn $MSG_MANUAL
    Write-Host $MSG_MANUAL_URL
    Write-Host ""
    Write-Err $MSG_ABORTED
    exit 1
}

# ── Idempotency check ──────────────────────────────────────────────────────────
$codexCmd = Get-Command codex -ErrorAction SilentlyContinue
if ($codexCmd) {
    $currentVer = (codex --version 2>$null)
    Write-Info $MSG_ALREADY
    Write-Info "$MSG_VERSION $currentVer"
    exit 0
}

# ── Install ────────────────────────────────────────────────────────────────────
Write-Info $MSG_INSTALLING
npm install -g @openai/codex

# Refresh PATH so codex is findable immediately
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")

# ── Verify ────────────────────────────────────────────────────────────────────
$codexCmd2 = Get-Command codex -ErrorAction SilentlyContinue
if ($codexCmd2) {
    $installedVer = (codex --version 2>$null)
    Write-Info $MSG_DONE
    Write-Info "$MSG_VERSION $installedVer"
} else {
    Write-Warn $MSG_VERIFY_FAIL
}
