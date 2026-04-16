# Setup-AI

[English](#english) | [한국어](#한국어)

---

## English

### Overview

Setup-AI provides simple installation scripts for popular AI services. No development experience required — just run the script and follow the prompts.

### Features

- Supports **English** and **Korean** — auto-detected from system locale or manually selectable
- Individual install scripts per service, or install everything at once via orchestration script

### Supported Platforms

| Platform | Script | Shell |
|----------|--------|-------|
| macOS | `.sh` | Bash / Zsh |
| Linux | `.sh` | Bash |
| Windows | `.ps1` | PowerShell |

### Supported AI Services

| Service | Description |
|---------|-------------|
| [Claude Desktop](https://claude.ai) | Anthropic's AI assistant desktop app |
| [ChatGPT / Codex](https://openai.com) | OpenAI's AI assistant and coding agent |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | Google's AI assistant for the terminal |
| [Ollama](https://ollama.com) | Run open-source LLMs locally |

### Usage

**Install everything at once:**

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/chordpli/Setup-AI/main/setup.sh | bash

# Windows (PowerShell)
irm https://raw.githubusercontent.com/chordpli/Setup-AI/main/setup.ps1 | iex
```

**Install a specific service:**

```bash
# macOS / Linux
./scripts/install-ollama.sh

# Windows (PowerShell)
.\scripts\install-ollama.ps1
```

### Project Structure

```
Setup-AI/
├── setup.sh                # Orchestration script (macOS/Linux)
├── setup.ps1               # Orchestration script (Windows)
└── scripts/
    ├── claude-desktop/
    │   ├── install.sh      # macOS / Linux
    │   └── install.ps1     # Windows
    ├── chatgpt-codex/
    │   ├── install.sh
    │   └── install.ps1
    ├── gemini-cli/
    │   ├── install.sh
    │   └── install.ps1
    └── ollama/
        ├── install.sh
        └── install.ps1
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
- 서비스별 개별 설치 스크립트 제공, 오케스트레이션 스크립트로 전체 설치도 가능

### 지원 플랫폼

| 플랫폼 | 스크립트 | 쉘 |
|--------|----------|-----|
| macOS | `.sh` | Bash / Zsh |
| Linux | `.sh` | Bash |
| Windows | `.ps1` | PowerShell |

### 지원 AI 서비스

| 서비스 | 설명 |
|--------|------|
| [Claude Desktop](https://claude.ai) | Anthropic의 AI 어시스턴트 데스크탑 앱 |
| [ChatGPT / Codex](https://openai.com) | OpenAI의 AI 어시스턴트 및 코딩 에이전트 |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | Google의 터미널용 AI 어시스턴트 |
| [Ollama](https://ollama.com) | 오픈소스 LLM을 로컬에서 실행 |

### 사용법

**모든 서비스 한 번에 설치:**

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/chordpli/Setup-AI/main/setup.sh | bash

# Windows (PowerShell)
irm https://raw.githubusercontent.com/chordpli/Setup-AI/main/setup.ps1 | iex
```

**개별 서비스 설치:**

```bash
# macOS / Linux
./scripts/install-ollama.sh

# Windows (PowerShell)
.\scripts\install-ollama.ps1
```

### 프로젝트 구조

```
Setup-AI/
├── setup.sh                # 오케스트레이션 스크립트 (macOS/Linux)
├── setup.ps1               # 오케스트레이션 스크립트 (Windows)
└── scripts/
    ├── claude-desktop/
    │   ├── install.sh      # macOS / Linux
    │   └── install.ps1     # Windows
    ├── chatgpt-codex/
    │   ├── install.sh
    │   └── install.ps1
    ├── gemini-cli/
    │   ├── install.sh
    │   └── install.ps1
    └── ollama/
        ├── install.sh
        └── install.ps1
```

### 기여하기

기여를 환영합니다! 이슈를 등록하거나 풀 리퀘스트를 보내주세요.

### 라이선스

[MIT](LICENSE)
