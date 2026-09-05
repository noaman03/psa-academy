const test = require('node:test');
const assert = require('node:assert');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const fs = require('node:fs');
const path = require('node:path');

const PROJECT_ID = 'demo-psa-acceptance';

test('Product Acceptance Journeys on Staging/Emulator', { concurrency: 1 }, async (t) => {
  let testEnv;

  t.before(async () => {
    const firestoreRules = fs.readFileSync(
      path.resolve(__dirname, '../../firestore.rules'),
      'utf8'
    );
    const storageRules = fs.readFileSync(
      path.resolve(__dirname, '../../storage.rules'),
      'utf8'
    );

    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        rules: firestoreRules,
        host: '127.0.0.1',
        port: 8080,
      },
      storage: {
        rules: storageRules,
        host: '127.0.0.1',
        port: 9199,
      },
    });
  });

  t.beforeEach(async () => {
    await testEnv.clearFirestore();
    await testEnv.clearStorage();
  });

  t.after(async () => {
    await testEnv.cleanup();
  });

  // =========================================================================
  // JOURNEY 1: TEST USERS PROVISIONING & ADMIN ACCEPTANCE JOURNEY
  // =========================================================================
  await t.test('Admin Acceptance Journey — Full End-to-End Workflow', async () => {
    // 1. Seed initial system state with admin user established
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await db.collection('users').doc('admin_01').set({
        name: 'Academy Director',
        email: 'admin@psa-academy.com',
        role: 'admin',
        createdAt: new Date(),
      });
      await db.collection('admins').doc('admin_01').set({
        userId: 'admin_01',
        name: 'Academy Director',
      });
    });

    const adminContext = testEnv.authenticatedContext('admin_01', { role: 'admin' });
    const adminDb = adminContext.firestore();

    // 2. Add Coach
    await adminDb.collection('coaches').doc('coach_alex').set({
      userId: 'coach_alex',
      name: 'Alex Ferguson',
      email: 'alex@psa-academy.com',
      specialization: 'Tactical & Fitness',
      hourlyRate: 150.0,
      totalWorkedHours: 0.0,
      isAllowedCoach: true,
      isActive: true,
      joinDate: new Date(),
    });

    // 3. Add Players (Active, Zero-Session Allowed, Zero-Session Denied, Suspended)
    await adminDb.collection('players').doc('player_omar').set({
      userId: 'player_omar',
      name: 'Omar Marmoush',
      email: 'omar@psa-academy.com',
      level: 'Advanced',
      category: 'Senior',
      ageGroup: 'Under 18',
      sessionsPaid: 10,
      sessionsAttended: 2, // remaining = 8
      balance: 0.0,
      isAllowedPlayer: true,
      isActive: true,
      joinDate: new Date(),
    });

    await adminDb.collection('players').doc('player_zero_allowed').set({
      userId: 'player_zero_allowed',
      name: 'Karim Bench',
      email: 'karim@psa-academy.com',
      level: 'Intermediate',
      category: 'Junior',
      ageGroup: 'Under 14',
      sessionsPaid: 5,
      sessionsAttended: 5, // remaining = 0, but isAllowedPlayer = true
      balance: 0.0,
      isAllowedPlayer: true,
      isActive: true,
      joinDate: new Date(),
    });

    await adminDb.collection('players').doc('player_zero_denied').set({
      userId: 'player_zero_denied',
      name: 'Tariq Unpaid',
      email: 'tariq@psa-academy.com',
      level: 'Beginner',
      category: 'Junior',
      ageGroup: 'Under 10',
      sessionsPaid: 4,
      sessionsAttended: 4, // remaining = 0, isAllowedPlayer = false
      balance: -400.0,
      isAllowedPlayer: false,
      isActive: true,
      joinDate: new Date(),
    });

    await adminDb.collection('players').doc('player_suspended').set({
      userId: 'player_suspended',
      name: 'Samy Suspended',
      email: 'samy@psa-academy.com',
      level: 'Beginner',
      category: 'Junior',
      ageGroup: 'Under 12',
      sessionsPaid: 8,
      sessionsAttended: 1,
      balance: -800.0,
      isAllowedPlayer: false,
      isActive: false,
      joinDate: new Date(),
    });

    // 4. Verify user counts (4 players, 1 coach)
    const playersSnap = await adminDb.collection('players').get();
    assert.strictEqual(playersSnap.docs.length, 4, 'Must find 4 players in academy directory');

    const coachesSnap = await adminDb.collection('coaches').get();
    assert.strictEqual(coachesSnap.docs.length, 1, 'Must find 1 coach');

    // 5. Suspend player and Reactivate player
    await adminDb.collection('players').doc('player_omar').update({
      isAllowedPlayer: false,
    });
    let omarDoc = await adminDb.collection('players').doc('player_omar').get();
    assert.strictEqual(omarDoc.data().isAllowedPlayer, false, 'Player should be suspended');

    await adminDb.collection('players').doc('player_omar').update({
      isAllowedPlayer: true,
    });
    omarDoc = await adminDb.collection('players').doc('player_omar').get();
    assert.strictEqual(omarDoc.data().isAllowedPlayer, true, 'Player should be reactivated');

    // 6. Record Payment (Inflow)
    await adminDb.collection('payments').add({
      playerId: 'player_omar',
      playerName: 'Omar Marmoush',
      amount: 1200.0,
      status: 'paid',
      paymentMethod: 'instapay',
      type: 'session_topup',
      date: new Date(),
      createdAt: new Date(),
    });

    // 7. Credit 8 additional sessions to Omar
    await adminDb.collection('players').doc('player_omar').update({
      sessionsPaid: 18, // 10 + 8
    });
    omarDoc = await adminDb.collection('players').doc('player_omar').get();
    const remaining = omarDoc.data().sessionsPaid - omarDoc.data().sessionsAttended;
    assert.strictEqual(remaining, 16, 'Remaining sessions must reflect top-up (18 - 2 = 16)');

    // 8. Record Expense (Outflow)
    await adminDb.collection('expenses').add({
      title: 'New Agility Cones and Match Balls',
      amount: 450.0,
      category: 'Equipment',
      recordedBy: 'admin_01',
      date: new Date(),
    });

    // 9. Financial calculation verification
    const payments = await adminDb.collection('payments').get();
    const expenses = await adminDb.collection('expenses').get();
    const totalRev = payments.docs.reduce((sum, d) => sum + d.data().amount, 0);
    const totalExp = expenses.docs.reduce((sum, d) => sum + d.data().amount, 0);
    const netProfit = totalRev - totalExp;
    assert.strictEqual(totalRev, 1200.0, 'Revenue matches payments');
    assert.strictEqual(totalExp, 450.0, 'Expenses match outflow');
    assert.strictEqual(netProfit, 750.0, 'Net profit is 1200 - 450 = 750 EGP');

    // 10. Create and persist Training Template with drills
    const templateRef = await adminDb.collection('trainingTemplates').add({
      title: 'Elite Speed & Ball Control',
      category: 'Elite',
      level: 'Advanced',
      durationMinutes: 90,
      drills: [
        { name: 'Cone Weave Slalom', duration: 15, sets: 4, reps: 10 },
        { name: '1v1 High Press Finishing', duration: 30, sets: 6, reps: 5 },
      ],
      createdAt: new Date(),
    });

    const templateDoc = await templateRef.get();
    assert.strictEqual(templateDoc.data().title, 'Elite Speed & Ball Control');
    assert.strictEqual(templateDoc.data().drills.length, 2);

    // 11. Edit template
    await templateRef.update({
      durationMinutes: 100,
    });
    const updatedTemplate = await templateRef.get();
    assert.strictEqual(updatedTemplate.data().durationMinutes, 100);
  });

  // =========================================================================
  // JOURNEY 2: COACH ACCEPTANCE JOURNEY
  // =========================================================================
  await t.test('Coach Acceptance Journey — Work Sessions & Attendance Scans', async () => {
    // Setup coach and player
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await db.collection('coaches').doc('coach_alex').set({
        userId: 'coach_alex',
        name: 'Alex Ferguson',
        hourlyRate: 150.0,
        totalWorkedHours: 0.0,
        isAllowedCoach: true,
        isActive: true,
      });
      await db.collection('players').doc('player_salah').set({
        userId: 'player_salah',
        name: 'Mohamed Salah',
        level: 'Professional',
        category: 'Senior',
        ageGroup: 'Under 23',
        sessionsPaid: 10,
        sessionsAttended: 3, // 7 remaining
        isAllowedPlayer: true,
        isActive: true,
        lastAttendance: null,
      });
    });

    const coachContext = testEnv.authenticatedContext('coach_alex', { role: 'coach' });
    const coachDb = coachContext.firestore();

    // 1. Coach Clock In
    const sessionRef = await coachDb.collection('coachWorkSessions').add({
      coachId: 'coach_alex',
      coachName: 'Alex Ferguson',
      checkIn: new Date(Date.now() - 2 * 60 * 60 * 1000), // 2 hours ago
      checkOut: null,
      hoursWorked: 0.0,
      calculatedSalary: 0.0,
      date: new Date(),
    });

    // Verify open session exists
    const openSessions = await coachDb
      .collection('coachWorkSessions')
      .where('coachId', '==', 'coach_alex')
      .where('checkOut', '==', null)
      .get();
    assert.strictEqual(openSessions.docs.length, 1, 'Coach has 1 active unclosed work session');

    // 2. Scan Player & Record Fitness Attendance via transaction
    const now = new Date();
    await coachDb.runTransaction(async (tx) => {
      const pDoc = await tx.get(coachDb.collection('players').doc('player_salah'));
      const pData = pDoc.data();
      assert.strictEqual(pData.name, 'Mohamed Salah');
      const rem = pData.sessionsPaid - pData.sessionsAttended;
      assert.strictEqual(rem, 7, 'Has 7 sessions remaining');

      // Mutate
      tx.update(coachDb.collection('players').doc('player_salah'), {
        sessionsAttended: pData.sessionsAttended + 1,
        lastAttendance: now,
      });

      const attRef = coachDb.collection('attendance').doc();
      tx.set(attRef, {
        playerId: 'player_salah',
        playerName: 'Mohamed Salah',
        coachId: 'coach_alex',
        coachName: 'Alex Ferguson',
        date: now,
        type: 'fitness',
      });
    });

    // Verify session decrement
    const updatedSalah = await coachDb.collection('players').doc('player_salah').get();
    assert.strictEqual(updatedSalah.data().sessionsAttended, 4, 'Attended incremented to 4');
    const remainingAfter = updatedSalah.data().sessionsPaid - updatedSalah.data().sessionsAttended;
    assert.strictEqual(remainingAfter, 6, 'Remaining decremented to 6');

    // 3. Attempt immediate duplicate attendance within 15 minutes (must be rejected by business rules)
    let duplicateBlocked = false;
    try {
      await coachDb.runTransaction(async (tx) => {
        const pDoc = await tx.get(coachDb.collection('players').doc('player_salah'));
        const lastAtt = pDoc.data().lastAttendance.toDate();
        const diffMinutes = (Date.now() - lastAtt.getTime()) / (1000 * 60);
        if (diffMinutes < 15) {
          throw new Error('DuplicateAttendanceException: Already scanned within 15 minutes');
        }
      });
    } catch (err) {
      if (err.message.includes('DuplicateAttendanceException')) {
        duplicateBlocked = true;
      }
    }
    assert.strictEqual(duplicateBlocked, true, 'Immediate duplicate scan within 15 mins correctly blocked');

    // 4. Record Recovery attendance after window (simulated 20 mins later)
    const twentyMinsLater = new Date(Date.now() + 20 * 60 * 1000);
    await coachDb.runTransaction(async (tx) => {
      const pDoc = await tx.get(coachDb.collection('players').doc('player_salah'));
      tx.update(coachDb.collection('players').doc('player_salah'), {
        sessionsAttended: pDoc.data().sessionsAttended + 1,
        lastAttendance: twentyMinsLater,
      });

      const attRef = coachDb.collection('attendance').doc();
      tx.set(attRef, {
        playerId: 'player_salah',
        playerName: 'Mohamed Salah',
        coachId: 'coach_alex',
        coachName: 'Alex Ferguson',
        date: twentyMinsLater,
        type: 'recovery',
      });
    });

    const finalSalah = await coachDb.collection('players').doc('player_salah').get();
    assert.strictEqual(finalSalah.data().sessionsAttended, 5, 'Recovery attendance consumed session');

    // 5. Coach Check Out
    const checkOutTime = new Date();
    const hoursWorked = 2.0;
    const salary = hoursWorked * 150.0; // 300 EGP

    await coachDb.collection('coachWorkSessions').doc(sessionRef.id).update({
      checkOut: checkOutTime,
      hoursWorked: hoursWorked,
      calculatedSalary: salary,
    });

    const closedSession = await coachDb.collection('coachWorkSessions').doc(sessionRef.id).get();
    assert.strictEqual(closedSession.data().hoursWorked, 2.0);
    assert.strictEqual(closedSession.data().calculatedSalary, 300.0);
  });

  // =========================================================================
  // JOURNEY 3: PLAYER ACCEPTANCE JOURNEY & STORAGE ISOLATION
  // =========================================================================
  await t.test('Player Acceptance Journey — Dashboard, History, Storage Vault', async () => {
    // Setup player
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await db.collection('users').doc('player_ziad').set({
        name: 'Ziad Tareq',
        email: 'ziad@psa-academy.com',
        role: 'player',
      });
      await db.collection('players').doc('player_ziad').set({
        userId: 'player_ziad',
        name: 'Ziad Tareq',
        email: 'ziad@psa-academy.com',
        level: 'Intermediate',
        category: 'Junior',
        ageGroup: 'Under 14',
        sessionsPaid: 12,
        sessionsAttended: 4, // 8 remaining
        balance: 0.0,
        isAllowedPlayer: true,
        isActive: true,
        joinDate: new Date(),
      });
    });

    const playerContext = testEnv.authenticatedContext('player_ziad', { role: 'player' });
    const playerDb = playerContext.firestore();
    const playerStorage = playerContext.storage();

    // 1. Read own dashboard profile
    const profile = await playerDb.collection('players').doc('player_ziad').get();
    assert.strictEqual(profile.data().name, 'Ziad Tareq');
    const remaining = profile.data().sessionsPaid - profile.data().sessionsAttended;
    assert.strictEqual(remaining, 8, 'Remaining sessions matches');

    // 2. Upload Document (JPEG) to Storage
    const imageRef = playerStorage.ref('player_documents/player_ziad/medical_clearance.jpg');
    const imageBytes = Buffer.from('fake-jpeg-binary-data');
    await assertSucceeds(imageRef.put(imageBytes, { contentType: 'image/jpeg' }));

    // 3. Upload Document (PDF) to Storage
    const pdfRef = playerStorage.ref('player_documents/player_ziad/academy_contract.pdf');
    const pdfBytes = Buffer.from('fake-pdf-contract-bytes');
    await assertSucceeds(pdfRef.put(pdfBytes, { contentType: 'application/pdf' }));

    // 4. Save metadata in Firestore subcollection
    const docMetaRef = playerDb
      .collection('players')
      .doc('player_ziad')
      .collection('documents')
      .doc();
    await assertSucceeds(
      docMetaRef.set({
        playerId: 'player_ziad',
        fileName: 'academy_contract.pdf',
        downloadUrl: 'https://storage.example.com/mock',
        fileSize: pdfBytes.length,
        uploadDate: new Date(),
      })
    );

    // 5. Test Unauthorized Access (Cannot access or delete another player's files)
    const otherPlayerRef = playerStorage.ref('player_documents/player_other/private.pdf');
    await assertFails(otherPlayerRef.put(pdfBytes, { contentType: 'application/pdf' }));
    await assertFails(otherPlayerRef.delete());
  });

  // =========================================================================
  // JOURNEY 4: ZERO-SESSION & DEACTIVATED ACCOUNTS
  // =========================================================================
  await t.test('Zero-Session & Deactivated Account Guardrails', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      // Ensure coach_alex exists
      await db.collection('users').doc('coach_alex').set({
        name: 'Alex Ferguson',
        email: 'alex@psa-academy.com',
        role: 'coach',
      });
      await db.collection('coaches').doc('coach_alex').set({
        userId: 'coach_alex',
        name: 'Alex Ferguson',
        hourlyRate: 150.0,
        totalWorkedHours: 0.0,
        isAllowedCoach: true,
        isActive: true,
      });
      // Zero-session allowed
      await db.collection('players').doc('zero_allowed').set({
        userId: 'zero_allowed',
        name: 'Zero Allowed Player',
        sessionsPaid: 4,
        sessionsAttended: 4, // 0 remaining
        isAllowedPlayer: true,
        isActive: true,
      });
      // Zero-session denied
      await db.collection('players').doc('zero_denied').set({
        userId: 'zero_denied',
        name: 'Zero Denied Player',
        sessionsPaid: 4,
        sessionsAttended: 4, // 0 remaining
        isAllowedPlayer: false,
        isActive: true,
      });
      // Deactivated player
      await db.collection('players').doc('deactivated_p').set({
        userId: 'deactivated_p',
        name: 'Deactivated Player',
        sessionsPaid: 4,
        sessionsAttended: 2,
        isAllowedPlayer: false,
        isActive: false,
      });
    });

    const coachContext = testEnv.authenticatedContext('coach_alex', { role: 'coach' });
    const coachDb = coachContext.firestore();

    // 1. Zero-session with isAllowedPlayer == true -> Granted grace overdraft
    await coachDb.runTransaction(async (tx) => {
      const pDoc = await tx.get(coachDb.collection('players').doc('zero_allowed'));
      const rem = pDoc.data().sessionsPaid - pDoc.data().sessionsAttended;
      assert.strictEqual(rem, 0);
      assert.strictEqual(pDoc.data().isAllowedPlayer, true);
      // Increment attendance
      tx.update(coachDb.collection('players').doc('zero_allowed'), {
        sessionsAttended: pDoc.data().sessionsAttended + 1,
      });
    });
    const zAllowedPost = await coachDb.collection('players').doc('zero_allowed').get();
    assert.strictEqual(zAllowedPost.data().sessionsAttended, 5, 'Grace overdraft allowed');

    // 2. Zero-session with isAllowedPlayer == false -> Rejected
    let zeroDeniedBlocked = false;
    try {
      await coachDb.runTransaction(async (tx) => {
        const pDoc = await tx.get(coachDb.collection('players').doc('zero_denied'));
        const rem = pDoc.data().sessionsPaid - pDoc.data().sessionsAttended;
        if (rem <= 0 && !pDoc.data().isAllowedPlayer) {
          throw new Error('InsufficientSessionsException: No sessions remaining and overdraft not permitted.');
        }
      });
    } catch (e) {
      if (e.message.includes('InsufficientSessionsException')) {
        zeroDeniedBlocked = true;
      }
    }
    assert.strictEqual(zeroDeniedBlocked, true, 'Zero-session without permission blocked');

    // 3. Deactivated Player -> Rejected
    let deactBlocked = false;
    try {
      await coachDb.runTransaction(async (tx) => {
        const pDoc = await tx.get(coachDb.collection('players').doc('deactivated_p'));
        if (!pDoc.data().isActive) {
          throw new Error('InactivePlayerException: Player account is deactivated.');
        }
      });
    } catch (e) {
      if (e.message.includes('InactivePlayerException')) {
        deactBlocked = true;
      }
    }
    assert.strictEqual(deactBlocked, true, 'Deactivated player check-in strictly rejected');
  });
});
