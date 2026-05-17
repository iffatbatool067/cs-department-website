# 🎓 CS Department Website — DevOps Lab Assignment

> **University Computer Science Department** | End-to-End DevOps Workflow  
> GitHub → Docker → GitHub Actions CI/CD → Render.com (Dev / Staging / Production)

---

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Team Members](#team-members)
3. [Live Environment URLs](#live-environment-urls)
4. [Repository Structure](#repository-structure)
5. [Git Flow Strategy](#git-flow-strategy)
6. [Web Pages](#web-pages)
7. [Docker Setup](#docker-setup)
8. [CI Pipeline](#ci-pipeline)
9. [CD Pipelines](#cd-pipelines)
10. [GitHub Environments & Secrets](#github-environments--secrets)
11. [Branch Protection Rules](#branch-protection-rules)
12. [Local Development](#local-development)

---

## Project Overview

A fully automated DevOps workflow for deploying a 5-page static university department website across three independent environments (Development, Staging/QA, Production) using:

- **GitHub** (Git Flow branching)  
- **Docker** (containerized with Nginx)  
- **GitHub Actions** (CI linting + multi-environment CD)  
- **Render.com** (three separate web services)

---

## Team Members

| # | Name | Roll Number | Role | Page Assigned |
|---|------|-------------|------|---------------|
| 1 | *(Team Lead)* | *(Roll No.)* | DevOps Lead | Home Page (`index.html`) |
| 2 | | | Developer | Courses Page (`courses.html`) |
| 3 | | | Developer | Faculty Page (`faculty.html`) |
| 4 | | | Developer | Admissions Page (`admissions.html`) |
| 5 | | | Developer | Contact Page (`contact.html`) |

> **Group Repository URL:** `https://github.com/<org>/<repo>`

---

## Live Environment URLs

| Environment | Branch | URL |
|-------------|--------|-----|
| 🟢 Production | `main` | `https://cs-dept-prod.onrender.com` |
| 🟡 Staging/QA | `release/*` | `https://cs-dept-staging.onrender.com` |
| 🔵 Development | `develop` | `https://cs-dept-dev.onrender.com` |

---

## Repository Structure

```
cs-department-website/
├── .github/
│   └── workflows/
│       ├── ci.yml            # CI: lint + Docker build (all branches)
│       ├── cd-dev.yml        # CD: Deploy to Development (develop branch)
│       ├── cd-staging.yml    # CD: Deploy to Staging (release/* branches)
│       └── cd-prod.yml       # CD: Deploy to Production (main branch)
├── src/
│   ├── index.html            # Home Page
│   ├── courses.html          # Courses Page
│   ├── faculty.html          # Faculty Page
│   ├── admissions.html       # Admissions Page
│   ├── contact.html          # Contact Page
│   └── assets/
│       ├── css/              # Shared styles (if split out)
│       └── images/           # Static images
├── Dockerfile                # Multi-stage: lint → nginx serve
├── nginx.conf                # Nginx server configuration
├── package.json              # NPM scripts for linting
├── .htmlhintrc               # HTMLHint config
├── .stylelintrc.json         # Stylelint config
├── .gitignore
└── README.md
```

---

## Git Flow Strategy

```
main           ◄── Production (protected, PR only)
  └─ release/v1.0   ◄── Staging/QA (auto-deploys on push)
        └─ develop  ◄── Development (auto-deploys on push)
              ├─ feature/home-page       (Team Lead)
              ├─ feature/courses-page    (Member 2)
              ├─ feature/faculty-page    (Member 3)
              ├─ feature/admissions-page (Member 4)
              └─ feature/contact-page    (Member 5)
```

### Branch Naming Convention
| Branch Type | Pattern | Example |
|-------------|---------|---------|
| Feature | `feature/<page-name>` | `feature/home-page` |
| Release | `release/<version>` | `release/v1.0` |
| Hotfix | `hotfix/<description>` | `hotfix/navbar-fix` |

### Workflow
1. Each developer works on their `feature/*` branch
2. Open Pull Request → `develop` (requires 1 reviewer approval)
3. CI runs automatically on every PR
4. Merge to `develop` → auto-deploys to **Development**
5. Create `release/vX.X` from `develop` → auto-deploys to **Staging/QA**
6. QA passes → Merge `release/vX.X` → `main` → auto-deploys to **Production**

---

## Web Pages

| Page | File | Developer | Content |
|------|------|-----------|---------|
| Home | `index.html` | Team Lead | Overview, mission, highlights, quick-links, news |
| Courses | `courses.html` | Member 2 | Course catalogue, semester schedule, program list |
| Faculty | `faculty.html` | Member 3 | Faculty profiles, designations, office hours |
| Admissions | `admissions.html` | Member 4 | Criteria, deadlines, degree programs, steps |
| Contact | `contact.html` | Member 5 | Contact form, office location, hours |

---

## Docker Setup

### Dockerfile Strategy (Multi-Stage)
```
Stage 1 (linter): node:20-alpine — installs deps, runs HTML/CSS lint
Stage 2 (production): nginx:1.25-alpine — copies static files, serves on port 80
```

### Build & Run Locally
```bash
# Build image
docker build -t cs-dept-website .

# Run container
docker run -d -p 8080:80 --name cs-website cs-dept-website

# View site
open http://localhost:8080

# Stop
docker stop cs-website && docker rm cs-website
```

### Docker Hub Image Tags
| Tag | Description |
|-----|-------------|
| `latest` | Latest production build |
| `prod-<sha>` | Production build by commit SHA |
| `staging` | Latest staging build |
| `staging-<sha>` | Staging build by commit SHA |
| `ci-<sha>` | CI-only build (not pushed) |

---

## CI Pipeline

**File:** `.github/workflows/ci.yml`  
**Triggers:** Push or PR to `develop`, `release/*`, `main`

```
┌─────────────┐     ┌──────────────────┐
│  Job 1:     │────►│  Job 2:          │
│  HTML/CSS   │     │  Docker Build    │
│  Lint       │     │  + Smoke Test    │
└─────────────┘     └──────────────────┘
```

| Step | Tool | Description |
|------|------|-------------|
| HTML Lint | HTMLHint | Validates HTML structure and attributes |
| CSS Lint | Stylelint | Enforces CSS code quality and style |
| Docker Build | Docker Buildx | Builds image, confirms no build errors |
| Smoke Test | curl | Hits `http://localhost:8080/` in container |

---

## CD Pipelines

### Development (`cd-dev.yml`)
- **Trigger:** Push to `develop`
- **Steps:** Lint → Render Deploy → Health Check
- **Target:** `RENDER_DEV_SERVICE_ID`

### Staging/QA (`cd-staging.yml`)
- **Trigger:** Push to `release/*`
- **Steps:** Lint → Docker Build & Push → Render Deploy → QA Smoke Tests (all 5 pages)
- **Target:** `RENDER_STAGING_SERVICE_ID`

### Production (`cd-prod.yml`)
- **Trigger:** Push to `main`
- **Steps:** Lint → Docker Build & Push (`:latest` + `:prod-<sha>`) → Render Deploy → Health Check → Git Release Tag
- **Target:** `RENDER_PROD_SERVICE_ID`
- **Concurrency:** `cancel-in-progress: false` (never interrupt a prod deploy)

---

## GitHub Environments & Secrets

### Environments
Create these in **Settings → Environments**:

| Environment | Protection Rules |
|-------------|-----------------|
| `development` | No restrictions |
| `staging` | 1 reviewer required |
| `production` | 2 reviewers required; only `main` branch |

### Secrets (per environment)
| Secret Name | Description |
|-------------|-------------|
| `RENDER_API_KEY` | Render.com API key (from account settings) |
| `RENDER_DEV_SERVICE_ID` | Render service ID for development |
| `RENDER_STAGING_SERVICE_ID` | Render service ID for staging |
| `RENDER_PROD_SERVICE_ID` | Render service ID for production |
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub access token |

### Variables (per environment)
| Variable | Example Value |
|----------|---------------|
| `RENDER_DEV_URL` | `https://cs-dept-dev.onrender.com` |
| `RENDER_STAGING_URL` | `https://cs-dept-staging.onrender.com` |
| `RENDER_PROD_URL` | `https://cs-dept-prod.onrender.com` |

---

## Branch Protection Rules

Configure in **Settings → Branches** for each protected branch:

### `main` (Production)
- ✅ Require pull request before merging
- ✅ Require 2 approvals
- ✅ Dismiss stale pull request approvals
- ✅ Require status checks to pass (CI workflow)
- ✅ Require linear history
- ✅ Do not allow bypassing above settings

### `develop`
- ✅ Require pull request before merging
- ✅ Require 1 approval
- ✅ Require status checks to pass (CI workflow)

---

## Local Development

### Prerequisites
- Node.js 20+
- Docker Desktop
- Git

### Setup
```bash
# 1. Clone the repository
git clone https://github.com/<org>/<repo>.git
cd <repo>

# 2. Create your feature branch (replace <your-page>)
git checkout develop
git pull origin develop
git checkout -b feature/<your-page>

# 3. Install lint tools
npm install

# 4. Edit your HTML page in src/
# e.g. src/courses.html

# 5. Lint locally before committing
npm run lint

# 6. Build and test in Docker
docker build -t cs-dept-website .
docker run -d -p 8080:80 cs-dept-website
open http://localhost:8080

# 7. Commit and push
git add .
git commit -m "feat: add courses page with semester schedule"
git push origin feature/<your-page>

# 8. Open Pull Request to develop on GitHub
```

### Commit Message Convention
```
feat:  add new feature or page content
fix:   bug fix
style: CSS/formatting change (no logic)
ci:    changes to CI/CD workflows
docs:  documentation update
chore: dependency updates, config
```

---

## Render.com Setup Guide

1. Sign up at [render.com](https://render.com)
2. Create **3 new Web Services** (one per environment)
3. For each service:
   - Connect your GitHub repo
   - Set **Environment** = `Docker`
   - Set **Branch** accordingly (develop / release branch / main)
   - Set **Auto-Deploy** = Yes
4. Copy each service's **Service ID** from the Render dashboard URL
5. Generate a **Render API Key** from Account Settings
6. Add all secrets to GitHub Environments

---

*Documentation maintained by the DevOps Team — CS Department Lab Assignment*
