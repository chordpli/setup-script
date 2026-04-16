# CLAUDE.md

## 프로젝트 개요

비개발자를 위한 AI 서비스 설치 스크립트 프로젝트. macOS/Linux(.sh)와 Windows(.ps1)를 모두 지원한다.

## 프로젝트 구조

```
Setup-AI/
├── setup.sh / setup.ps1          # 오케스트레이션 스크립트
└── scripts/
    ├── claude-desktop/
    ├── chatgpt-codex/
    ├── gemini-cli/
    └── ollama/
        ├── install.sh            # macOS / Linux
        └── install.ps1           # Windows
```

## 크로스 플랫폼 필수 규칙

### 인코딩

| 파일 | 인코딩 | BOM |
|------|--------|-----|
| `.ps1` (한글 포함) | UTF-8 | **필수** — PowerShell 5.1이 BOM 없으면 시스템 인코딩(EUC-KR)으로 읽어 파싱 에러 발생 |
| `.sh` | UTF-8 | **금지** — BOM이 있으면 `#!/bin/bash` shebang을 인식 못함 |
| `.md`, `.json`, `.yaml` | UTF-8 | 불필요 |

BOM 없는 한글 `.ps1` 파일의 대표 증상:
```
식에 닫는 ')'가 없습니다.
문 블록 또는 형식 정의에 닫는 '}'가 없습니다.
```

BOM 추가 방법 (macOS/Linux에서):
```bash
printf '\xEF\xBB\xBF' > file.bom && cat file.ps1 >> file.bom && mv file.bom file.ps1
```

### 줄바꿈

| 파일 | 줄바꿈 | 이유 |
|------|--------|------|
| `.sh` | **LF** | CRLF면 `/bin/bash^M: bad interpreter` 또는 `$'\r'` 에러 |
| `.ps1` | **CRLF** | PowerShell은 LF도 처리하지만 Windows 관례상 CRLF |

`.gitattributes`에 반드시 명시:
```gitattributes
* text=auto
*.sh  text eol=lf
*.ps1 text eol=crlf
*.png binary
*.jpg binary
```

### 경로

- **구분자**: Windows `\`, macOS/Linux `/`
- **대소문자**: Linux만 구분함. macOS에서 되던 import가 Linux CI에서 실패하는 흔한 원인
- **공백 포함 경로**: Windows에서 매우 흔함 (`C:\Users\KIM JEE SEUK\...`) — 모든 경로 변수를 반드시 따옴표로 감쌀 것

주요 경로 매핑:

| 용도 | PowerShell | Bash |
|------|-----------|------|
| 홈 | `$env:USERPROFILE` | `$HOME` |
| 임시 | `$env:TEMP` | `/tmp` |
| 앱 데이터 | `$env:APPDATA` | `$HOME/.config` 또는 `~/Library` (macOS) |
| 프로그램 설치 | `C:\Program Files\` | `/usr/local/bin` 또는 `/opt/homebrew/` (macOS ARM) |
| npm 글로벌 | `$env:APPDATA\npm\` | `/usr/local/lib/node_modules/` |

**OneDrive 주의**: Windows에서 Desktop/Documents가 OneDrive 안에 있으면 경로가 길어지고 파일 잠금/동기화 문제 발생. 프로젝트는 OneDrive 외부에 두도록 안내할 것.

### 셸 문법 차이 (Bash vs PowerShell)

**환경변수:**

| 작업 | Bash | PowerShell |
|------|------|------------|
| 읽기 | `$VAR` | `$env:VAR` |
| 설정 (세션) | `export VAR=value` | `$env:VAR = "value"` |
| 설정 (영구) | `~/.bashrc`에 추가 | `[Environment]::SetEnvironmentVariable("VAR","value","User")` |

**명령 존재 확인:**

| Bash | PowerShell |
|------|------------|
| `command -v node &>/dev/null` | `Get-Command node -ErrorAction SilentlyContinue` |

**종료 코드:**

| | Bash | PowerShell |
|-|------|------------|
| 마지막 명령 | `$?` (0=성공) | `$LASTEXITCODE` |
| 에러 시 중단 | `set -e` | `$ErrorActionPreference = "Stop"` |
| 조건 실행 | `cmd1 && cmd2` | PS 5.1: `; if ($?) { cmd2 }` (PS 7에서만 `&&` 지원) |

**출력 숨기기:**

| | Bash | PowerShell |
|-|------|------------|
| stdout | `> /dev/null` | `\| Out-Null` |
| stderr | `2>/dev/null` | `2>$null` |
| 둘 다 | `&>/dev/null` | `*>$null` |

**PowerShell 5.1 호환 주의**: `&&`, `||` 연산자 사용 금지. Windows 10 기본 탑재가 5.1이므로 반드시 5.1 기준으로 작성.

### 패키지 관리자 매핑

| 도구 | Homebrew (macOS) | winget (Windows) | scoop (Windows) | apt (Linux) |
|------|-----------------|-----------------|-----------------|-------------|
| Node.js | `brew install node` | `winget install OpenJS.NodeJS.LTS` | `scoop install nodejs-lts` | `apt install nodejs` |
| Git | Xcode CLT 포함 | `winget install Git.Git` | `scoop install git` | `apt install git` |
| GitHub CLI | `brew install gh` | `winget install GitHub.cli` | `scoop install gh` | `apt install gh` |

| 특징 | Homebrew | winget | scoop |
|------|----------|--------|-------|
| 관리자 권한 | 불필요 | 일부 필요 | 불필요 |
| 자동 PATH | O | 일부 (재시작 필요) | O |
| 설치 위치 | `/opt/homebrew/` (ARM) | `C:\Program Files\` | `$HOME\scoop\` |

### 실행 권한

| OS | 필요 조건 |
|----|----------|
| macOS / Linux | `chmod +x script.sh` (git에서: `git update-index --chmod=+x setup.sh`) |
| Windows | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |

### PATH 갱신

프로그램 설치 후 PATH가 현재 세션에 즉시 반영되지 않는 문제는 모든 OS에서 발생한다.

**Bash:**
```bash
source ~/.bashrc  # 또는 source ~/.zshrc
```

**PowerShell:**
```powershell
$env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [Environment]::GetEnvironmentVariable("Path","User")
```

**IDE 터미널**: IDE 시작 시점의 PATH를 사용하므로, 설치 후 IDE를 완전히 재시작하거나 위 명령으로 수동 갱신.

## Windows 환경 알려진 이슈

### 1. Claude Code — git-bash 필수

Claude Code on Windows는 git-bash가 필수. PATH에 없으면 동작하지 않는다.

**대응:**
- 설치 스크립트에서 git-bash 존재 여부를 먼저 확인
- 없으면 Git for Windows 설치를 안내하거나 자동 설치
- PATH에 없는 경우 환경변수 설정 안내:
  ```
  CLAUDE_CODE_GIT_BASH_PATH=C:\Program Files\Git\bin\bash.exe
  ```

### 2. PowerShell 실행 정책

Windows 기본 설정에서는 `.ps1` 스크립트 실행이 차단된다.

**대응:**
- 스크립트 시작 시 현재 실행 정책을 확인
- `irm ... | iex` 패턴으로 우회 (README에 반영됨)

### 3. 관리자 권한 (UAC)

일부 설치(winget 등)는 관리자 권한이 필요하다.

**대응:**
```powershell
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "관리자 권한이 필요합니다. PowerShell을 관리자로 다시 실행해주세요."
    exit 1
}
```

### 4. winget 미설치 / 구버전

Windows 10 구버전에서는 winget이 없거나 오래된 버전일 수 있다.

**대응:**
- winget 존재 및 버전 확인 후, 없으면 Microsoft Store 또는 GitHub 릴리스에서 설치 안내
- 폴백: chocolatey / scoop

## 스크립트 작성 규칙

1. **크로스 플랫폼 대응**: 모든 서비스는 `.sh`와 `.ps1`를 쌍으로 제공
2. **비개발자 대상**: 에러 메시지는 한국어/영어 모두 지원, 기술 용어 최소화
3. **방어적 코딩**: 의존성(git-bash, winget, brew 등) 존재 여부를 먼저 확인
4. **멱등성**: 이미 설치된 서비스는 스킵하고 안내
5. **로케일 자동 감지**: 시스템 언어에 따라 한국어/영어 자동 선택

## 스크립트 작성 체크리스트

| 항목 | 확인 |
|------|------|
| `.ps1` 파일에 한글 포함 시 UTF-8 BOM 추가 | |
| `.sh` 파일은 LF 줄바꿈, BOM 없음 | |
| `.gitattributes`에 줄바꿈 규칙 설정 | |
| 모든 경로 변수를 따옴표로 감싸기 | |
| 파일명/import 대소문자 통일 (Linux 대소문자 구분) | |
| 환경변수 접근 방식이 OS별로 다름을 반영 | |
| 프로그램 설치 후 PATH 새로고침 로직 포함 | |
| PowerShell 5.1 호환: `&&` 연산자 사용 금지 | |
| 에러 메시지에 OS별 해결 방법 포함 | |

## 빌드 / 테스트

별도 빌드 없음. 스크립트를 직접 실행하여 테스트.

```bash
# macOS/Linux
bash setup.sh

# Windows (PowerShell)
powershell -ExecutionPolicy Bypass -File setup.ps1
```
