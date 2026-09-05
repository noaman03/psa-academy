# Production Deployment Checklist — PSA Academy V2

**Status:** Official Release Gate Runbook  
**Target Environment:** Production (`psa-academy-65088`)  
**Prerequisite:** Full approval from Project Owner to merge `feature/psa-academy-v2`  

---

## Pre-Deployment Gate Conditions
Before beginning deployment, ensure:
- [x] Working tree clean on `feature/psa-academy-v2`
- [x] `flutter analyze` passes with 0 issues
- [x] `flutter test` passes 100% (40/40 tests)
- [x] Firebase emulator test suite passes 100% (45/45 tests)
- [x] Release web bundle builds cleanly (`flutter build web --release`)
- [x] Authoritative schema documentation reviewed (`docs/FIRESTORE_SCHEMA_V2.md`)

---

## 13-Step Production Deployment Sequence

### Step 1: Backup Firestore Database
Perform a full snapshot export of production Firestore to a Cloud Storage bucket before any changes.
```bash
gcloud firestore export gs://psa-academy-backups/pre-v2-$(date +%Y%m%d%H%M%S) --project=psa-academy-65088
```
- [ ] Export completed and verified in Google Cloud Console.

### Step 2: Verify Target Firebase Project
Confirm that Firebase CLI is authenticated and active for the production project:
```bash
firebase use psa-academy-65088
```
- [ ] Active project confirmed: `psa-academy-65088`.

### Step 3: Verify Environment Configuration
Confirm compile-time environment flags in `lib/core/config/app_environment.dart`:
- `Environment.production` active by default.
- [ ] Verified `useEmulator = false` and `projectId = 'psa-academy-65088'`.

### Step 4: Execute & Review Migration Dry-Run
Run the migration utility in safe simulation mode (zero writes) to inspect legacy fields and anomalies:
```dart
final migration = getIt<FirestoreV2Migration>();
final summary = await migration.runAllMigrations(dryRun: true);
print(summary.toString());
```
- [ ] Dry-run output reviewed; zero unhandled errors.

### Step 5: Deploy Firestore Composite Indexes
Deploy the production composite indexes defined in `firestore.indexes.json`:
```bash
firebase deploy --only firestore:indexes --project=psa-academy-65088
```
- [ ] Index build status: `READY` in Firebase Console.

### Step 6: Deploy Firestore Security Rules
Deploy the hardened, role-isolated security rules:
```bash
firebase deploy --only firestore:rules --project=psa-academy-65088
```
- [ ] Verified active ruleset matches `firestore.rules`.

### Step 7: Deploy Storage Security Rules
Deploy Cloud Storage access rules (< 15MB, MIME validation, folder isolation):
```bash
firebase deploy --only storage --project=psa-academy-65088
```
- [ ] Verified active storage rules match `storage.rules`.

### Step 8: Execute Controlled Migration (If Approved)
Once owner explicitly approves writing normalized V2 schemas:
```dart
final summary = await migration.runAllMigrations(dryRun: false);
// Audit document written to migration_audit/{id}
```
- [ ] Migration audit log verified in Firestore `migration_audit` collection.

### Step 9: Compile Production Web Release
Build the minified production web bundle with tree-shaken icons:
```bash
flutter build web --release --dart-define=ENVIRONMENT=production
```
- [ ] Build outputs generated in `build/web`.

### Step 10: Deploy Firebase Hosting
Deploy web assets to Firebase Hosting:
```bash
firebase deploy --only hosting --project=psa-academy-65088
```
- [ ] Hosting URL live and responding with HTTP 200.

### Step 11: Production Smoke Test
Execute live sanity check across primary roles:
1. **Admin**: Log in -> View dashboard -> Verify player & coach lists -> Record test expense.
2. **Coach**: Log in -> Verify work session clock-in -> View squad roster.
3. **Player**: Log in -> View remaining sessions counter -> View QR code.
- [ ] All smoke tests passed.

### Step 12: Monitor Real-Time Errors
- Monitor Firebase Crashlytics & Google Cloud Error Reporting for 30 minutes post-release.
- [ ] Zero unhandled exceptions detected.

### Step 13: Sign-Off or Trigger Rollback
- If all steps succeed: Mark release complete.
- If critical regressions arise: Follow [`docs/ROLLBACK_PLAN.md`](./ROLLBACK_PLAN.md).
