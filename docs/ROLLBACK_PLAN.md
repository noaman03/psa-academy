# Production Rollback Plan — PSA Academy V2

**Status:** Authoritative Disaster Recovery Runbook  
**Target Application:** PSA Academy Management System  
**Legacy Stable Baseline:** `main` branch at commit `e9b7b96`  
**Purpose:** Ensure immediate, non-destructive recovery if V2 release encounters critical production defects.  

---

## 1. Rollback Scenarios & Triggers

Trigger a rollback immediately if any of the following occur post-deployment:
1. **Critical Data Degradation**: Inability to record player attendance or corruption of session balances.
2. **Authentication Lockout**: Users across any role (Admin, Coach, Player) unable to authenticate.
3. **Severe Rule Failure**: Pervasive `permission-denied` errors blocking core business workflows.
4. **Hosting Incompatibility**: Web app fails to render or crashes upon startup in mainstream browsers.

---

## 2. Immediate Step-by-Step Rollback Procedure

### 2.1. Firebase Hosting Rollback (< 2 Minutes)
The fastest remediation is rolling back Firebase Hosting to the previous release version via the Firebase Console or CLI:
```bash
# List previous release versions
firebase hosting:releases:list --project=psa-academy-65088

# Rollback to the previous live deployment version (instantaneous CDN switch)
firebase hosting:rollback --project=psa-academy-65088
```
*Effect:* Instantly serves the previous stable frontend build to all users without requiring a rebuild.

---

### 2.2. Security Rules Rollback (< 2 Minutes)
If security rules block legacy client queries, restore the previous baseline rules:
```bash
# Check out legacy rules from main
git checkout main -- firestore.rules storage.rules

# Deploy legacy ruleset
firebase deploy --only firestore:rules,storage --project=psa-academy-65088

# Restore local branch files
git checkout feature/psa-academy-v2 -- firestore.rules storage.rules
```

---

### 2.3. Database Recovery & Schema Backward Compatibility
Because PSA Academy V2 was engineered with strict schema backward compatibility:
1. **Schema Compatibility Guarantee**:
   - V2 models read legacy fields (`sessionPaid`, `paymentBalance`, `uid`) seamlessly via fallback parsers.
   - Legacy models read `sessionsPaid` and `sessionsAttended`.
   - The reconciliation formula $\text{sessionsPaid}_{V2} = \text{sessionsPaid}_{legacy} + \text{sessionsAttended}_{legacy}$ preserves remaining sessions accurately.
2. **Full Snapshot Database Restoration (If Disaster Occurred)**:
   If data was corrupted, restore from the Cloud Storage backup created in Step 1 of the Deployment Checklist:
   ```bash
   gcloud firestore import gs://psa-academy-backups/pre-v2-YYYYMMDDHHMMSS --project=psa-academy-65088
   ```

---

### 2.4. Git Source Code Recovery
If `feature/psa-academy-v2` had been merged into `main`, revert the merge commit cleanly:
```bash
git checkout main
git revert -m 1 <MERGE_COMMIT_HASH>
git push origin main
```
*Note:* The baseline legacy codebase at `e9b7b96` remains intact, verified, and tagged.

---

## 3. Post-Rollback Verification
1. Verify legacy web app loads and authenticates users.
2. Verify coaches can log attendance.
3. Verify remaining session calculations match expected balances.
4. Convene post-mortem to analyze error telemetry before scheduling re-release.
