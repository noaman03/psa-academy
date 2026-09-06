# PSA Academy V2 — Staging Release Report & Remote Audit

**Execution Date**: September 6, 2026  
**Target Environment**: Staging (`psa-academy-staging`)  
**Release Tag**: `psa-academy-v2-web-rc1`  
**Current Branch**: `main` (commit `41e87f0`)  
**Preserved Feature Branch**: `feature/psa-academy-v2` (commit `2020745`)  

---

## 1. Executive Summary & Verdict

### Final Verdict: `STAGING SETUP BLOCKED`

The GitHub remote backup and version control objectives have been **100% completed**:
1. Official GitHub repository created at [https://github.com/noaman03/psa-academy](https://github.com/noaman03/psa-academy).
2. Local `main` (`41e87f0`), `feature/psa-academy-v2` (`2020745`), and release candidate tag `psa-academy-v2-web-rc1` have been pushed with upstream tracking. Remote commit hashes match local commits with zero history rewriting.
3. Dedicated Firebase project `psa-academy-staging` is provisioned and running.
4. Cloud Firestore security rules and composite indexes are deployed to `psa-academy-staging`.
5. Web release application is compiled and deployed live to [https://psa-academy-staging.web.app](https://psa-academy-staging.web.app).
6. Real hosted browser routing acceptance (Google Chrome & Microsoft Edge) passed with 0 errors and zero 404s.

**Operational Gating Factor**:
Progress to the subsequent live browser smoke testing and test user creation is gated solely by one-time web console activation of:
- **Firebase Storage**: Needs clicking "Get Started" in the console to initialize the default bucket before `storage.rules` can be deployed.
- **Firebase Authentication**: Needs clicking "Get Started" and enabling "Email/Password" sign-in provider before staging test users can be registered.

**Zero production systems, databases, rules, or data were touched.**

---

## 2. Release & Remote State Matrix

| Component | Status | Details |
| :--- | :---: | :--- |
| **Local `main` HEAD** | `41e87f0` | Clean descendant of merge commit `ac7890e` with staging configuration |
| **Feature Branch** | `2020745` | Preserved intact at `feature/psa-academy-v2` |
| **Working Tree** | Clean | `nothing to commit, working tree clean` |
| **GitHub Remote Status** | **CONFIGURED & PUSHED** | `origin` configured to `https://github.com/noaman03/psa-academy.git` |
| **Origin Repository URL** | [https://github.com/noaman03/psa-academy](https://github.com/noaman03/psa-academy) | Official V2 repository under `noaman03` |
| **Remote `main` HEAD** | `41e87f0` | Verified via `git ls-remote origin` (Exact match) |
| **Remote Feature HEAD** | `2020745` | Verified via `git ls-remote origin` (Exact match) |
| **Pushed RC Tag** | `psa-academy-v2-web-rc1` | Verified via `git ls-remote origin` pointing to `41e87f0` |
| **Secret Audit Result** | **PASSED** | 0 private keys, 0 service account JSONs, 0 FCM keys, 0 `.env` secrets |

---

## 3. Dedicated Firebase Staging Environment

A completely isolated, dedicated Firebase project was provisioned to eliminate any risk to the production project (`psa-academy-65088`):

* **Staging Project ID**: `psa-academy-staging`
* **Project Number**: `441143149918`
* **Staging Web App ID**: `1:441143149918:web:8adf7625396ff49e8cfbcf`
* **Staging API Key**: `AIzaSyAZGATfJNnu32cNOk7kS5z15f63ofcITpI`
* **Staging Auth Domain**: `psa-academy-staging.firebaseapp.com`
* **Staging Hosting URL**: [https://psa-academy-staging.web.app](https://psa-academy-staging.web.app)
* **Hosting Site Status**: **LIVE & DEPLOYED** (55 release files deployed, SPA rewrites active)

### Project Separation Verification
```text
Production Project: psa-academy-65088 (UNTOUCHED)
Staging Project:    psa-academy-staging (ACTIVE)
```

---

## 4. Staging Rules, Indexes, and Services

| Service | Target File | Deployment Status | Verification Output |
| :--- | :--- | :---: | :--- |
| **Cloud Firestore Rules** | `firestore.rules` | **DEPLOYED** | `released rules firestore.rules to cloud.firestore` |
| **Firestore Indexes** | `firestore.indexes.json` | **DEPLOYED** | `deployed indexes in firestore.indexes.json successfully` |
| **Firebase Hosting** | `build/web` | **DEPLOYED** | Live at [https://psa-academy-staging.web.app](https://psa-academy-staging.web.app) |
| **SPA Routing Rewrites** | `firebase.json` | **VERIFIED** | Deep routes (`/admin`, `/coach`, `/player`) rewrite to `/index.html` |
| **Cloud Storage Rules** | `storage.rules` | **BLOCKED** | Blocked on console setup: `Go to console.firebase.google.com/project/psa-academy-staging/storage and click 'Get Started'` |
| **Firebase Authentication** | Auth Service | **BLOCKED** | Blocked on console setup: Enable Email/Password provider |

---

## 5. Secret & Security Audit

Before initiating the GitHub push, an exhaustive secret scan was conducted across the entire codebase:

1. **Service Accounts & Credentials**:
   - `git ls-files "*service*.json"`: 0 results
   - `git ls-files "*key*" "*pem*" "*secret*"`: 0 results
2. **Private Key Signatures**:
   - Grep search for `BEGIN PRIVATE KEY`: 0 results
   - Grep search for `client_secret`: 0 results
   - Grep search for `service_account`: 0 results
3. **Environment Secrets**:
   - Search for `.env` files: 0 untracked or tracked `.env` secret files
   - `.gitignore` audit: `.env`, `node_modules/`, `build/`, `.firebase/`, `*.log`, `.dart_tool/` are rigorously excluded.

---

## 6. Staging Build & Test Verification

* **Static Analysis**: `flutter analyze` — **0 issues found**
* **Automated Unit & Widget Tests**: `flutter test` — **40/40 tests passed (100%)**
* **Firebase Emulator Suite**: 4 test suites — **45/45 tests passed (100%)**
  - Granular RBAC permissions
  - ACID attendance concurrency stress tests
  - Storage MIME and size limitations
  - Complete End-to-End role acceptance journeys
* **Staging Release Compilation**:
  ```bash
  flutter build web --release --dart-define=ENVIRONMENT=staging
  ```
  Completed with exit code 0 (`√ Built build\web`).

---

## 7. Real Hosted Staging Routing Acceptance (Chrome & Edge)

Automated headless browser routing validation was performed against the live hosted app:

| Route / Action | HTTP Status | Final URL | Browser Engine | Result |
| :--- | :---: | :--- | :---: | :---: |
| Landing `/` | 200 | `https://psa-academy-staging.web.app/#/login` | Chrome & Edge | **PASS** |
| Deep `/admin` | 200 | `https://psa-academy-staging.web.app/admin#/login` | Chrome | **PASS** |
| Deep `/coach` | 200 | `https://psa-academy-staging.web.app/coach#/login` | Chrome | **PASS** |
| Deep `/player` | 200 | `https://psa-academy-staging.web.app/player#/login` | Chrome | **PASS** |
| Browser Reload `/admin` | 304 | `https://psa-academy-staging.web.app/admin#/login` | Chrome | **PASS** |
| Browser Back / Forward | 200 | Session history transitions without crash | Chrome | **PASS** |
| Console / Page Errors | N/A | **0 errors logged** | Chrome & Edge | **PASS** |

---

## 8. Staging Seed Automation & Smoke Test Readiness

A dedicated staging seed script has been prepared at `scripts/seed_staging.js` to automatically create and populate:
1. **Admin**: `staging-admin@psa-academy.test` (`admin` profile)
2. **Coach**: `staging-coach@psa-academy.test` (`coaches` profile with 150 EGP/hr rate)
3. **Active Player**: `staging-player-active@psa-academy.test` (10 paid, 2 attended, 8 remaining)
4. **Zero-Session Player**: `staging-player-zero@psa-academy.test` (5 paid, 5 attended, 0 remaining, overdraft disabled)
5. **Inactive Player**: `staging-player-inactive@psa-academy.test` (deactivated account)
6. Synthetic payments, expenses, attendance, training templates, and coach work sessions.

---

## 9. Action Required to Unblock Final Acceptance

To complete live storage upload, test data seeding, and smoke testing, please perform the two one-time activation clicks:

1. **Storage Console**: Visit [Firebase Storage Console](https://console.firebase.google.com/project/psa-academy-staging/storage) → Click **Get Started** (accept default bucket location).
2. **Auth Console**: Visit [Firebase Authentication Console](https://console.firebase.google.com/project/psa-academy-staging/authentication) → Click **Get Started** → Under **Sign-in method**, enable **Email/Password**.

---

## 10. Defect & Issue Summary

* **Critical Issues**: 0
* **High Issues**: 0
* **Medium Issues**: 0
* **Remaining Bugs**: 0
* **Operational Blockers**: 1 (Firebase Web Console Storage/Auth activation required)

**Verdict**: `STAGING SETUP BLOCKED` (Awaiting Console Activation for Storage & Auth).
