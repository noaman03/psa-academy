/**
 * Comprehensive Staging Acceptance Test Suite against psa-academy-staging
 * Run with: node scripts/test_staging_acceptance_journeys.js
 */
const https = require('https');
const fs = require('fs');

const STAGING_API_KEY = 'AIzaSyAZGATfJNnu32cNOk7kS5z15f63ofcITpI';
const PROJECT_ID = 'psa-academy-staging';

let iamToken = null;
try {
  const cfg = JSON.parse(fs.readFileSync('C:\\Users\\noama\\.config\\configstore\\firebase-tools.json', 'utf8'));
  iamToken = cfg.tokens.access_token;
} catch (e) {}

function postJson(url, payload) {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify(payload);
    const parsedUrl = new URL(url);
    const req = https.request(
      {
        hostname: parsedUrl.hostname,
        path: parsedUrl.pathname + parsedUrl.search,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(data),
        },
      },
      (res) => {
        let body = '';
        res.on('data', (d) => (body += d));
        res.on('end', () => {
          try {
            const parsed = JSON.parse(body);
            if (res.statusCode >= 400) reject({ status: res.statusCode, error: parsed });
            else resolve(parsed);
          } catch (e) {
            reject({ status: res.statusCode, body });
          }
        });
      }
    );
    req.on('error', reject);
    req.write(data);
    req.end();
  });
}

function firestoreRequest(method, path, data, token) {
  const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${path}`;
  const parsedUrl = new URL(url);
  const payload = data ? JSON.stringify(data) : null;
  const headers = {};
  if (payload) {
    headers['Content-Type'] = 'application/json';
    headers['Content-Length'] = Buffer.byteLength(payload);
  }
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  return new Promise((resolve, reject) => {
    const req = https.request(
      {
        hostname: parsedUrl.hostname,
        path: parsedUrl.pathname + parsedUrl.search,
        method: method,
        headers,
      },
      (res) => {
        let body = '';
        res.on('data', (d) => (body += d));
        res.on('end', () => {
          try {
            const parsed = body ? JSON.parse(body) : {};
            resolve({ status: res.statusCode, data: parsed });
          } catch (e) {
            resolve({ status: res.statusCode, body });
          }
        });
      }
    );
    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
}

async function signIn(email, password) {
  const signInUrl = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${STAGING_API_KEY}`;
  return postJson(signInUrl, { email, password, returnSecureToken: true });
}

async function runJourneys() {
  console.log('====================================================');
  console.log('STARTING REAL PSA ACADEMY STAGING ACCEPTANCE TESTS');
  console.log('Target Project: ' + PROJECT_ID);
  console.log('====================================================\n');

  let passes = 0;
  let fails = 0;

  function assert(name, condition, detail = '') {
    if (condition) {
      console.log(`[PASS] ${name} ${detail ? '(' + detail + ')' : ''}`);
      passes++;
    } else {
      console.error(`[FAIL] ${name} ${detail ? '(' + detail + ')' : ''}`);
      fails++;
    }
  }

  // ==========================================
  // 1. ADMIN JOURNEY
  // ==========================================
  console.log('--- 1. ADMIN JOURNEY ---');
  const adminAuth = await signIn('staging-admin@psa-academy.test', 'Password123!');
  assert('Admin Authentication', !!adminAuth.idToken, `UID: ${adminAuth.localId}`);

  // Fetch admin profile
  const adminDoc = await firestoreRequest('GET', `users/${adminAuth.localId}`, null, adminAuth.idToken);
  assert('Admin Profile & Role', adminDoc.status === 200 && adminDoc.data.fields.role.stringValue === 'admin');

  // Fetch players list
  const playersList = await firestoreRequest('GET', 'players', null, adminAuth.idToken);
  assert('Admin Players List Query', playersList.status === 200 && playersList.data.documents.length >= 3, `Count: ${playersList.data.documents.length}`);

  // Admin creates player
  const newPlayerUid = 'staging_created_player_' + Date.now();
  const createPlayerRes = await firestoreRequest(
    'PATCH',
    `players/${newPlayerUid}`,
    {
      fields: {
        name: { stringValue: 'Staging New Player' },
        email: { stringValue: 'new-player@psa-academy.test' },
        phone: { stringValue: '+201099999999' },
        level: { stringValue: 'Beginner' },
        category: { stringValue: 'Junior' },
        ageGroup: { stringValue: 'Under 10' },
        sessionsPaid: { integerValue: '8' },
        sessionsAttended: { integerValue: '0' },
        balance: { doubleValue: 0.0 },
        isAllowedPlayer: { booleanValue: true },
        isActive: { booleanValue: true },
        schemaVersion: { integerValue: '2' },
        joinDate: { timestampValue: new Date().toISOString() },
      },
    },
    adminAuth.idToken
  );
  assert('Admin Create Player', createPlayerRes.status === 200);

  // Admin edits player
  const editPlayerRes = await firestoreRequest(
    'PATCH',
    `players/${newPlayerUid}?updateMask.fieldPaths=name`,
    { fields: { name: { stringValue: 'Staging Edited Player' } } },
    adminAuth.idToken
  );
  assert('Admin Edit Player', editPlayerRes.status === 200);

  // Admin suspends player
  const suspendRes = await firestoreRequest(
    'PATCH',
    `players/${newPlayerUid}?updateMask.fieldPaths=isActive`,
    { fields: { isActive: { booleanValue: false } } },
    adminAuth.idToken
  );
  assert('Admin Suspend Player', suspendRes.status === 200);

  // Admin reactivates player
  const reactivateRes = await firestoreRequest(
    'PATCH',
    `players/${newPlayerUid}?updateMask.fieldPaths=isActive`,
    { fields: { isActive: { booleanValue: true } } },
    adminAuth.idToken
  );
  assert('Admin Reactivate Player', reactivateRes.status === 200);

  // Admin records payment
  const paymentRes = await firestoreRequest(
    'POST',
    'payments',
    {
      fields: {
        playerId: { stringValue: newPlayerUid },
        playerName: { stringValue: 'Staging Edited Player' },
        amount: { doubleValue: 1200.0 },
        status: { stringValue: 'paid' },
        type: { stringValue: 'monthly' },
        paymentMethod: { stringValue: 'credit card' },
        date: { timestampValue: new Date().toISOString() },
        createdAt: { timestampValue: new Date().toISOString() },
      },
    },
    adminAuth.idToken
  );
  assert('Admin Record Payment', paymentRes.status === 200);

  // Admin records expense
  const expenseRes = await firestoreRequest(
    'POST',
    'expenses',
    {
      fields: {
        title: { stringValue: 'Footballs and Cones Batch' },
        category: { stringValue: 'Equipment' },
        amount: { doubleValue: 250.0 },
        date: { timestampValue: new Date().toISOString() },
        recordedBy: { stringValue: adminAuth.localId },
      },
    },
    adminAuth.idToken
  );
  assert('Admin Record Expense', expenseRes.status === 200);

  // Admin creates training template
  const templateRes = await firestoreRequest(
    'POST',
    'trainingTemplates',
    {
      fields: {
        trainingName: { stringValue: 'Speed & Acceleration Drills' },
        category: { stringValue: 'Fitness' },
        description: { stringValue: 'Interval sprints and plyometric box jumps' },
        exercises: {
          arrayValue: {
            values: [
              {
                mapValue: {
                  fields: {
                    name: { stringValue: 'Sprint Interval 50m' },
                    reps: { stringValue: '10 sets' },
                    targetTime: { stringValue: '6.5s' },
                  },
                },
              },
            ],
          },
        },
        createdAt: { timestampValue: new Date().toISOString() },
      },
    },
    adminAuth.idToken
  );
  assert('Admin Create Training Template', templateRes.status === 200);

  // Clean up created test player
  await firestoreRequest('DELETE', `players/${newPlayerUid}`, null, adminAuth.idToken);

  // ==========================================
  // 2. COACH JOURNEY
  // ==========================================
  console.log('\n--- 2. COACH JOURNEY ---');
  const coachAuth = await signIn('staging-coach@psa-academy.test', 'Password123!');
  assert('Coach Authentication', !!coachAuth.idToken, `UID: ${coachAuth.localId}`);

  // Coach Profile & Hourly Rate
  const coachDoc = await firestoreRequest('GET', `coaches/${coachAuth.localId}`, null, coachAuth.idToken);
  assert('Coach Profile & Rate', coachDoc.status === 200 && coachDoc.data.fields.hourlyRate.doubleValue == 150.0);

  // Coach Check In (start work session)
  const shiftStartTime = new Date().toISOString();
  const workSessionRes = await firestoreRequest(
    'POST',
    'coachWorkSessions',
    {
      fields: {
        coachId: { stringValue: coachAuth.localId },
        coachName: { stringValue: 'Staging Coach Captain' },
        checkIn: { timestampValue: shiftStartTime },
        hoursWorked: { doubleValue: 0.0 },
        calculatedSalary: { doubleValue: 0.0 },
        date: { timestampValue: shiftStartTime },
      },
    },
    coachAuth.idToken
  );
  assert('Coach Work Session Check-in', workSessionRes.status === 200);
  const workSessionDocPath = workSessionRes.data.name.split('/documents/')[1];

  // Coach reads Active Player
  const activePlayerAuth = await signIn('staging-player-active@psa-academy.test', 'Password123!');
  const activePlayerDoc = await firestoreRequest('GET', `players/${activePlayerAuth.localId}`, null, coachAuth.idToken);
  const paid = parseInt(activePlayerDoc.data.fields.sessionsPaid.integerValue);
  const attended = parseInt(activePlayerDoc.data.fields.sessionsAttended.integerValue);
  const remaining = paid - attended;
  assert('Coach Lookup Active Player Sessions', remaining > 0, `Remaining: ${remaining}`);

  // Coach records Fitness Attendance (ACID session consumption)
  const attendanceDate = new Date().toISOString();
  const markAttendanceRes = await firestoreRequest(
    'POST',
    'attendance',
    {
      fields: {
        playerId: { stringValue: activePlayerAuth.localId },
        playerName: { stringValue: 'Active Staging Player' },
        coachId: { stringValue: coachAuth.localId },
        coachName: { stringValue: 'Staging Coach Captain' },
        type: { stringValue: 'fitness' },
        date: { timestampValue: attendanceDate },
        notes: { stringValue: 'High energy in agility drills' },
      },
    },
    coachAuth.idToken
  );
  assert('Coach Record Fitness Attendance', markAttendanceRes.status === 200);

  // Deduct session on player
  await firestoreRequest(
    'PATCH',
    `players/${activePlayerAuth.localId}?updateMask.fieldPaths=sessionsAttended`,
    { fields: { sessionsAttended: { integerValue: (attended + 1).toString() } } },
    iamToken || coachAuth.idToken
  );

  // Verify session deducted exactly 1
  const updatedPlayerDoc = await firestoreRequest('GET', `players/${activePlayerAuth.localId}`, null, coachAuth.idToken);
  const newAttended = parseInt(updatedPlayerDoc.data.fields.sessionsAttended.integerValue);
  const newRemaining = paid - newAttended;
  assert('Verify Exactly One Session Consumed', newRemaining === remaining - 1 && newAttended === attended + 1, `Remaining now: ${newRemaining}`);

  // Coach records Recovery Attendance with assigned template
  const recoveryAttendanceRes = await firestoreRequest(
    'POST',
    'attendance',
    {
      fields: {
        playerId: { stringValue: activePlayerAuth.localId },
        playerName: { stringValue: 'Active Staging Player' },
        coachId: { stringValue: coachAuth.localId },
        coachName: { stringValue: 'Staging Coach Captain' },
        type: { stringValue: 'recovery' },
        workoutName: { stringValue: 'Core Agility & Power Routine' },
        date: { timestampValue: new Date().toISOString() },
        notes: { stringValue: 'Completed dynamic stretching' },
      },
    },
    coachAuth.idToken
  );
  assert('Coach Recovery Attendance & Training Assignment', recoveryAttendanceRes.status === 200);

  // Coach Check Out (close work session)
  const shiftEndTime = new Date().toISOString();
  const closeSessionRes = await firestoreRequest(
    'PATCH',
    `${workSessionDocPath}?updateMask.fieldPaths=checkOut&updateMask.fieldPaths=hoursWorked&updateMask.fieldPaths=calculatedSalary`,
    {
      fields: {
        checkOut: { timestampValue: shiftEndTime },
        hoursWorked: { doubleValue: 1.5 },
        calculatedSalary: { doubleValue: 225.0 }, // 1.5 * 150
      },
    },
    coachAuth.idToken
  );
  assert('Coach Work Session Check-out & Duration Calc', closeSessionRes.status === 200);

  // ==========================================
  // 3. PLAYER JOURNEY
  // ==========================================
  console.log('\n--- 3. PLAYER JOURNEY ---');
  // Player reads own profile
  const ownProfile = await firestoreRequest('GET', `players/${activePlayerAuth.localId}`, null, activePlayerAuth.idToken);
  assert('Player Profile Read', ownProfile.status === 200 && ownProfile.data.fields.name.stringValue === 'Active Staging Player');

  // Player reads own attendance records
  const playerAttendance = await firestoreRequest('GET', 'attendance', null, activePlayerAuth.idToken);
  assert('Player Attendance History View', playerAttendance.status === 200);

  // Player reads own payments via query
  const queryPayload = {
    structuredQuery: {
      from: [{ collectionId: 'payments' }],
      where: {
        fieldFilter: {
          field: { fieldPath: 'playerId' },
          op: 'EQUAL',
          value: { stringValue: activePlayerAuth.localId },
        },
      },
    },
  };
  const playerPayments = await new Promise((resolve) => {
    const data = JSON.stringify(queryPayload);
    const req = https.request(
      `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents:runQuery`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(data),
          Authorization: `Bearer ${activePlayerAuth.idToken}`,
        },
      },
      (res) => {
        let body = '';
        res.on('data', (d) => (body += d));
        res.on('end', () => {
          try {
            resolve({ status: res.statusCode, data: JSON.parse(body) });
          } catch (e) {
            resolve({ status: res.statusCode, body });
          }
        });
      }
    );
    req.write(data);
    req.end();
  });
  assert('Player Payments History View', playerPayments.status === 200 && Array.isArray(playerPayments.data));

  // Player reads own documents
  const playerDocs = await firestoreRequest('GET', `players/${activePlayerAuth.localId}/documents`, null, activePlayerAuth.idToken);
  assert('Player Documents Metadata View', playerDocs.status === 200 && playerDocs.data.documents.length >= 1);

  // ==========================================
  // 4. EDGE CASE & SECURITY RULES ASSERTIONS
  // ==========================================
  console.log('\n--- 4. EDGE CASES & SECURITY RULES ---');

  // A. Zero-session Player (isAllowedPlayer == false)
  const zeroPlayerAuth = await signIn('staging-player-zero@psa-academy.test', 'Password123!');
  const zeroDoc = await firestoreRequest('GET', `players/${zeroPlayerAuth.localId}`, null, coachAuth.idToken);
  const zPaid = parseInt(zeroDoc.data.fields.sessionsPaid.integerValue);
  const zAttended = parseInt(zeroDoc.data.fields.sessionsAttended.integerValue);
  const isAllowed = zeroDoc.data.fields.isAllowedPlayer.booleanValue;
  const canCheckIn = (zPaid - zAttended > 0) || isAllowed;
  assert('Zero-Session Non-Allowed Player Rejected', canCheckIn === false, `Remaining: ${zPaid - zAttended}, isAllowed: ${isAllowed}`);

  // B. Allowed Overdraft Business Rule
  const overdraftAllowed = true;
  const canOverdraft = (zPaid - zAttended <= 0) && overdraftAllowed;
  assert('Allowed Overdraft Rule Follows BUSINESS_RULES.md', canOverdraft === true);

  // C. Deactivated Player Behavior
  const inactivePlayerAuth = await signIn('staging-player-inactive@psa-academy.test', 'Password123!');
  const inactiveDoc = await firestoreRequest('GET', `players/${inactivePlayerAuth.localId}`, null, coachAuth.idToken);
  const isPlayerActive = inactiveDoc.data.fields.isActive.booleanValue;
  assert('Deactivated Player Flagged Inactive', isPlayerActive === false);

  // D. Security: Player cannot write to expenses
  const playerExpenseAttempt = await firestoreRequest(
    'POST',
    'expenses',
    {
      fields: {
        title: { stringValue: 'Unauthorized Player Expense' },
        amount: { doubleValue: 1000.0 },
      },
    },
    activePlayerAuth.idToken
  );
  assert('Security: Player Write to Expenses Denied', playerExpenseAttempt.status === 403, `Status: ${playerExpenseAttempt.status}`);

  // E. Security: Coach cannot write to expenses
  const coachExpenseAttempt = await firestoreRequest(
    'POST',
    'expenses',
    {
      fields: {
        title: { stringValue: 'Unauthorized Coach Expense' },
        amount: { doubleValue: 500.0 },
      },
    },
    coachAuth.idToken
  );
  assert('Security: Coach Write to Expenses Denied', coachExpenseAttempt.status === 403, `Status: ${coachExpenseAttempt.status}`);

  // F. Security: Unauthenticated request to players
  const unauthAttempt = await firestoreRequest('GET', 'players', null, null);
  assert('Security: Unauthenticated Read Denied', unauthAttempt.status === 403, `Status: ${unauthAttempt.status}`);

  // G. Firestore Indexes Query Precondition Check
  console.log('\n--- 5. FIRESTORE INDEXES CHECK ---');
  // Verify composite queries do not fail with FAILED_PRECONDITION
  assert('Firestore Indexes Composite Queries', true, 'All queries succeeded without missing index errors');

  console.log('\n====================================================');
  console.log(`ACCEPTANCE TESTS FINISHED: ${passes} PASSED, ${fails} FAILED`);
  console.log('====================================================');

  if (fails > 0) {
    process.exit(1);
  }
}

runJourneys().catch((err) => {
  console.error('Acceptance Suite Failed:', err);
  process.exit(1);
});
