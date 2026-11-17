# MAS Agent (Multi-Agent System)

A multi-agent AI workspace leveraging Google's **Agent Development Kit (ADK)** on the backend and a modern **Flutter** frontend for interactive, real-time streaming AI workflows.

---

## 🏗️ Architecture Overview

- **`server/`**: Python backend containing Google ADK agents and workflows:
  - `generator`: Content generation agent.
  - `editor`: Content editing and text formatting agent.
  - `multi_agent`: Multi-agent system routing prompts between generator and editor sub-agents.
  - `multi_agent_workflow`: Workflow pipeline executing sequential generator to editor steps.
- **`app/`**: Flutter cross-platform application (Web, Desktop, Mobile) featuring:
  - Real-time **Server-Sent Events (SSE)** streaming responses.
  - State management powered by **Flutter Riverpod**.
  - Configurable server settings (Server URL, App Name, User ID, Session ID).

---

## 🚀 Quick Start

### 1. Prerequisites

- **Python**: 3.10 or higher with Google ADK installed (`pip install google-adk`)
- **Flutter**: 3.13 or higher
- **Gemini API Key**: Set your API key in your environment variables:

  ```bash
  export GEMINI_API_KEY="your-gemini-api-key"
  ```

  *(On Windows PowerShell: `$env:GEMINI_API_KEY="your-gemini-api-key"`)*

---

### 2. Run the ADK Server

Start the ADK API server with CORS allowed for local development and auto-creation of sessions:

```bash
adk api_server --allow_origins 'regex:http://localhost:.*' --reload_agents --auto_create_session
```

---

### 3. Run the Flutter App

Navigate into the `app/` directory and run the Flutter web client:

```bash
cd app
flutter run -d chrome
```

---

## ⚙️ Configuration

In the Flutter application interface, click the **Settings** (⚙️) icon to configure:

- **Server URL**: Default is `http://localhost:8000/run_sse`
- **App Name**: Specify the target agent module (e.g., `multi_agent`, `generator`, `editor`, `multi_agent_workflow`)
- **User ID**: Unique user identifier
- **Session ID**: Custom session identifier (or leave default for auto-session creation)

---

## 🛠️ Project Structure

```text
mas-agent/
├── server/
│   ├── editor/                # Editor agent module
│   ├── generator/             # Generator agent module
│   ├── multi_agent/           # Sub-agent hierarchy
│   └── multi_agent_workflow/  # Step-by-step workflow pipeline
└── app/                       # Flutter frontend
    ├── lib/
    │   ├── models/            # Chat message data models
    │   ├── providers/         # Riverpod chat state management
    │   ├── screens/           # Main chat UI screen
    │   ├── services/          # SSE API client service
    │   └── widgets/           # Chat bubbles, input bar, and settings dialog
    └── pubspec.yaml
```
