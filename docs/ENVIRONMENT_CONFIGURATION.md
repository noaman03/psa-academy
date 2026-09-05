# Environment Configuration & Staging Architecture — PSA Academy V2

**Status:** Production Reference  
**Version:** 2.0.0  
**Last Updated:** 2026-09-05  

---

## 1. Overview & Architecture

PSA Academy V2 implements compile-time and runtime environment isolation across three distinct environments:

1. **Development (`development`)**:
   - Uses local Firebase Emulator Suite (`localhost:9099` Auth, `localhost:8080` Firestore, `localhost:9199` Storage).
   - Project ID: `demo-psa-academy`.
   - Never touches remote Firebase networks or databases.
2. **Staging (`staging`)**:
   - Targets a dedicated non-production Firebase project (e.g. `psa-academy-staging`).
   - Used for pre-release quality assurance, customer acceptance testing, and release gate verification.
3. **Production (`production`)**:
   - Live production Firebase project (`psa-academy-65088`).
   - Protected with production security rules and backup pipelines.

---

## 2. Environment Selection Mechanism

Environment selection is driven by Dart compile-time defines (`--dart-define`) evaluated by `AppEnvironment` in `lib/core/config/app_environment.dart`:

### Running with Local Emulators (Development)
```bash
flutter run -d chrome --dart-define=ENVIRONMENT=development --dart-define=USE_EMULATOR=true
```

### Building for Staging
```bash
flutter build web --release --dart-define=ENVIRONMENT=staging --dart-define=STAGING_PROJECT_ID=psa-academy-staging
```

### Building for Production (Default)
```bash
flutter build web --release
# Or explicitly:
flutter build web --release --dart-define=ENVIRONMENT=production
```

---

## 3. Staging Deployment Status

### Current Assessment:
- **Available Projects in CLI:** `fooddonationapp-7b0cd`, `instgramclone-a113d`, `khayyer-a1bf9`, `padelsystem-b6b67`, `psa-academy-65088 (current production)`.
- **Dedicated Staging Project:** Not yet provisioned on this Firebase account.
- **Status Classification:**  
  $$\text{STAGING DEPLOYMENT BLOCKED BY ENVIRONMENT ACCESS}$$

### Operational Protocol:
Per production release gate guidelines, production Firebase (`psa-academy-65088`) was **NOT** modified or deployed to. All staging behavior, security rules, concurrent transactions, and role journeys are verified against the hermetic local Firebase Emulator Suite with representative staging accounts.
