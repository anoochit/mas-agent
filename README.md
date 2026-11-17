# MAS Agent (Multi-Agent System)

A multi-agent AI workspace leveraging Google's **Agent Development Kit (ADK)** on the backend and a modern **Flutter** frontend for interactive, real-time streaming AI workflows.

---

## 🏗️ Architecture Overview

- **`server/`**: Python backend containing Google ADK agents and workflows:
  - `generator`: Content generation agent.
  - `editor`: Content editing and text formatting agent.
  - `multi_agent`: Multi-agent system routing prompts between generator and editor sub-agents.
  - `multi_agent_workflow`: Workflow pipeline executing sequential generator to editor steps.
  - `a2a_expose`: Exposes an agent via the Agent-to-Agent (A2A) protocol server using FastAPI/Uvicorn.
  - `a2a_consume`: Consumes remote A2A agents using ADK's `RemoteA2aAgent`.
- **`app/`**: Flutter cross-platform application (Web, Desktop, Mobile) featuring:
  - Real-time **Server-Sent Events (SSE)** streaming responses.
  - State management powered by **Flutter Riverpod**.
  - Configurable server settings (Server URL, App Name, User ID, Session ID).

---

## 🚀 Quick Start

### 1. Prerequisites

- **Python**: 3.10 or higher with Google ADK installed (`pip install google-adk uvicorn`)
- **Flutter**: 3.13 or higher
- **Gemini API Key**: Set your API key in your environment variables:

  ```bash
  export GEMINI_API_KEY="your-gemini-api-key"
  ```

  *(On Windows PowerShell: `$env:GEMINI_API_KEY="your-gemini-api-key"`)*

---

### 2. Run the ADK Server

Start the main ADK API server with CORS allowed for local development and auto-creation of sessions:

```bash
adk api_server --allow_origins 'regex:http://localhost:.*' --reload_agents --auto_create_session
```

---

### 3. Run the A2A Example (Agent-to-Agent)

#### Step A: Start the A2A Exposed Server

Navigate to the `server/` directory and run the A2A service on port `8001`:

```bash
cd server
uvicorn a2a_expose.agent:a2a_app --host localhost --port 8001
```

When running, the remote A2A agent exposes its card endpoint at `http://localhost:8001/.well-known/agent-card.json`.

#### Step B: Run the A2A Client via CLI

In a separate terminal window, run the consumer agent from the `server/` directory:

```bash
cd server
adk run a2a_consume "use your remote agent to solve 1+1"
```

*(You can also set the App Name to `a2a_consume` in the Flutter web client or query it via the ADK API server).*

---

### 4. Run the Flutter App

Navigate into the `app/` directory and run the Flutter web client:

```bash
cd app
flutter run -d chrome
```

---

## ⚙️ Configuration

In the Flutter application interface, click the **Settings** (⚙️) icon to configure:

- **Server URL**: Default is `http://localhost:8000/run_sse`
- **App Name**: Specify the target agent module (e.g., `multi_agent`, `generator`, `editor`, `multi_agent_workflow`, `a2a_consume`)
- **User ID**: Unique user identifier
- **Session ID**: Custom session identifier (or leave default for auto-session creation)

---

## 🛠️ Project Structure

```text
mas-agent/
├── server/
│   ├── a2a_consume/           # Consumes remote A2A agent via RemoteA2aAgent
│   ├── a2a_expose/            # Exposes an ADK agent via A2A protocol endpoint
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
