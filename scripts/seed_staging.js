/**
 * Seed script for PSA Academy V2 Staging Environment (psa-academy-staging)
 * Run with: node scripts/seed_staging.js
 */

const https = require('https');

const STAGING_API_KEY = 'AIzaSyAZGATfJNnu32cNOk7kS5z15f63ofcITpI';
const PROJECT_ID = 'psa-academy-staging';

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
        res.on('data', (chunk) => (body += chunk));
        res.on('end', () => {
          try {
            const parsed = JSON.parse(body);
            if (res.statusCode >= 400) {
              reject({ status: res.statusCode, error: parsed });
            } else {
              resolve(parsed);
            }
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

function patchFirestore(docPath, fields, idToken) {
  const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${docPath}`;
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({ fields });
    const parsedUrl = new URL(url);
    const req = https.request(
      {
        hostname: parsedUrl.hostname,
        path: parsedUrl.pathname + parsedUrl.search,
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(data),
          Authorization: `Bearer ${idToken}`,
        },
      },
      (res) => {
        let body = '';
        res.on('data', (chunk) => (body += chunk));
        res.on('end', () => {
          try {
            const parsed = JSON.parse(body);
            if (res.statusCode >= 400) {
              reject({ status: res.statusCode, error: parsed });
            } else {
              resolve(parsed);
            }
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

function createFirestoreDoc(collectionPath, fields, idToken, docId) {
  let url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${collectionPath}`;
  if (docId) {
    url += `?documentId=${docId}`;
  }
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({ fields });
    const parsedUrl = new URL(url);
    const req = https.request(
      {
        hostname: parsedUrl.hostname,
        path: parsedUrl.pathname + parsedUrl.search,
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(data),
          Authorization: `Bearer ${idToken}`,
        },
      },
      (res) => {
        let body = '';
        res.on('data', (chunk) => (body += chunk));
        res.on('end', () => {
          try {
            const parsed = JSON.parse(body);
            if (res.statusCode >= 400) {
              reject({ status: res.statusCode, error: parsed });
            } else {
              resolve(parsed);
            }
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

async function getOrCreateUser(email, password, displayName) {
  const signUpUrl = `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${STAGING_API_KEY}`;
  const signInUrl = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${STAGING_API_KEY}`;

  try {
    const res = await postJson(signUpUrl, {
      email,
      password,
      returnSecureToken: true,
    });
    console.log(`[AUTH] Created user: ${email} (UID: ${res.localId})`);
    return res;
  } catch (err) {
    if (
      err.error &&
      err.error.error &&
      err.error.error.message === 'EMAIL_EXISTS'
    ) {
      const res = await postJson(signInUrl, {
        email,
        password,
        returnSecureToken: true,
      });
      console.log(`[AUTH] Signed in existing user: ${email} (UID: ${res.localId})`);
      return res;
    }
    throw err;
  }
}

async function seed() {
  console.log('=== Starting PSA Academy V2 Staging Seed ===');

  // 1. Create or authenticate all 5 users
  const adminAuth = await getOrCreateUser(
    'staging-admin@psa-academy.test',
    'Password123!',
    'Staging Admin'
  );
  const coachAuth = await getOrCreateUser(
    'staging-coach@psa-academy.test',
    'Password123!',
    'Staging Coach Captain'
  );
  const activePlayerAuth = await getOrCreateUser(
    'staging-player-active@psa-academy.test',
    'Password123!',
    'Active Staging Player'
  );
  const zeroPlayerAuth = await getOrCreateUser(
    'staging-player-zero@psa-academy.test',
    'Password123!',
    'Zero Sessions Player'
  );
  const inactivePlayerAuth = await getOrCreateUser(
    'staging-player-inactive@psa-academy.test',
    'Password123!',
    'Inactive Player'
  );

  const adminToken = adminAuth.idToken;
  const nowIso = new Date().toISOString();

  // 2. Seed `users` directory
  console.log('[FIRESTORE] Seeding users collection...');
  await patchFirestore(
    `users/${adminAuth.localId}`,
    {
      name: { stringValue: 'Staging Admin' },
      email: { stringValue: 'staging-admin@psa-academy.test' },
      role: { stringValue: 'admin' },
      createdAt: { timestampValue: nowIso },
    },
    adminToken
  );

  await patchFirestore(
    `users/${coachAuth.localId}`,
    {
      name: { stringValue: 'Staging Coach Captain' },
      email: { stringValue: 'staging-coach@psa-academy.test' },
      role: { stringValue: 'coach' },
      createdAt: { timestampValue: nowIso },
    },
    adminToken
  );

  await patchFirestore(
    `users/${activePlayerAuth.localId}`,
    {
      name: { stringValue: 'Active Staging Player' },
      email: { stringValue: 'staging-player-active@psa-academy.test' },
      role: { stringValue: 'player' },
      createdAt: { timestampValue: nowIso },
    },
    adminToken
  );

  await patchFirestore(
    `users/${zeroPlayerAuth.localId}`,
    {
      name: { stringValue: 'Zero Sessions Player' },
      email: { stringValue: 'staging-player-zero@psa-academy.test' },
      role: { stringValue: 'player' },
      createdAt: { timestampValue: nowIso },
    },
    adminToken
  );

  await patchFirestore(
    `users/${inactivePlayerAuth.localId}`,
    {
      name: { stringValue: 'Inactive Player' },
      email: { stringValue: 'staging-player-inactive@psa-academy.test' },
      role: { stringValue: 'player' },
      createdAt: { timestampValue: nowIso },
    },
    adminToken
  );

  // 3. Seed `admin` collection
  console.log('[FIRESTORE] Seeding admin document...');
  await patchFirestore(
    `admin/${adminAuth.localId}`,
    {
      name: { stringValue: 'Staging Admin' },
      email: { stringValue: 'staging-admin@psa-academy.test' },
      role: { stringValue: 'admin' },
      createdAt: { timestampValue: nowIso },
    },
    adminToken
  );

  // 4. Seed `coaches` collection
  console.log('[FIRESTORE] Seeding coaches collection...');
  await patchFirestore(
    `coaches/${coachAuth.localId}`,
    {
      userId: { stringValue: coachAuth.localId },
      name: { stringValue: 'Staging Coach Captain' },
      email: { stringValue: 'staging-coach@psa-academy.test' },
      phoneNumber: { stringValue: '+201000000001' },
      specialization: { stringValue: 'Fitness & Conditioning' },
      hourlyRate: { doubleValue: 150.0 },
      totalWorkedHours: { doubleValue: 2.0 },
      rating: { doubleValue: 4.8 },
      totalSessions: { integerValue: '12' },
      isAllowedCoach: { booleanValue: true },
      isActive: { booleanValue: true },
      certifications: {
        arrayValue: {
          values: [
            { stringValue: 'UEFA C License' },
            { stringValue: 'First Aid Certified' },
          ],
        },
      },
      yearsOfExperience: { integerValue: '5' },
      bio: { stringValue: 'Dedicated academy fitness coach' },
      availability: {
        arrayValue: {
          values: [{ stringValue: 'Mon' }, { stringValue: 'Wed' }, { stringValue: 'Fri' }],
        },
      },
      assignedCategories: {
        arrayValue: {
          values: [{ stringValue: 'Junior' }, { stringValue: 'Senior' }],
        },
      },
      joinDate: { timestampValue: nowIso },
    },
    adminToken
  );

  // 5. Seed `players` collection
  console.log('[FIRESTORE] Seeding players collection...');
  // A. Active Player with 8 remaining sessions
  await patchFirestore(
    `players/${activePlayerAuth.localId}`,
    {
      userId: { stringValue: activePlayerAuth.localId },
      name: { stringValue: 'Active Staging Player' },
      email: { stringValue: 'staging-player-active@psa-academy.test' },
      phone: { stringValue: '+201000000002' },
      level: { stringValue: 'Intermediate' },
      category: { stringValue: 'Junior' },
      ageGroup: { stringValue: 'Under 12' },
      sessionsPaid: { integerValue: '10' },
      sessionsAttended: { integerValue: '2' },
      balance: { doubleValue: 0.0 },
      isAllowedPlayer: { booleanValue: true },
      isActive: { booleanValue: true },
      joinDate: { timestampValue: nowIso },
      parentName: { stringValue: 'Parent of Active Player' },
      parentPhone: { stringValue: '+201000000003' },
      position: { stringValue: 'Midfielder' },
      schemaVersion: { integerValue: '2' },
    },
    adminToken
  );

  // B. Zero-session Player (cannot check in unless allowed overdraft)
  await patchFirestore(
    `players/${zeroPlayerAuth.localId}`,
    {
      userId: { stringValue: zeroPlayerAuth.localId },
      name: { stringValue: 'Zero Sessions Player' },
      email: { stringValue: 'staging-player-zero@psa-academy.test' },
      phone: { stringValue: '+201000000004' },
      level: { stringValue: 'Beginner' },
      category: { stringValue: 'Junior' },
      ageGroup: { stringValue: 'Under 10' },
      sessionsPaid: { integerValue: '5' },
      sessionsAttended: { integerValue: '5' },
      balance: { doubleValue: 0.0 },
      isAllowedPlayer: { booleanValue: false },
      isActive: { booleanValue: true },
      joinDate: { timestampValue: nowIso },
      parentName: { stringValue: 'Parent of Zero Player' },
      parentPhone: { stringValue: '+201000000005' },
      position: { stringValue: 'Forward' },
      schemaVersion: { integerValue: '2' },
    },
    adminToken
  );

  // C. Inactive Player
  await patchFirestore(
    `players/${inactivePlayerAuth.localId}`,
    {
      userId: { stringValue: inactivePlayerAuth.localId },
      name: { stringValue: 'Inactive Player' },
      email: { stringValue: 'staging-player-inactive@psa-academy.test' },
      phone: { stringValue: '+201000000006' },
      level: { stringValue: 'Advanced' },
      category: { stringValue: 'Senior' },
      ageGroup: { stringValue: 'Under 16' },
      sessionsPaid: { integerValue: '10' },
      sessionsAttended: { integerValue: '5' },
      balance: { doubleValue: 0.0 },
      isAllowedPlayer: { booleanValue: false },
      isActive: { booleanValue: false },
      joinDate: { timestampValue: nowIso },
      parentName: { stringValue: 'Parent of Inactive Player' },
      parentPhone: { stringValue: '+201000000007' },
      position: { stringValue: 'Defender' },
      schemaVersion: { integerValue: '2' },
    },
    adminToken
  );

  // 6. Seed `trainingTemplates`
  console.log('[FIRESTORE] Seeding trainingTemplates collection...');
  await createFirestoreDoc(
    'trainingTemplates',
    {
      trainingName: { stringValue: 'Core Agility & Power Routine' },
      category: { stringValue: 'Fitness' },
      targetMuscle: { stringValue: 'Legs & Core' },
      description: { stringValue: 'High-intensity cone agility drills and core stabilization.' },
      exercises: {
        arrayValue: {
          values: [
            {
              mapValue: {
                fields: {
                  name: { stringValue: 'Ladder Speed Run' },
                  reps: { stringValue: '5 sets x 30 sec' },
                  targetTime: { stringValue: '30s' },
                },
              },
            },
            {
              mapValue: {
                fields: {
                  name: { stringValue: 'Plank with Shoulder Taps' },
                  reps: { stringValue: '3 sets x 15 reps' },
                  targetTime: { stringValue: '45s' },
                },
              },
            },
          ],
        },
      },
      createdAt: { timestampValue: nowIso },
    },
    adminToken
  );

  await createFirestoreDoc(
    'trainingTemplates',
    {
      trainingName: { stringValue: 'Tactical Passing & Ball Control' },
      category: { stringValue: 'Technical' },
      targetMuscle: { stringValue: 'Full Body' },
      description: { stringValue: 'Two-touch passing sequences under pressure.' },
      exercises: {
        arrayValue: {
          values: [
            {
              mapValue: {
                fields: {
                  name: { stringValue: 'Rondo 4v2' },
                  reps: { stringValue: '4 rounds x 3 min' },
                  targetTime: { stringValue: '12 min' },
                },
              },
            },
          ],
        },
      },
      createdAt: { timestampValue: nowIso },
    },
    adminToken
  );

  // 7. Seed `payments`
  console.log('[FIRESTORE] Seeding payments collection...');
  await createFirestoreDoc(
    'payments',
    {
      playerId: { stringValue: activePlayerAuth.localId },
      playerName: { stringValue: 'Active Staging Player' },
      amount: { doubleValue: 1500.0 },
      status: { stringValue: 'paid' },
      type: { stringValue: 'monthly' },
      paymentMethod: { stringValue: 'instapay' },
      notes: { stringValue: 'Monthly 10-session package subscription' },
      date: { timestampValue: nowIso },
      createdAt: { timestampValue: nowIso },
    },
    adminToken
  );

  await createFirestoreDoc(
    'payments',
    {
      playerId: { stringValue: zeroPlayerAuth.localId },
      playerName: { stringValue: 'Zero Sessions Player' },
      amount: { doubleValue: 800.0 },
      status: { stringValue: 'paid' },
      type: { stringValue: 'session_topup' },
      paymentMethod: { stringValue: 'cash' },
      notes: { stringValue: '5-session package top-up' },
      date: { timestampValue: nowIso },
      createdAt: { timestampValue: nowIso },
    },
    adminToken
  );

  // 8. Seed `expenses`
  console.log('[FIRESTORE] Seeding expenses collection...');
  await createFirestoreDoc(
    'expenses',
    {
      title: { stringValue: 'Training Cones and Speed Ladders' },
      amount: { doubleValue: 450.0 },
      category: { stringValue: 'Equipment' },
      notes: { stringValue: 'Replacement gear for pitch A' },
      date: { timestampValue: nowIso },
      recordedBy: { stringValue: adminAuth.localId },
    },
    adminToken
  );

  await createFirestoreDoc(
    'expenses',
    {
      title: { stringValue: 'Pitch Floodlights Maintenance' },
      amount: { doubleValue: 600.0 },
      category: { stringValue: 'Facility' },
      notes: { stringValue: 'Electrician service fee' },
      date: { timestampValue: nowIso },
      recordedBy: { stringValue: adminAuth.localId },
    },
    adminToken
  );

  // 9. Seed `coachWorkSessions`
  console.log('[FIRESTORE] Seeding coachWorkSessions collection...');
  const shiftStart = new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString();
  await createFirestoreDoc(
    'coachWorkSessions',
    {
      coachId: { stringValue: coachAuth.localId },
      coachName: { stringValue: 'Staging Coach Captain' },
      checkIn: { timestampValue: shiftStart },
      checkOut: { timestampValue: nowIso },
      hoursWorked: { doubleValue: 2.0 },
      calculatedSalary: { doubleValue: 300.0 },
      date: { timestampValue: nowIso },
    },
    adminToken
  );

  // 10. Seed `attendance`
  console.log('[FIRESTORE] Seeding attendance collection...');
  await createFirestoreDoc(
    'attendance',
    {
      playerId: { stringValue: activePlayerAuth.localId },
      playerName: { stringValue: 'Active Staging Player' },
      coachId: { stringValue: coachAuth.localId },
      coachName: { stringValue: 'Staging Coach Captain' },
      date: { timestampValue: nowIso },
      type: { stringValue: 'fitness' },
      notes: { stringValue: 'Initial baseline fitness check-in' },
    },
    adminToken
  );

  console.log('=== Staging Seed Successfully Completed ===');
  console.log('Synthetic Accounts Created:');
  console.log('1. Admin:           staging-admin@psa-academy.test           / Password123!');
  console.log('2. Coach:           staging-coach@psa-academy.test           / Password123!');
  console.log('3. Active Player:   staging-player-active@psa-academy.test   / Password123!');
  console.log('4. Zero-Session:    staging-player-zero@psa-academy.test     / Password123!');
  console.log('5. Inactive Player: staging-player-inactive@psa-academy.test / Password123!');
}

seed().catch((err) => {
  console.error('Seed Failed:', err);
  process.exit(1);
});
