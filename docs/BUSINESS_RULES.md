# Business Rules & Operational Logic — PSA Academy V2

**Status:** Authoritative Production Reference  
**Version:** 2.0.0  
**Last Updated:** 2026-09-05  

---

## 1. Session Accounting & Attendance Validation Rules

### 1.1. Session Balance Definitions
- **Prepaid Sessions (`sessionsPaid`)**: Cumulative lifetime count of sessions purchased by or credited to a player.
- **Attended Sessions (`sessionsAttended`)**: Cumulative lifetime count of training sessions attended by the player.
- **Remaining Sessions (`remainingSessions`)**:
  $$\text{remainingSessions} = \text{sessionsPaid} - \text{sessionsAttended}$$

### 1.2. Attendance Transaction Rules
When a coach scans a player's QR code or records attendance via `RecordAttendanceUseCase`:

1. **Transaction Isolation**:
   - The operation executes inside a Firebase Firestore ACID Transaction (`FirebaseFirestore.runTransaction`).
   - Reads occur before any writes to guarantee fresh state and prevent concurrent double-spend race conditions.
2. **Authorization & Active Status Check**:
   - The player record must exist and have `isActive == true`.
   - If `isAllowedPlayer == false`, the player is suspended. The transaction is **rejected** immediately with `PlayerSuspendedException`.
3. **Session Overdraft Enforcement**:
   - If `remainingSessions <= 0` and `isAllowedPlayer == false`, attendance is **rejected** with `InsufficientSessionsException`.
   - If `remainingSessions <= 0` and `isAllowedPlayer == true`, the player is in good standing and granted grace overdraft attendance; `sessionsAttended` is incremented.
4. **Duplicate Attendance Check (15-Minute Sliding Window)**:
   - If `lastAttendance != null`, calculate:
     $$\Delta t = t_{\text{current}} - t_{\text{lastAttendance}}$$
   - If $\Delta t < 15 \text{ minutes}$, the transaction is **rejected** with `DuplicateAttendanceException` to eliminate accidental double-scanning.
5. **State Mutation**:
   - `sessionsAttended` is incremented by `+1` (or via `FieldValue.increment(1)`).
   - `lastAttendance` is updated to the current server timestamp.
   - A new immutable document is created in the `attendance` collection recording `playerId`, `coachId`, `date`, and `type`.

---

## 2. Session Types & Training Classifications

### 2.1. Attendance Types
Attendance records support three standardized session types:
1. `'regular'`: Standard technical and tactical academy squad training. Consumes 1 session credit.
2. `'fitness'`: Specialized physical conditioning and athletic performance workout. Consumes 1 session credit.
3. `'recovery'`: Hydrotherapy, physiotherapy, or light active recovery session. Consumes 1 session credit.

---

## 3. Coach Work-Session & Payroll Rules

### 3.1. Work-Session Life Cycle
1. **Clock-In (`checkInCoach`)**:
   - Validates that the coach does not already have an unclosed work session (`checkOut == null`).
   - If an open session exists, the existing session is returned without creating a duplicate.
   - Creates a document in `coachWorkSessions` with `checkIn = now`, `checkOut = null`, `hoursWorked = 0.0`.
2. **Clock-Out (`checkOutCoach`)**:
   - Queries the active work session for the coach.
   - If no active session exists, fails with `FirestoreFailure('No active session to check out.')`.
   - Computes elapsed duration:
     $$\Delta t_{\text{minutes}} = t_{\text{checkout}} - t_{\text{checkin}}$$
     $$\text{hoursWorked} = \max(0.0, \frac{\Delta t_{\text{minutes}}}{60.0})$$
     $$\text{calculatedSalary} = \text{hoursWorked} \times \text{hourlyRate}$$
   - Atomically updates the work session document with `checkOut`, `hoursWorked`, and `calculatedSalary`.
   - Atomically updates `coaches/{coachId}` by incrementing `totalWorkedHours` with `FieldValue.increment(hoursWorked)`.

---

## 4. Financial Management & Ledger Rules

### 4.1. Inflow (Payments)
- Recorded in the `payments` collection with `amount > 0.0` and `status = 'paid'`.
- Supported payment methods: `Cash`, `Credit Card`, `Bank Transfer`, `InstaPay`.
- Recording a payment creates an audit ledger entry and updates financial summary metrics.
- Adding sessions via Admin credits `sessionsPaid` and records a top-up payment atomically.

### 4.2. Outflow (Expenses)
- Recorded in the `expenses` collection with `amount > 0.0`.
- Categorized under: `'Equipment'`, `'Facility'`, `'Salaries'`, `'Tournament'`, `'Utilities'`, `'Other'`.
- Outflows deduct from total academy net revenue.

### 4.3. Financial Reconciliation Formulas
$$\text{Total Revenue} = \sum \text{payments.amount where status} = \text{'paid'}$$
$$\text{Total Expenses} = \sum \text{expenses.amount}$$
$$\text{Net Profit} = \text{Total Revenue} - \text{Total Expenses}$$

### 4.4. Financial Reporting & PDF Export
- Dynamic date range filtering: All-time, Today, This Month, This Year, or Custom range.
- Cross-platform PDF export generates financial reports directly via `PlatformPdfExport`:
  - **Web**: Uses browser Blob / Object URL download triggering via `dart:html` / `package:web`.
  - **Mobile / Desktop**: Generates PDF and shares or saves to local device storage via `path_provider` and `open_file`.

---

## 5. User Lifecycle & Access Control Rules

### 5.1. User Types & Permissions
- **Admin**: Full read/write access to all collections, user management, financial reports, and system settings.
- **Coach**:
  - Authorized (`isAllowedCoach == true`): Can scan player attendance, view squad players, schedule training sessions, and clock in/out.
  - Deactivated (`isAllowedCoach == false`): Denied access to coach features.
- **Player**:
  - Active (`isAllowedPlayer == true`): Authorized to attend sessions if session balance is valid.
  - Suspended (`isAllowedPlayer == false`): Prohibited from session attendance and check-in.

### 5.2. User Creation & Deletion Safeguards
- **Creation**: Requires non-empty name and valid email. Unique IDs are generated, and role document is written in corresponding collection (`players` or `coaches`).
- **Deletion**: Requires explicit administrative confirmation via modal prompt. Deletion removes the root player/coach record from Firestore.
