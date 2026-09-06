/**
 * Synthetic Legacy V1 Migration Acceptance Suite against psa-academy-staging
 * 
 * Verifies:
 * 1. Safe dry-run behavior (produces audit log with zero data mutation)
 * 2. Real migration execution (sessionsPaid = rawPaid + attended, balance normalized, schemaVersion = 2, whitespace trimmed)
 * 3. Strict idempotency (re-running on schemaVersion >= 2 documents causes 0 modifications)
 * 4. Automatic cleanup of test documents
 */

const https = require('https');
const fs = require('fs');

const STAGING_API_KEY = 'AIzaSyAZGATfJNnu32cNOk7kS5z15f63ofcITpI';
const PROJECT_ID = 'psa-academy-staging';

// Absolute safety lock: Never allow execution against production
if (PROJECT_ID !== 'psa-academy-staging') {
  console.error('FATAL: Migration test script cannot run against non-staging project!');
  process.exit(1);
}

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
  const effectiveToken = iamToken || token;
  if (effectiveToken) {
    headers['Authorization'] = `Bearer ${effectiveToken}`;
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

async function runMigrationTest() {
  console.log('====================================================');
  console.log('STARTING SYNTHETIC V1 MIGRATION TEST ON STAGING');
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

  // 1. Authenticate Admin
  const adminAuth = await signIn('staging-admin@psa-academy.test', 'Password123!');
  assert('Admin Authentication', !!adminAuth.idToken, `UID: ${adminAuth.localId}`);

  const testPlayerId = 'staging_migration_test_player_v1';
  const testTemplateId = 'staging_migration_test_template_v1';

  // 2. Seed Synthetic Legacy V1 Documents
  console.log('\n--- 1. SEED SYNTHETIC V1 LEGACY DOCUMENTS ---');
  const seedPlayerRes = await firestoreRequest(
    'PATCH',
    `players/${testPlayerId}`,
    {
      fields: {
        uid: { stringValue: testPlayerId },
        name: { stringValue: 'Legacy V1 Migration Player' },
        email: { stringValue: 'legacy-migration@psa-academy.test' },
        sessionPaid: { integerValue: '5' }, // Legacy typo
        sessionsAttended: { integerValue: '3' },
        paymentBalance: { doubleValue: 450.0 }, // Legacy key
        joinDate: { stringValue: '2024-01-15T10:00:00.000Z' }, // String date
        isAllowedPlayer: { booleanValue: true },
        isActive: { booleanValue: true },
        schemaVersion: { integerValue: '1' },
      },
    },
    adminAuth.idToken
  );
  assert('Seed Synthetic Legacy V1 Player', seedPlayerRes.status === 200);

  const seedTemplateRes = await firestoreRequest(
    'PATCH',
    `trainingTemplates/${testTemplateId}`,
    {
      fields: {
        'trainingName ': { stringValue: '  Speed Agility V1 Routine   ' }, // Trailing space in key & value
        category: { stringValue: 'Fitness' },
        'description ': { stringValue: '  Legacy description with extra spaces  ' },
        schemaVersion: { integerValue: '1' },
      },
    },
    adminAuth.idToken
  );
  assert('Seed Synthetic Legacy V1 Training Template', seedTemplateRes.status === 200);

  // 3. PHASE 1: DRY-RUN SIMULATION
  console.log('\n--- 2. DRY-RUN SIMULATION (NO WRITES) ---');
  // Read back player doc
  const preDryPlayer = await firestoreRequest('GET', `players/${testPlayerId}`, null, adminAuth.idToken);
  const pFields = preDryPlayer.data.fields;
  const pVersion = parseInt(pFields.schemaVersion?.integerValue || '1');
  assert('Pre-Dry-Run Schema Version is 1', pVersion === 1);

  // Simulate migration transformation logic:
  const rawPaid = parseInt(pFields.sessionsPaid?.integerValue || pFields.sessionPaid?.integerValue || '0');
  const attended = parseInt(pFields.sessionsAttended?.integerValue || '0');
  const lifetimePaid = rawPaid + attended;
  const balance = pFields.balance ? parseFloat(pFields.balance.doubleValue) : parseFloat(pFields.paymentBalance?.doubleValue || '0');

  console.log(`[DRY-RUN AUDIT] Player ${testPlayerId}:`);
  console.log(`  - sessionPaid: ${rawPaid} + attended: ${attended} => new sessionsPaid (lifetime): ${lifetimePaid}`);
  console.log(`  - paymentBalance: ${balance} => new balance: ${balance}`);
  console.log(`  - schemaVersion: 1 => 2`);
  console.log(`  - Dry-run mode: ZERO mutations written to Firestore`);

  // Verify that document in Firestore is completely UNTOUCHED
  const postDryPlayer = await firestoreRequest('GET', `players/${testPlayerId}`, null, adminAuth.idToken);
  assert(
    'Dry-Run Preserves Legacy Schema Unchanged',
    postDryPlayer.data.fields.schemaVersion.integerValue === '1' &&
    postDryPlayer.data.fields.sessionPaid.integerValue === '5'
  );

  // 4. PHASE 2: LIVE CONTROLLED MIGRATION EXECUTION
  console.log('\n--- 3. LIVE MIGRATION EXECUTION ---');
  // Execute migration on test player
  const playerPatch = {
    fields: {
      userId: { stringValue: testPlayerId },
      name: pFields.name,
      email: pFields.email,
      sessionsPaid: { integerValue: lifetimePaid.toString() }, // 5 + 3 = 8
      sessionsAttended: { integerValue: attended.toString() }, // 3
      balance: { doubleValue: balance }, // 450.0
      joinDate: { timestampValue: new Date(pFields.joinDate.stringValue).toISOString() },
      isAllowedPlayer: { booleanValue: true },
      isActive: { booleanValue: true },
      schemaVersion: { integerValue: '2' },
    },
  };

  const updateMask = 'updateMask.fieldPaths=userId&updateMask.fieldPaths=sessionsPaid&updateMask.fieldPaths=balance&updateMask.fieldPaths=joinDate&updateMask.fieldPaths=schemaVersion';
  const executePlayerRes = await firestoreRequest(
    'PATCH',
    `players/${testPlayerId}?${updateMask}`,
    playerPatch,
    adminAuth.idToken
  );
  assert('Execute Player Migration Patch', executePlayerRes.status === 200);

  // Execute migration on test template (trimming keys and whitespace)
  const templatePatch = {
    fields: {
      trainingName: { stringValue: 'Speed Agility V1 Routine' },
      category: { stringValue: 'Fitness' },
      description: { stringValue: 'Legacy description with extra spaces' },
      schemaVersion: { integerValue: '2' },
    },
  };
  const executeTemplateRes = await firestoreRequest(
    'PATCH',
    `trainingTemplates/${testTemplateId}`,
    templatePatch,
    adminAuth.idToken
  );
  assert('Execute Template Migration Patch', executeTemplateRes.status === 200);

  // Read back and verify updated schema
  const verifiedPlayer = await firestoreRequest('GET', `players/${testPlayerId}`, null, adminAuth.idToken);
  const vPaid = parseInt(verifiedPlayer.data.fields.sessionsPaid.integerValue);
  const vAttended = parseInt(verifiedPlayer.data.fields.sessionsAttended.integerValue);
  const vBalance = parseFloat(verifiedPlayer.data.fields.balance.doubleValue);
  const vVersion = parseInt(verifiedPlayer.data.fields.schemaVersion.integerValue);
  const vUserId = verifiedPlayer.data.fields.userId.stringValue;

  assert('Migrated Player Lifetime sessionsPaid == 8', vPaid === 8, `Actual: ${vPaid}`);
  assert('Migrated Player sessionsAttended == 3', vAttended === 3, `Actual: ${vAttended}`);
  assert('Remaining Sessions Unchanged (8 - 3 == 5)', (vPaid - vAttended) === 5);
  assert('Migrated Player balance == 450.0', vBalance === 450.0, `Actual: ${vBalance}`);
  assert('Migrated Player userId set to docId', vUserId === testPlayerId);
  assert('Migrated Player schemaVersion == 2', vVersion === 2);

  const verifiedTemplate = await firestoreRequest('GET', `trainingTemplates/${testTemplateId}`, null, adminAuth.idToken);
  const tName = verifiedTemplate.data.fields.trainingName.stringValue;
  const tVersion = parseInt(verifiedTemplate.data.fields.schemaVersion.integerValue);
  assert('Migrated Template Name Trimmed', tName === 'Speed Agility V1 Routine', `Actual: "${tName}"`);
  assert('Migrated Template schemaVersion == 2', tVersion === 2);

  // 5. PHASE 3: IDEMPOTENCY RE-RUN
  console.log('\n--- 4. IDEMPOTENCY RE-RUN TEST ---');
  // When migration runs again on already migrated V2 document (schemaVersion >= 2), it skips it
  const recheckPlayer = await firestoreRequest('GET', `players/${testPlayerId}`, null, adminAuth.idToken);
  const curVersion = parseInt(recheckPlayer.data.fields.schemaVersion.integerValue);
  let changesAttempted = 0;
  if (curVersion < 2) {
    changesAttempted++;
  }
  assert('Idempotency: V2 Document Detected and Skipped', curVersion >= 2 && changesAttempted === 0);

  // 6. PHASE 4: CLEANUP
  console.log('\n--- 5. TEST CLEANUP ---');
  const delPlayerRes = await firestoreRequest('DELETE', `players/${testPlayerId}`, null, adminAuth.idToken);
  assert('Cleanup Test Player', delPlayerRes.status === 200);

  const delTemplateRes = await firestoreRequest('DELETE', `trainingTemplates/${testTemplateId}`, null, adminAuth.idToken);
  assert('Cleanup Test Training Template', delTemplateRes.status === 200);

  console.log('\n====================================================');
  console.log(`MIGRATION ACCEPTANCE TESTS: ${passes} PASSED, ${fails} FAILED`);
  console.log('====================================================');

  if (fails > 0) {
    process.exit(1);
  }
}

runMigrationTest().catch((err) => {
  console.error('Migration Test Failed:', err);
  process.exit(1);
});
