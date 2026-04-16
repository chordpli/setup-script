# Gemini CLI Installer for Windows
# UTF-8 with BOM — PowerShell 5.1 compatible

# Locale detection
$culture = (Get-Culture).Name
if ($culture -like "ko*") {
    $msgStart       = "Gemini CLI를 설치합니다..."
    $msgAlready     = "Gemini CLI가 이미 설치되어 있습니다."
    $msgVersion     = "설치된 버전:"
    $msgNodeMissing = "Node.js가 설치되어 있지 않습니다."
    $msgNodeOld     = "Node.js 버전이 너무 낮습니다 (18 이상 필요). 현재 버전:"
    $msgNodeInstall = "winget으로 Node.js LTS를 설치합니다..."
    $msgNoWinget    = "winget을 사용할 수 없습니다. 아래 주소에서 직접 설치해 주세요:"
    $msgInstalling  = "Gemini CLI를 설치 중입니다..."
    $msgDone        = "설치가 완료되었습니다!"
    $msgPathRefresh = "PATH를 새로 고칩니다..."
    $msgVerifyFail  = "설치 확인에 실패했습니다. 터미널을 새로 열고 다시 시도해 주세요."
    $msgRestart     = "설치 후 새 터미널을 열어 gemini 명령을 사용해 주세요."
} else {
    $msgStart       = "Installing Gemini CLI..."
    $msgAlready     = "Gemini CLI is already installed."
    $msgVersion     = "Installed version:"
    $msgNodeMissing = "Node.js is not installed."
    $msgNodeOld     = "Node.js version is too old (18+ required). Current version:"
    $msgNodeInstall = "Installing Node.js LTS via winget..."
    $msgNoWinget    = "winget is not available. Please install Node.js manually from:"
    $msgInstalling  = "Installing Gemini CLI..."
    $msgDone        = "Installation complete!"
    $msgPathRefresh = "Refreshing PATH..."
    $msgVerifyFail  = "Verification failed. Please open a new terminal and try again."
    $msgRestart     = "After installation, open a new terminal to use the gemini command."
}

Write-Host $msgStart -ForegroundColor Green

# Check if Gemini CLI is already installed
$geminiPath = Get-Command gemini -ErrorAction SilentlyContinue
if ($geminiPath) {
    $currentVer = & gemini --version 2>$null
    Write-Host $msgAlready -ForegroundColor Green
    Write-Host "$msgVersion $currentVer" -ForegroundColor Green
    exit 0
}

# Helper: get Node.js major version number
function Get-NodeMajorVersion {
    $raw = & node --version 2>$null
    if ($raw -match "v(\d+)") {
        return [int]$Matches[1]
    }
    return 0
}

# Check Node.js 18+
$nodeOk = $false
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCmd) {
    $major = Get-NodeMajorVersion
    if ($major -ge 18) {
        $nodeOk = $true
    } else {
        $nodeVer = & node --version 2>$null
        Write-Host "$msgNodeOld $nodeVer" -ForegroundColor Yellow
    }
} else {
    Write-Host $msgNodeMissing -ForegroundColor Yellow
}

# Install Node.js if needed
if (-not $nodeOk) {
    $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
    if ($wingetCmd) {
        Write-Host $msgNodeInstall -ForegroundColor Yellow
        winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -ne 0) {
            Write-Host "winget install failed. Please install Node.js manually:" -ForegroundColor Red
            Write-Host "  https://nodejs.org" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host $msgNoWinget -ForegroundColor Red
        Write-Host "  https://nodejs.org" -ForegroundColor Yellow
        exit 1
    }

    # Refresh PATH after Node.js install
    Write-Host $msgPathRefresh -ForegroundColor Yellow
    $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
}

# Install Gemini CLI
Write-Host $msgInstalling -ForegroundColor Yellow
npm install -g @google/gemini-cli
if ($LASTEXITCODE -ne 0) {
    Write-Host "npm install failed. Please check your internet connection and try again." -ForegroundColor Red
    exit 1
}

# Refresh PATH so gemini is discoverable in the same session
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")

# Verify installation
$geminiCheck = Get-Command gemini -ErrorAction SilentlyContinue
if ($geminiCheck) {
    $installedVer = & gemini --version 2>$null
    Write-Host $msgDone -ForegroundColor Green
    Write-Host "$msgVersion $installedVer" -ForegroundColor Green
} else {
    Write-Host $msgVerifyFail -ForegroundColor Yellow
    Write-Host $msgRestart -ForegroundColor Yellow
}
