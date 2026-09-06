# PSA Academy V2 — Staging Release Report & Remote Audit

**Execution Date**: September 6, 2026  
**Target Environment**: Staging (`psa-academy-staging`)  
**Release Candidate 1 Tag**: `psa-academy-v2-web-rc1` (commit `41e87f0`)  
**Release Candidate 2 Tag**: `psa-academy-v2-web-rc2` (commit `f77e9cc`)  
**Current Branch**: `main` (commit `f77e9cc`)  
**Preserved Feature Branch**: `feature/psa-academy-v2` (commit `2020745`)  

---

## 1. Executive Summary & Verdict

### Final Verdict: `STAGING SETUP BLOCKED`

The codebase and hosting configuration have been elevated to **Release Candidate 2 (`psa-academy-v2-web-rc2`)** with a unified, production-grade **HTML5 Path URL Strategy**:
- Eliminated legacy mixed path + hash routing (`/admin#/login`).
- All routes now resolve cleanly as pure paths (`/login`, `/admin`, `/coach`, `/player`).
- Real hosted browser routing verified across Google Chrome and Microsoft Edge with zero console errors.
- Full test suite passing: **40/40 Flutter tests** and **45/45 Firebase Emulator tests** (85/85 automated tests total).
- New release candidate tag `psa-academy-v2-web-rc2` published to GitHub without rewriting existing RC1 history.

### Crucial Project Clarification & Operational Blocker
API diagnostics revealed that Authentication and Storage were activated on the **Production project (`psa-academy-65088`)** rather than the dedicated **Staging project (`psa-academy-staging`)**:
- `psa-academy-65088` (Production): Auth and Storage are already active.
- `psa-academy-staging` (Staging): Storage reports `0 buckets` and Auth reports `CONFIGURATION_NOT_FOUND`.

To safeguard production from test data contamination, testing is paused until the user accesses the **`psa-academy-staging`** project in the Firebase Console and activates Storage and Auth.

---

## 2. Release & Remote State Matrix

| Component | Status | Details |
| :--- | :---: | :--- |
| **Local `main` HEAD** | `f77e9cc` | Includes clean path routing engine and updated pubspec |
| **Feature Branch** | `2020745` | Preserved intact at `feature/psa-academy-v2` |
| **Working Tree** | Clean | `nothing to commit, working tree clean` |
| **GitHub Remote Status** | **CONFIGURED & PUSHED** | `origin = https://github.com/noaman03/psa-academy.git` |
| **Origin Repository URL** | [https://github.com/noaman03/psa-academy](https://github.com/noaman03/psa-academy) | Official V2 repository |
| **Remote `main` HEAD** | `f77e9cc` | Verified via `git ls-remote origin` (Exact match) |
| **Remote Feature HEAD** | `2020745` | Verified via `git ls-remote origin` (Exact match) |
| **Published RC1 Tag** | `psa-academy-v2-web-rc1` | Published at `41e87f0` |
| **Published RC2 Tag** | `psa-academy-v2-web-rc2` | Published at `f77e9cc` |
| **Secret Audit Result** | **PASSED** | 0 private keys, 0 service account JSONs, 0 FCM keys, 0 `.env` secrets |

---

## 3. Clean Path URL Routing Architecture (RC2)

Per user directive, mixed routing was eliminated by standardizing on pure HTML5 Path URL Strategy:

* **Implementation**: Added cross-platform `configureAppUrlStrategy()` via `flutter_web_plugins/url_strategy.dart` with conditional compilation stubs for native platforms.
* **Hosting Configuration**: Wildcard rewrite rule in `firebase.json`:
  ```json
  "rewrites": [
    {
      "source": "**",
      "destination": "/index.html"
    }
  ]
  ```

### Real Browser Verification Results (Chrome & Edge)
| URL Tested | HTTP Status | Resolved Browser URL | Visual Behavior | Status |
| :--- | :---: | :--- | :--- | :---: |
| `https://psa-academy-staging.web.app/` | 200 | `https://psa-academy-staging.web.app/login` | Clean Login Screen | **PASS** |
| `https://psa-academy-staging.web.app/admin` | 200 | `https://psa-academy-staging.web.app/login` | Route Guard Redirect | **PASS** |
| `https://psa-academy-staging.web.app/coach` | 200 | `https://psa-academy-staging.web.app/login` | Route Guard Redirect | **PASS** |
| `https://psa-academy-staging.web.app/player` | 200 | `https://psa-academy-staging.web.app/login` | Route Guard Redirect | **PASS** |
| Reload on `/admin` | 200 | `https://psa-academy-staging.web.app/login` | Seamless Refresh | **PASS** |
| Microsoft Edge Landing | 200 | `https://psa-academy-staging.web.app/login` | Seamless Rendering | **PASS** |
| Console Errors | N/A | **0 errors logged** | Zero 404s, Zero `#` | **PASS** |

---

## 4. Staging Services & Deployment Status

| Service | Target File | Environment Status | Details |
| :--- | :--- | :---: | :--- |
| **Cloud Firestore Rules** | `firestore.rules` | **DEPLOYED** | Active on `psa-academy-staging` |
| **Firestore Indexes** | `firestore.indexes.json` | **DEPLOYED** | Active on `psa-academy-staging` |
| **Firebase Hosting** | `build/web` | **DEPLOYED** | Live with RC2 bundle at [https://psa-academy-staging.web.app](https://psa-academy-staging.web.app) |
| **HTML5 Path Routing** | `firebase.json` | **ACTIVE** | Pure path routing without hashes |
| **Cloud Storage Rules** | `storage.rules` | **BLOCKED** | Staging bucket not provisioned yet |
| **Firebase Authentication** | Auth Service | **BLOCKED** | Identity Platform not initialized on staging |

---

## 5. How to Unblock Staging in 60 Seconds

The Firebase Console opened by default on the production project `PSA academy` (`psa-academy-65088`). To activate the staging project instead:

1. Click directly on: **[Firebase Storage Console for Staging](https://console.firebase.google.com/project/psa-academy-staging/storage)**  
   → Click **Get Started** → Select location (e.g. `us-central1`) → Done.
2. Click directly on: **[Firebase Authentication Console for Staging](https://console.firebase.google.com/project/psa-academy-staging/authentication)**  
   → Click **Get Started** → Under **Sign-in method**, click **Email/Password** and enable it.

Once activated on `psa-academy-staging`, the automated seed script (`scripts/seed_staging.js`) and live browser acceptance tests will execute immediately.

---

## 6. Defect & Issue Summary

* **Critical Issues**: 0
* **High Issues**: 0
* **Medium Issues**: 0
* **Remaining Bugs**: 0
* **Operational Blockers**: 1 (Need staging console activation rather than production)

**Verdict**: `STAGING SETUP BLOCKED` (Awaiting Staging Project Console Activation).
