# Catalyst: AI-Powered Algorithmic Decision Contestation Platform

Catalyst is an advanced, transparent algorithmic decision-engine and contestation platform. It is designed to evaluate complex user factors (such as loan applications), return transparent reasoning behind automated decisions, identify localized bias disparities across applicant cohorts, and allow a completely deterministic "What-if" testing suite to explain its behaviors. 

Crucially, Catalyst allows users to **appeal and contest** algorithmic decisions. It incorporates advanced Natural Language Processing (NLP) and forensic Vision AI to verify unstructured textual evidence and uploaded documents securely against predetermined risk-mitigation vectors.

---

## 🌟 Core Features

- **XGBoost Inference Engine:** Handles complex imbalanced classifications based on the "Give Me Some Credit" dataset.
- **SHAP Explainability:** Extracts the exact mathematically impactful factors leading to approvals or denials.
- **Adversarial "What-If" Modeling:** Deterministically calculates the exact baseline values needed to "flip" a decision.
- **Forensic Vision Document Auditing:** Uses Gemini 2.0+ Flash to scan user-uploaded documents (e.g., medical bills, employment letters) for authenticity and relevance to their appeal claims.
- **NLP Semantic Mitigation:** Uses `SentenceTransformers` (`all-MiniLM-L6-v2`) to cross-reference unstructured appeal text against validated mitigation dictionaries, penalizing risk vectors dynamically.
- **Bias Monitoring Tracker:** Logs every decision securely into SQLite to monitor long-term fairness, tracking demographic metrics to ensure the base rate does not systematically disadvantage cohorts.
- **AI Agent Chat:** A built-in advisor (powered by Groq / Llama 3.3 70B) that answers user questions, explains decisions in plain English, and even drafts formal appeal letters.
- **Passwordless Authentication:** Secure Google OAuth combined with Magic Link verification sent via SMTP (Gmail).

---

## 🏗️ Technology Stack

### **Frontend**
- **Framework:** React.js powered by Vite
- **Styling:** Vanilla CSS + custom design tokens
- **Features:** Interactive dashboards, document upload drag-and-drops, SHAP-value visualizations, and Chatbot UI.

### **Backend (`verdictai-backend`)**
- **Web Framework:** FastAPI (Python)
- **Database:** SQLite via `SQLModel` & Pydantic V2
- **Machine Learning Engine:**
  - `xgboost` (Classification)
  - `shap` (Model Explainer)
  - `scikit-learn` & `pandas` (Data pipelines & scaling)
- **Natural Language & Vision AI (`AIBridge`):**
  - `Groq API` (Llama 3.3 70B Versatile for high-speed text generation & chat)
  - `Google Generative AI` (Gemini 2.5 Flash for forensic document auditing)
  - `SentenceTransformers` (Local semantic matching)

---

## ⚙️ Architecture & Data Flow

```text
       [React Frontend UI]
                │
   (REST API / JSON / Form-Data)
                ▼
      [FastAPI Endpoints] ──────────────► [SQLite Bias & Decision Logs]
                │                                    ▲
                ▼                                    │
   ┌──────────────────────────┐                      │
   │   Engine Logic Gateways  │──────────────────────┘
   └──────────────────────────┘
      │         │           │
      ▼         ▼           ▼
  [XGBoost]  [SHAP]   [AI Bridge & NLP]
 (Predict)  (Explain) (Vision Audit & Semantic Mitigation)
```

---

## 🚀 Setup Instructions

### 1. Backend Setup (`verdictai-backend`)
Ensure Python 3.11+ is installed on your system.

```bash
cd Catalyst/verdictai-backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

**Environment Variables:**
Create a `.env` file in the `verdictai-backend` directory with the following keys:
- `GROQ_API_KEY`: Key for Llama 3.3 models.
- `GEMINI_API_KEY`: Key for Vision document analysis.
- `GOOGLE_CLIENT_ID`: OAuth Client ID.
- `GMAIL_APP_PASSWORD` / `GMAIL_USER`: For sending Magic Link authentication emails.

**Start the Server:**
```bash
uvicorn main:app --reload --host 127.0.0.1 --port 8000
```
*Note: On the first startup, Catalyst automatically synthesizes the ~150,000 row dataset, trains the XGBoost model, configures SHAP explainers, downloads the NLP models, and initializes the SQL tables.*

### 2. Frontend Setup
```bash
cd Catalyst
npm install
npm run dev
```
Create a `.env` file in the `Catalyst` root directory with `VITE_GOOGLE_CLIENT_ID` for the frontend login UI.

---

## 📡 Key API Endpoints

### Inference & Explainability
- **`POST /api/decide`**: Runs core predictive routines against applicant data. Returns the decision (`APPROVE` or `DENY`), confidence metrics, SHAP feature factors, and an adversarial gap report detailing how close the user is to flipping the verdict.
- **`GET /api/whatif`**: Rapidly recalculates the decision matrix if specific features are altered deterministically.

### Contestation & Appeals
- **`POST /api/appeal`**: The core contestation pipeline. Takes user evidence documents and text claims.
  1. **Stage 1 (Context Check):** Uses Gemini to verify if the uploaded document directly relates to the stated claim.
  2. **Stage 2 (Authenticity Check):** Uses Gemini to analyze document integrity (looking for tampering, edits).
  3. **Stage 3 (Semantic Match):** Uses `SentenceTransformers` to map the claim to localized risk factors.
  4. **Stage 4 (Recalculation):** Mitigates the risk factor weights inside the XGBoost feature vector and recalculates the final verdict.

### AI Assistance
- **`POST /api/chat`**: Conversational interface using Groq (Llama 3) to explain algorithmic decisions to the user without mathematical jargon.
- **`POST /api/appeal-letter`**: AI drafting assistant that automatically writes professional contestation letters based on the user's rejection reasons.

### Authentication & Telemetry
- **`POST /api/auth/google`**: Validates Google Identity Services JWT tokens securely.
- **`POST /api/auth/send-welcome`**: Dispatches passwordless Magic Link emails via SMTP.
- **`GET /api/bias-report`**: Returns a comprehensive digest of bias metrics securely monitored from the `DecisionLog` and `AppealLog` SQL tables.
