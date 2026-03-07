<div align="center">

# Project Management Platform

**A full-stack project management platform with role-based access, task assignment, file deliverables, and developer payment workflow.**

Built with **FastAPI** + **Flutter** + **PostgreSQL** + **Docker**

[![Python](https://img.shields.io/badge/Python-3.11-3776AB?logo=python&logoColor=white)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.128-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.11-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.11-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?logo=postgresql&logoColor=white)](https://postgresql.org)
[![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)](https://docker.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-3.2-blue)](https://riverpod.dev)

</div>

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App (Dart)                      │
│            Riverpod (State) + GoRouter (Navigation)              │
│         Dio (HTTP) + FlutterSecureStorage (Token Storage)        │
└──────────────────────────┬──────────────────────────────────────┘
                           │ REST API + JWT Bearer
                           ▼
┌──────────────────────────────────────────────────────────────────┐
│                     FastAPI Backend (Python)                       │
│                                                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │   Auth   │  │ Projects │  │  Tasks   │  │    Payments      │  │
│  │  (JWT)   │  │  (CRUD)  │  │ (Assign) │  │  (Per Task)      │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └───────┬──────────┘  │
│       │              │              │                │             │
│       ▼              ▼              ▼                ▼             │
│  ┌─────────────────────────────┐  ┌──────────────────────────┐    │
│  │   SQLAlchemy + psycopg2     │  │   File Upload Storage    │    │
│  │     (PostgreSQL 16)         │  │   (Local Volume Mount)   │    │
│  └─────────────────────────────┘  └──────────────────────────┘    │
└──────────────────────────────────────────────────────────────────┘
```

### Request Flow

```
Flutter App ──► Dio HTTP Client (auto token attachment)
                        │
                        ▼
                FastAPI endpoint
                        │
                ┌───────┴───────┐
                ▼               ▼
          Role guard        Service layer
        (dependency)      (business logic)
                               │
                         ┌─────┴─────┐
                         ▼           ▼
                    PostgreSQL    File System
                   (SQLAlchemy)  (uploads volume)
```

### Auth Flow

```
Register ──► POST /auth/register ──► User created with hashed password
Login    ──► POST /auth/login    ──► JWT access token (60min)
                                      stored in FlutterSecureStorage

API call ──► Bearer token in header ──► 401? ──► redirect to login
```

---

## System Overview

### Role Hierarchy

| Role          | Access                                                                                          |
| ------------- | ----------------------------------------------------------------------------------------------- |
| **Admin**     | View platform statistics (total projects, tasks, payments, revenue, developer hours).           |
| **Buyer**     | Create projects, create & assign tasks to developers, review submissions, process payments.     |
| **Developer** | View assigned tasks, update task status, submit solutions with file uploads, track hours.       |

### Task Lifecycle

```
Buyer creates project
        │
        ▼
Buyer creates task (assigns developer + hourly rate)
        │
        ▼
Developer works on task (todo → in_progress)
        │
        ▼
Developer submits solution (file upload + hours logged → submitted)
        │
        ▼
Buyer reviews submission & processes payment (→ paid)
```

### State Machine

```
Task:    todo ──► in_progress ──► submitted ──► paid
                                (file + hours)  (payment created)

Payment: created ──► completed
```

---

## Tech Stack

| Layer              | Technology                                           |
| ------------------ | ---------------------------------------------------- |
| **API**            | Python 3.11, FastAPI 0.128, Uvicorn                  |
| **ORM**            | SQLAlchemy 2.0 + Pydantic v2                         |
| **Database**       | PostgreSQL 16 (Alpine) via psycopg2                  |
| **Auth**           | python-jose (JWT), bcrypt password hashing            |
| **Frontend**       | Flutter (Dart SDK ^3.11.0)                            |
| **State Mgmt**     | Riverpod (flutter_riverpod ^3.2.1)                   |
| **Routing**        | GoRouter ^17.1.0                                     |
| **HTTP Client**    | Dio ^5.9.2 with interceptors                         |
| **Token Storage**  | FlutterSecureStorage ^10.0.0                         |
| **File Handling**  | file_picker ^10.3.10, path_provider ^2.1.3           |
| **Infra**          | Docker Compose (PostgreSQL + Backend)                |

---

## Quick Start

### Prerequisites

- **Docker Desktop** — [docker.com](https://www.docker.com/products/docker-desktop/) (must be running)
- **Flutter SDK 3.11+** — [flutter.dev](https://flutter.dev/docs/get-started/install)
- **Git** — [git-scm.com](https://git-scm.com/)

### Setup

```bash
# 1. Clone the repository
git clone https://github.com/sabbir-swissmarket/project-management-platform.git
cd project-management-platform

# 2. Start backend services (PostgreSQL + FastAPI)
docker compose up --build -d

# 3. Install Flutter dependencies & run the app
cd flutter-app/project_management
flutter pub get
flutter run
```

### Seed Users

To create default test users (admin, buyer, developer), run:

```bash
docker compose exec backend python -m app.scripts.seed_users
```

This creates:
| Email            | Password | Role      |
|------------------|----------|-----------|
| admin@test.com   | 123456   | admin     |
| buyer@test.com   | 123456   | buyer     |
| dev@test.com     | 123456   | developer |

### Services

| Service          | URL                         |
| ---------------- | --------------------------- |
| **Backend API**  | http://localhost:8000       |
| **Swagger UI**   | http://localhost:8000/docs  |
| **PostgreSQL**   | localhost:5432              |

### Environment Variables

| Variable                       | Default                          | Description                  |
| ------------------------------ | -------------------------------- | ---------------------------- |
| `POSTGRES_USER`                | `pm_user`                        | Database username            |
| `POSTGRES_PASSWORD`            | `pm_secure_password_2024`        | Database password            |
| `POSTGRES_DB`                  | `project_management`             | Database name                |
| `SECRET_KEY`                   | *(change in production)*         | JWT signing secret           |
| `ALGORITHM`                    | `HS256`                          | JWT algorithm                |
| `ACCESS_TOKEN_EXPIRE_MINUTES`  | `60`                             | Token expiration time        |

---

## API Routes

### Auth

| Method | Route              | Description                | Access |
| ------ | ------------------ | -------------------------- | ------ |
| POST   | `/auth/register`   | Register a new user        | Public |
| POST   | `/auth/login`      | Login and receive JWT      | Public |

### Projects

| Method | Route                          | Description               | Access |
| ------ | ------------------------------ | ------------------------- | ------ |
| GET    | `/projects`                    | List buyer's projects     | Buyer  |
| POST   | `/projects`                    | Create a new project      | Buyer  |
| GET    | `/projects/{id}/tasks`         | List tasks in project     | Buyer  |

### Tasks

| Method | Route                       | Description                              | Access    |
| ------ | --------------------------- | ---------------------------------------- | --------- |
| POST   | `/tasks`                    | Create task & assign developer           | Buyer     |
| GET    | `/tasks/my-tasks`           | Get developer's assigned tasks           | Developer |
| GET    | `/tasks/{id}`               | Get task details                         | Auth      |
| PATCH  | `/tasks/{id}/status`        | Update task status                       | Developer |
| PATCH  | `/tasks/{id}/submit`        | Submit solution (file + hours)           | Developer |
| GET    | `/tasks/{id}/download`      | Download submitted solution              | Buyer     |

### Payments

| Method | Route                  | Description                  | Access |
| ------ | ---------------------- | ---------------------------- | ------ |
| POST   | `/payments/{task_id}`  | Process payment for task     | Buyer  |

### Admin

| Method | Route           | Description              | Access |
| ------ | --------------- | ------------------------ | ------ |
| GET    | `/admin/stats`  | Platform-wide statistics | Admin  |

### Developers

| Method | Route          | Description          | Access |
| ------ | -------------- | -------------------- | ------ |
| GET    | `/developers`  | List all developers  | Buyer  |

---

## Key Architectural Decisions

### 1. Clean Architecture (Feature-First)

Both frontend and backend follow a clean architecture pattern. The Flutter app is organized by feature modules (`auth`, `buyer`, `developer`, `admin`), each with its own `domain`, `data`, and `presentation` layers. This ensures separation of concerns and makes the codebase scalable.

### 2. Riverpod for State Management

Riverpod was chosen over BLoC or Provider for its compile-time safety, testability, and support for `StateNotifier`. Each feature has dedicated providers that manage state independently, making the app modular and easy to test.

### 3. JWT Stored in Secure Storage

Access tokens are stored in `FlutterSecureStorage`, which uses the platform's secure keychain (iOS Keychain / Android EncryptedSharedPreferences). This prevents token exposure compared to plain shared preferences.

### 4. Dio with Interceptors

Dio handles all HTTP communication with automatic token attachment via interceptors. This keeps API calls clean and ensures every authenticated request includes the JWT header without manual handling.

### 5. Docker Compose for Backend

PostgreSQL and the FastAPI backend run in Docker containers, ensuring consistent environments across development machines. The database auto-initializes on first run, and uploads persist via Docker volumes.

### 6. Role-Based Route Guards

GoRouter uses redirect logic combined with the auth state to enforce role-based navigation. Users are automatically redirected to their role-specific dashboard, preventing unauthorized access at the routing level.

---

## Project Structure

```
backend/
├── app/
│   ├── main.py                    # FastAPI app entry point
│   ├── core/
│   │   ├── config.py              # Environment configuration
│   │   ├── database.py            # SQLAlchemy engine & session
│   │   ├── security.py            # JWT & password hashing
│   │   └── dependencies.py        # Auth & role guard dependencies
│   ├── models/                    # SQLAlchemy ORM models
│   │   ├── user.py                # User (admin, buyer, developer)
│   │   ├── project.py             # Project (title, description, buyer)
│   │   ├── task.py                # Task (assignment, status, solution)
│   │   └── payment.py             # Payment (amount, status)
│   ├── schemas/                   # Pydantic request/response schemas
│   │   ├── user.py                # UserCreate, UserLogin, UserSummary
│   │   ├── project.py             # ProjectCreate
│   │   └── task.py                # TaskCreate
│   ├── routes/                    # API endpoint handlers
│   │   ├── auths.py               # Registration & login
│   │   ├── projects.py            # Project CRUD
│   │   ├── tasks.py               # Task management & file upload
│   │   ├── payments.py            # Payment processing
│   │   ├── admin.py               # Admin statistics
│   │   └── developers.py          # Developer listing
│   └── services/
│       └── task_services.py       # Business logic & status validation
├── requirements.txt               # Python dependencies
├── Dockerfile                     # Container configuration
└── scripts/
    └── seed_users.py              # Database seeding script

flutter-app/project_management/lib/
├── main.dart                      # App entry point
├── core/
│   ├── network/
│   │   ├── api_client.dart        # Dio client with token interceptor
│   │   └── dio_provider.dart      # Dio instance provider
│   ├── storage/
│   │   ├── secure_storage_services.dart  # JWT token persistence
│   │   └── local_storage_service.dart    # Role caching
│   ├── utils/
│   │   └── jwt_decoder.dart       # JWT payload decoding
│   └── router/
│       └── app_router.dart        # GoRouter with role-based guards
└── features/
    ├── auth/                      # Login & registration
    │   ├── domain/                # Auth state & repository interface
    │   ├── data/                  # Auth API implementation
    │   └── presentation/         # Login UI & auth provider
    ├── buyer/                     # Buyer dashboard & project management
    │   ├── domain/                # Buyer repository interface
    │   ├── data/                  # Buyer API implementation
    │   └── presentation/         # Dashboard, project & task pages
    ├── developer/                 # Developer task management
    │   ├── domain/                # Developer repository interface
    │   ├── data/                  # Developer API implementation
    │   └── presentation/         # Dashboard & task submission
    ├── admin/                     # Admin statistics dashboard
    │   ├── domain/                # Stats entities & repository
    │   ├── data/                  # Admin API implementation
    │   └── presentation/         # Stats dashboard & widgets
    └── shared/                    # Shared entities & models
        ├── domain/entities/       # Project, Task, Developer entities
        └── data/models/           # JSON serialization models
```

---

## Testing

```bash
# Run Flutter widget & unit tests
cd flutter-app/project_management
flutter test
```

**Test coverage includes:**

| Test                        | Description                                         |
| --------------------------- | --------------------------------------------------- |
| `login_page_test.dart`      | Form validation, loading states, UI rendering        |
| `developer_notifier_test.dart` | Developer state transitions with fake repository  |
| `buyer_notifier_test.dart`  | Buyer state management with mock data                |
| `admin_dashboard_test.dart` | Statistics display and stat card rendering            |

Tests use fake repository implementations for isolated, deterministic unit testing without network calls.

---

## Database Schema

```
┌──────────────┐       ┌──────────────┐
│    Users     │       │   Projects   │
├──────────────┤       ├──────────────┤
│ id (UUID PK) │◄──┐   │ id (UUID PK) │
│ name         │   │   │ title        │
│ email (UQ)   │   │   │ description  │
│ password_hash│   └───│ buyer_id (FK)│
│ role         │       │ created_at   │
└──────────────┘       └──────┬───────┘
       │                      │
       │                      │
       ▼                      ▼
┌──────────────────┐   ┌──────────────┐
│     Tasks        │   │   Payments   │
├──────────────────┤   ├──────────────┤
│ id (UUID PK)     │   │ id (UUID PK) │
│ project_id (FK)──┼───│ task_id (FK) │
│ title            │   │ buyer_id (FK)│
│ description      │   │ amount       │
│ assigned_dev (FK)│   │ status       │
│ hourly_rate      │   │ paid_at      │
│ status           │   └──────────────┘
│ hours_logged     │
│ solution_file    │
│ created_at       │
└──────────────────┘
```

---

