# EcoFeast 2.0 — Real-Time Food Waste Redistribution Platform
### Autonomous, Multi-Agent Food Rescue Orchestration System

**Status: Production-Ready ✅ (91/91 Tests Passing, CI Integrated)**

**EcoFeast 2.0** is a web-based, agentic platform that tackles food waste by automating the redistribution of surplus food from donors (restaurants, grocery stores, event organizers) to NGOs. 

Evolving from a baseline Django web application, EcoFeast 2.0 integrates **classical Machine Learning** for freshness prediction, **Generative AI** for unstructured data intake, **RAG** for constraint-based NGO matching, and **LangGraph** for autonomous routing.

---

## 🌟 Key Features

* **Multimodal GenAI Intake:** Donors can submit food listings using a photo (Vision Intake using Groq Llama Vision) or a simple conversational description (Chat Intake using Groq Llama 3 70B). The system extracts structured fields automatically with donor verification.
* **XGBoost Freshness Prediction:** A machine learning model predicts a precise freshness score based on temporal parameters and sensory details (smell, texture, moisture).
* **SHAP Explainability:** Surfaces feature contributions (e.g., storage time, cooking method) explaining *why* the model predicted a freshness score, translated into natural language by an LLM for NGOs.
* **RAG-based NGO Matching:** Combines semantic profiles (dietary restrictions, operating hours, capacity) embedded via SentenceTransformers (`all-MiniLM-L6-v2`) in Qdrant with real-world distance (Haversine formula), capacity, and reliability rankings.
* **LangGraph Multi-Agent Orchestration:** Runs an autonomous pipeline of specialized agents (Intake, Verification, Matching, Logistics) with conditional routing and self-loop escalations to re-route offers if an NGO times out or rejects the assignment.
* **Observability Dashboard:** A real-time monitoring dashboard displaying pipeline status distributions, agent performance charts, and step-by-step decision trails.

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      OBSERVABILITY DASHBOARD                    │
│           (Django Templates + Chart.js Pipeline Auditing)       │
└────────────────────────────────┬────────────────────────────────┘
                                 │
┌────────────────────────────────▼────────────────────────────────┐
│             LANGGRAPH MULTI-AGENT STATE MACHINE                 │
│  [Intake Agent] ──► [Verify Agent] ──► [Match] ──► [Logistics]  │
└───────┬────────────────────┬─────────────┬─────────────▲────────┘
        │                    │             │             │
┌───────▼───────┐    ┌───────▼───────┐     │     ┌───────┴────────┐
│   ML LAYER    │    │  GENAI LAYER  │     │     │   RAG LAYER    │
│  XGBoost +    │    │ Llama Vision  │     │     │  SentenceTrans │
│  SHAP Engine  │    │ + JSON Mode   │     │     │   + Qdrant     │
└───────────────┘    └───────────────┘     │     └────────────────┘
                                           │
┌──────────────────────────────────────────▼──────────────────────┐
│                  DJANGO REST API + POSTGRESQL                   │
│          (Data Persistence, User Auth, and API Routing)         │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📁 Repository Structure

```bash
EcoFeast/
├── config/             # Django project configuration
├── donations/          # Core donation models, serializers, and views
├── users/              # Custom user roles (Donors/NGOs) and capability profiles
├── ml_service/         # Feature engineering, XGBoost training, and SHAP explainability
├── genai_service/      # LLM-based image/text information extraction (Groq Llama)
├── rag_service/        # Qdrant NGO profile embeddings and weighted matching
├── agents/             # LangGraph state definition and autonomous agent node handlers
├── templates/          # HTML templates (Dashboard, Maps, and Agent Observability)
├── tests/              # Pytest test suite for ML, GenAI, RAG, and Agents (91 tests)
├── test_evidence/      # Automated & manual test evidence screenshots and logs
├── EcoFeast_Testing_Report_Template.md # Full QA & independent ML evaluation report
├── EcoFeast_2.0_Updated_Roadmap.md     # Architecture roadmap & implementation guide
├── start_docker.bat    # Windows 1-click Docker startup script
├── start_local.bat     # Windows 1-click Local dev startup script
├── uv.lock             # Deterministic dependency lockfile
├── requirements.txt    # Production & testing dependencies
├── Dockerfile          # Production web service Dockerfile
└── docker-compose.yml  # Multi-service stack (Django, Postgres, Redis, Qdrant)
```

---

## 🚀 Getting Started

### Prerequisites
* **Docker & Docker Compose** (for containerized setup)
* **Python 3.11+ / 3.13** (if running locally without Docker)
* **[uv](https://github.com/astral-sh/uv)** (recommended for fast local Python dependency management)
* A **[Groq API Key](https://console.groq.com/)** for GenAI vision and chat intake features

---

### Windows Quick Start (1-Click Batch Scripts)

- **Docker Environment**: Double-click or run [`start_docker.bat`](./start_docker.bat)
  - Automatically verifies Docker Desktop is running.
  - Builds and starts all background services (`db`, `redis`, `qdrant`, `web`).
  - Runs database migrations and populates mock NGO RAG profiles into Qdrant.
- **Local Development**: Double-click or run [`start_local.bat`](./start_local.bat)
  - Ensures dependencies are installed via `uv`.
  - Runs database migrations.
  - Starts the Django development server on `http://localhost:8000`.

---

### Running with Docker (Recommended)

1. **Clone the repository and enter the directory:**
   ```bash
   git clone https://github.com/ShivamKumar-666/EcoFeast.git
   cd EcoFeast
   ```

2. **Configure your `.env` file:**
   Copy the example environment template:
   ```bash
   cp .env.example .env
   ```
   Provide your `GROQ_API_KEY` and adjust database/secret settings as needed.

3. **Build and start the container services:**
   ```bash
   docker-compose up --build -d
   ```
   This spins up:
   * **Django Web Server** at `http://localhost:8000`
   * **PostgreSQL Database** at `localhost:5432`
   * **Redis Cache/Broker** at `localhost:6379`
   * **Qdrant Vector DB** at `localhost:6333`

4. **Run migrations and populate mock NGO profiles:**
   ```bash
   docker-compose exec web python manage.py migrate
   docker-compose exec web python manage.py shell -c "from rag_service.matcher import sync_all_ngos; sync_all_ngos()"
   ```

---

### Running Locally (Without Docker)

1. **Clone the repository and navigate into the directory:**
   ```bash
   git clone https://github.com/ShivamKumar-666/EcoFeast.git
   cd EcoFeast
   ```

2. **Create and activate a virtual environment:**
   Using `uv` (recommended):
   ```bash
   uv venv
   # On Windows:
   .venv\Scripts\activate
   # On Linux/macOS:
   source .venv/bin/activate
   ```
   Or using standard `venv`:
   ```bash
   python -m venv venv
   # On Windows:
   venv\Scripts\activate
   # On Linux/macOS:
   source venv/bin/activate
   ```

3. **Install dependencies:**
   ```bash
   uv pip install -r requirements.txt
   # OR with standard pip:
   pip install -r requirements.txt
   ```

4. **Configure `.env` file:**
   Create a `.env` file in the project root based on `.env.example`.

5. **Run migrations and start the development server:**
   ```bash
   python manage.py migrate
   python manage.py runserver
   ```
   Visit `http://localhost:8000` in your browser.

---

## 🧪 Verification & Testing

The project uses `pytest` for unit, integration, and agent state machine testing (**91/91 tests passing**).

**Run tests locally:**
```bash
uv run pytest
# or with an active virtualenv:
pytest
```

**Run tests inside Docker:**
```bash
docker-compose exec web pytest
```

The automated test suite covers:
* **Django Models & Auth:** CustomUser profiles, roles, and Donation constraints.
* **ML Service:** Feature transformation pipelines, XGBoost predictions, and SHAP explainability.
* **GenAI Service:** Llama vision/chat extraction structures and explanation generation.
* **RAG Service:** Qdrant embedding upserts and multi-criteria constraint matcher.
* **Agents:** LangGraph StateGraph state transitions, validation checks, and autonomous escalation loops.

> 📊 **Detailed Quality & Evaluation Report:**
> Comprehensive manual and automated test execution results, E2E Playwright logs, and independent ML validation metrics (Accuracy: 92.5%, ROC-AUC: 0.988, Confusion Matrix, and SHAP plots) are documented in [`EcoFeast_Testing_Report_Template.md`](./EcoFeast_Testing_Report_Template.md).
