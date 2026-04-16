# Setup-AI

[English](#english) | [한국어](#한국어)

---

## English

### Overview

Setup-AI provides simple installation scripts for popular AI services. No development experience required — just run the script and follow the prompts.

### Features

- Supports **English** and **Korean** — auto-detected from system locale or manually selectable
- Individual install scripts per service — just copy, paste, and run

### Supported Platforms

| Platform | Script | Shell |
|----------|--------|-------|
| macOS | `.sh` | Bash / Zsh |
| Linux | `.sh` | Bash |
| Windows | `.ps1` | PowerShell |

### Supported AI Services

| Service | Description |
|---------|-------------|
| [Claude Code](https://claude.ai) | Anthropic's AI coding assistant |
| [ChatGPT / Codex](https://openai.com) | OpenAI's AI assistant and coding agent |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | Google's AI assistant for the terminal |
| [iTerm2](https://iterm2.com) | Terminal emulator for macOS with shell integration |

### Quick Install

Copy and paste the command for the service you want. No downloads or setup needed.

**Claude Code:**

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/chordpli/Setup-AI/main/scripts/claude-code/install.sh | bash
```

```powershell
# Windows (PowerShell)
irm https://raw.githubusercontent.com/chordpli/Setup-AI/main/scripts/claude-code/install.ps1 | iex
```

**ChatGPT / Codex:**

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/chordpli/Setup-AI/main/scripts/chatgpt-codex/install.sh | bash
```

```powershell
# Windows (PowerShell)
irm https://raw.githubusercontent.com/chordpli/Setup-AI/main/scripts/chatgpt-codex/install.ps1 | iex
```

**Gemini CLI:**

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/chordpli/Setup-AI/main/scripts/gemini-cli/install.sh | bash
```

```powershell
# Windows (PowerShell)
irm https://raw.githubusercontent.com/chordpli/Setup-AI/main/scripts/gemini-cli/install.ps1 | iex
```

**iTerm2** (macOS only):

```bash
curl -fsSL https://raw.githubusercontent.com/chordpli/Setup-AI/main/scripts/iterm/install.sh | bash
```

### Project Structure

```
Setup-AI/
└── scripts/
    ├── claude-code/
    │   ├── install.sh      # macOS / Linux
    │   └── install.ps1     # Windows
    ├── chatgpt-codex/
    │   ├── install.sh
    │   └── install.ps1
    ├── gemini-cli/
    │   ├── install.sh
    │   └── install.ps1
    └── iterm/
        └── install.sh      # macOS only
```

### Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

### License

[MIT](LICENSE)

---

## 한국어

### 개요

Setup-AI는 주요 AI 서비스를 간편하게 설치할 수 있는 스크립트를 제공합니다. 개발 경험이 없어도 스크립트를 실행하고 안내를 따르기만 하면 됩니다.

### 주요 기능

- **한국어**와 **영어** 지원 — 시스템 로케일 자동 감지 또는 수동 선택
- 서비스별 개별 설치 스크립트 제공 — 복사, 붙여넣기, 실행만 하면 끝

### 지원 플랫폼

| 플랫폼 | 스크립트 | 쉘 |
|--------|----------|-----|
| macOS | `.sh` | Bash / Zsh |
| Linux | `.sh` | Bash |
| Windows | `.ps1` | PowerShell |

### 지원 AI 서비스

| 서비스 | 설명 |
|--------|------|
| [Claude Code](https://claude.ai) | Anthropic의 AI 코딩 어시스턴트 |
| [ChatGPT / Codex](https://openai.com) | OpenAI의 AI 어시스턴트 및 코딩 에이전트 |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | Google의 터미널용 AI 어시스턴트 |
| [iTerm2](https://iterm2.com) | macOS용 터미널 에뮬레이터 (Shell Integration 포함) |

### 간편 설치

원하는 서비스의 명령어를 복사해서 터미널에 붙여넣기만 하면 됩니다. 별도의 다운로드나 설정이 필요 없습니다.

**Claude Code:**

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/chordpli/Setup-AI/main/scripts/claude-code/install.sh | bash
```

```powershell
# Windows (PowerShell)
irm https://raw.githubusercontent.com/chordpli/Setup-AI/main/scripts/claude-code/install.ps1 | iex
```

**ChatGPT / Codex:**

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/chordpli/Setup-AI/main/scripts/chatgpt-codex/install.sh | bash
```

```powershell
# Windows (PowerShell)
irm https://raw.githubusercontent.com/chordpli/Setup-AI/main/scripts/chatgpt-codex/install.ps1 | iex
```

**Gemini CLI:**

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/chordpli/Setup-AI/main/scripts/gemini-cli/install.sh | bash
```

```powershell
# Windows (PowerShell)
irm https://raw.githubusercontent.com/chordpli/Setup-AI/main/scripts/gemini-cli/install.ps1 | iex
```

**iTerm2** (macOS 전용):

```bash
curl -fsSL https://raw.githubusercontent.com/chordpli/Setup-AI/main/scripts/iterm/install.sh | bash
```

### 프로젝트 구조

```
Setup-AI/
└── scripts/
    ├── claude-code/
    │   ├── install.sh      # macOS / Linux
    │   └── install.ps1     # Windows
    ├── chatgpt-codex/
    │   ├── install.sh
    │   └── install.ps1
    ├── gemini-cli/
    │   ├── install.sh
    │   └── install.ps1
    └── iterm/
        └── install.sh      # macOS only
```

### 기여하기

기여를 환영합니다! 이슈를 등록하거나 풀 리퀘스트를 보내주세요.

### 라이선스

[MIT](LICENSE)
