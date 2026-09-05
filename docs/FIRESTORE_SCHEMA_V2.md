# Firestore Schema Specification — PSA Academy V2

**Status:** Authoritative Production Reference  
**Version:** 2.0.0  
**Last Updated:** 2026-09-05  

---

## 1. Architectural Philosophy & Principles

PSA Academy V2 standardizes all database schemas on a strictly typed, relational-document hybrid Firestore model. The architecture enforces:

1. **Explicit Role Separation & Zero Plaintext Secrets**: Auth credentials and passwords reside exclusively within Firebase Authentication (`auth.uid`). No plain-text passwords or authentication tokens are ever stored in Firestore documents.
2. **Cumulative Lifetime Session Accounting**:
   - `sessionsPaid`: Cumulative lifetime count of prepaid sessions purchased.
   - `sessionsAttended`: Cumulative lifetime count of sessions actually attended.
   - `remainingSessions`: Deterministically computed on client as:
     $$\text{remainingSessions} = \text{sessionsPaid} - \text{sessionsAttended}$$
   - When attendance is logged, `sessionsAttended` is incremented by `+1` inside an ACID Firestore transaction. `sessionsPaid` remains unchanged upon check-in.
3. **Auditability & Traceability**: All financial mutations (`payments`, `expenses`) and attendance records are append-only historical records.
4. **Idempotency & Concurrency Safety**: Attendance transactions verify duplicate check-ins within a 15-minute sliding window and enforce active account authorization before recording attendance.

---

## 2. Collections Specification

### 2.1. `users`
Master user directory linking Firebase Auth UIDs to system roles.

- **Document ID**: `auth.uid` (Firebase Authentication User ID)
- **Security**: Authenticated user can read their own document; Admins have read/write access.

| Field | Type | Required | Description | Constraints |
| :--- | :--- | :--- | :--- | :--- |
| `name` | `string` | Yes | Full display name | Min 1 char |
| `email` | `string` | Yes | Primary email address | Valid email format |
| `role` | `string` | Yes | User authorization level | `'admin'` \| `'coach'` \| `'player'` |
| `createdAt` | `timestamp` | Yes | Account creation timestamp | Server timestamp |
| `updatedAt` | `timestamp` | No | Last profile modification | Timestamp |

---

### 2.2. `players`
Player profiles, athletic classifications, and session balances.

- **Document ID**: Unique Player ID (`auth.uid` or assigned doc ID)
- **Security**: Players can read their own profile; Coaches can read all active players; Admins have read/write access.

| Field | Type | Required | Description | Constraints |
| :--- | :--- | :--- | :--- | :--- |
| `userId` | `string` | Yes | References `users/{userId}` | Non-empty string |
| `name` | `string` | Yes | Player full name | Non-empty string |
| `email` | `string` | Yes | Contact email | Valid email |
| `phone` | `string` | No | Player mobile phone | E.164 or local format |
| `level` | `string` | Yes | Skill classification | `'Beginner'` \| `'Intermediate'` \| `'Advanced'` \| `'Professional'` |
| `category` | `string` | Yes | Age / Division | `'Junior'` \| `'Senior'` \| `'Elite'` |
| `ageGroup` | `string` | Yes | Bracket group | e.g. `'Under 8'`, `'Under 10'`, `'Under 12'` |
| `sessionsPaid` | `integer` | Yes | Lifetime prepaid sessions | $\ge 0$ |
| `sessionsAttended` | `integer` | Yes | Lifetime attended sessions | $\ge 0$ |
| `balance` | `number` | Yes | Ledger financial balance in EGP | Negative indicates debt |
| `isAllowedPlayer` | `boolean` | Yes | Active participation permission | `true` = active, `false` = suspended |
| `isActive` | `boolean` | Yes | Account active status | Default: `true` |
| `joinDate` | `timestamp` | Yes | Date enrolled in academy | Timestamp |
| `lastAttendance` | `timestamp` | No | Timestamp of latest attendance | Timestamp |
| `parentName` | `string` | No | Guardian name | String |
| `parentPhone` | `string` | No | Guardian contact phone | String |
| `emergencyContact`| `string` | No | Emergency contact phone | String |
| `medicalInfo` | `string` | No | Chronic allergies, conditions | String |
| `dateOfBirth` | `timestamp` | No | Player birth date | Timestamp |
| `height` | `number` | No | Height in cm | $\ge 0$ |
| `weight` | `number` | No | Weight in kg | $\ge 0$ |
| `position` | `string` | No | Tactical position | String |
| `history` | `list<map>`| No | Array of financial / session logs | List of ledger entries |

#### Subcollection: `players/{playerId}/documents`
Stores metadata for uploaded medical certificates, contracts, and identification.
- **Document ID**: Auto-generated UID
- **Security**: Player can read their own documents; Admins have read/write access.

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `id` | `string` | Yes | Document identifier |
| `playerId` | `string` | Yes | Owning player ID |
| `fileName` | `string` | Yes | Original file name |
| `downloadUrl` | `string` | Yes | Firebase Storage HTTPS download URL |
| `fileSize` | `integer` | Yes | File size in bytes |
| `uploadDate` | `timestamp` | Yes | Upload timestamp |

---

### 2.3. `coaches`
Coach profiles, specializations, hourly compensation, and accumulated hours.

- **Document ID**: Unique Coach ID (`auth.uid` or assigned doc ID)
- **Security**: Coaches can read their own document; Admins have read/write access.

| Field | Type | Required | Description | Constraints |
| :--- | :--- | :--- | :--- | :--- |
| `userId` | `string` | Yes | References `users/{userId}` | Non-empty string |
| `name` | `string` | Yes | Coach full name | Non-empty string |
| `email` | `string` | Yes | Contact email | Valid email |
| `phoneNumber` | `string` | No | Mobile phone | E.164 or local format |
| `specialization` | `string` | Yes | Primary coaching discipline | e.g. `'Fitness'`, `'Technical'`, `'General'` |
| `certifications` | `list<string>`| Yes | Coaching licenses/credentials | Array of strings |
| `yearsOfExperience`| `integer` | Yes | Total coaching experience | $\ge 0$ |
| `bio` | `string` | No | Biography / background summary | String |
| `availability` | `list<string>`| Yes | Days/hours of availability | Array of strings |
| `hourlyRate` | `number` | Yes | Hourly compensation rate in EGP| $\ge 0.0$ |
| `totalWorkedHours` | `number` | Yes | Lifetime accumulated hours | $\ge 0.0$ |
| `isAllowedCoach` | `boolean` | Yes | Academy authorization flag | `true` = authorized, `false` = deactivated |
| `isActive` | `boolean` | Yes | Account active status | Default: `true` |
| `rating` | `number` | Yes | Quality rating | $0.0 - 5.0$ |
| `totalSessions` | `integer` | Yes | Total training sessions led | $\ge 0$ |
| `assignedCategories`| `list<string>`| No | Divisions assigned to coach | e.g. `['Junior', 'Elite']` |
| `joinDate` | `timestamp` | Yes | Academy hire date | Timestamp |

---

### 2.4. `coachWorkSessions`
Timecard check-in / check-out records for coach shifts and payroll calculations.

- **Document ID**: Auto-generated UID
- **Security**: Coach can create and read their own work sessions; Admins have read/write access.

| Field | Type | Required | Description | Constraints |
| :--- | :--- | :--- | :--- | :--- |
| `coachId` | `string` | Yes | References `coaches/{coachId}` | Non-empty string |
| `coachName` | `string` | Yes | Snapshot of coach name | String |
| `checkIn` | `timestamp` | Yes | Clock-in time | Timestamp |
| `checkOut` | `timestamp` | No | Clock-out time | Timestamp (null while shift active) |
| `hoursWorked` | `number` | Yes | Shift duration in hours | $\ge 0.0$, computed on checkout |
| `calculatedSalary`| `number` | Yes | Shift earnings in EGP | $\text{hoursWorked} \times \text{hourlyRate}$ |
| `date` | `timestamp` | Yes | Shift calendar date | Timestamp |

---

### 2.5. `attendance`
Immutable ledger of player training attendance logged by coaches.

- **Document ID**: Auto-generated UID
- **Security**: Authenticated Coaches and Admins can create; Admins and associated Players can read.

| Field | Type | Required | Description | Constraints |
| :--- | :--- | :--- | :--- | :--- |
| `playerId` | `string` | Yes | References `players/{playerId}` | Non-empty string |
| `playerName` | `string` | Yes | Snapshot of player name | String |
| `coachId` | `string` | Yes | References `coaches/{coachId}` | Non-empty string |
| `coachName` | `string` | Yes | Snapshot of coach name | String |
| `date` | `timestamp` | Yes | Attendance timestamp | Server timestamp |
| `type` | `string` | Yes | Session type | `'regular'` \| `'fitness'` \| `'recovery'` |
| `notes` | `string` | No | Coach observations / notes | Optional string |

---

### 2.6. `payments`
Financial inflow ledger for player subscriptions, package renewals, and dues.

- **Document ID**: Auto-generated UID
- **Security**: Admins have full access; Players can read their own payments.

| Field | Type | Required | Description | Constraints |
| :--- | :--- | :--- | :--- | :--- |
| `playerId` | `string` | Yes | References `players/{playerId}` | Non-empty string |
| `playerName` | `string` | Yes | Snapshot of player name | String |
| `amount` | `number` | Yes | Inflow amount in EGP | $> 0.0$ |
| `status` | `string` | Yes | Payment status | `'paid'` \| `'pending'` |
| `type` | `string` | No | Payment categorization | e.g. `'session_topup'`, `'monthly'` |
| `paymentMethod`| `string` | No | Method of transaction | `'cash'` \| `'credit card'` \| `'bank transfer'` \| `'instapay'` |
| `notes` | `string` | No | Internal remarks | String |
| `date` | `timestamp` | Yes | Payment receipt date | Timestamp |
| `createdAt` | `timestamp` | Yes | Audit log creation time | Timestamp |

---

### 2.7. `expenses`
Financial outflow ledger for academy operational expenditures.

- **Document ID**: Auto-generated UID
- **Security**: Admins only (read & write).

| Field | Type | Required | Description | Constraints |
| :--- | :--- | :--- | :--- | :--- |
| `title` | `string` | Yes | Expense description | Non-empty string |
| `amount` | `number` | Yes | Outflow amount in EGP | $> 0.0$ |
| `category` | `string` | Yes | Expense category | `'Equipment'` \| `'Facility'` \| `'Salaries'` \| `'Tournament'` \| `'Utilities'` \| `'Other'` |
| `notes` | `string` | No | Detailed notes | String |
| `date` | `timestamp` | Yes | Incurred date | Timestamp |
| `recordedBy` | `string` | Yes | Admin UID recording transaction | Non-empty string |

---

### 2.8. `training_sessions`
Scheduled academy group and division training sessions.

- **Document ID**: Auto-generated UID
- **Security**: Coaches and Admins can create; All authenticated users can read.

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `coachId` | `string` | Yes | Coach leading the session |
| `category` | `string` | Yes | Target division (`Junior`, `Senior`, `Elite`) |
| `level` | `string` | Yes | Target level |
| `type` | `string` | Yes | Session focus (`technical`, `tactical`, `physical`) |
| `date` | `timestamp` | Yes | Scheduled start time |
| `durationMinutes`| `integer` | Yes | Planned session duration |
| `notes` | `string` | No | Session plan outline |

---

### 2.9. `migration_audit`
Append-only audit trail recording every schema migration run (dry-run and live).

- **Document ID**: Auto-generated or timestamped ID (`migration_{timestamp}`)
- **Security**: Admins only.

| Field | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `timestamp` | `timestamp` | Yes | Execution timestamp |
| `dryRun` | `boolean` | Yes | `true` if dry-run, `false` if applied live |
| `legacySchemaVersion`| `integer` | Yes | Detected source version (e.g. 1) |
| `fieldsDetected` | `list<string>`| Yes | Legacy fields identified (e.g. `['password', 'sessionsPaid']`) |
| `reasonForChange` | `string` | Yes | Rationale summary |
| `warnings` | `list<string>`| Yes | Logged anomalies or boundary conditions |
| `errors` | `list<string>`| Yes | Failures encountered |
| `stats` | `map` | Yes | Record counts: `{ playersScanned, playersMigrated, coachesScanned, ... }` |

---

## 3. Legacy Schema Reconciliation & Migration Formula

### 3.1. The Legacy Session Bug
In the legacy codebase (commit `e9b7b96`):
- `coachProvider.dart` lines 48–56 decremented `sessionsPaid` via `FieldValue.increment(-1)` upon attendance scan.
- Concurrently, `sessionsAttended` was incremented via `FieldValue.increment(1)`.
- Consequently, legacy `sessionsPaid` stored **remaining sessions**, not cumulative paid sessions.

### 3.2. The V2 Cumulative Reconciliation Formula
To restore full mathematical consistency in V2 without losing historical counts:
$$\text{sessionsPaid}_{V2} = \text{sessionsPaid}_{legacy} + \text{sessionsAttended}_{legacy}$$
$$\text{sessionsAttended}_{V2} = \text{sessionsAttended}_{legacy}$$
$$\text{remainingSessions} = \text{sessionsPaid}_{V2} - \text{sessionsAttended}_{V2} \equiv \text{sessionsPaid}_{legacy}$$

This preserves the player's exact available session balance while properly aligning with the V2 cumulative schema.
