const { describe, it, before, after, beforeEach } = require('node:test');
const assert = require('node:assert');
const { initializeTestEnvironment } = require('@firebase/rules-unit-testing');

const PROJECT_ID = 'psa-academy-65088';

describe('Attendance Firestore Integration Tests (Real Transactions)', { concurrency: 1 }, () => {
  let testEnv;

  before(async () => {
    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        host: '127.0.0.1',
        port: 8080,
      },
    });
  });

  after(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  beforeEach(async () => {
    await testEnv.clearFirestore();
  });

  // Executes the exact atomic attendance transaction implemented by AttendanceRepositoryImpl
  async function recordAttendanceAtomic(adminDb, {
    playerId,
    coachId,
    coachName = 'Coach Ahmed',
    type = 'fitness',
    sessionPrice = 50.0,
    scanTime = new Date(),
  }) {
    const trimmedCoachId = (coachId || '').trim();
    const trimmedPlayerId = (playerId || '').trim();

    if (trimmedCoachId && trimmedCoachId === trimmedPlayerId) {
      throw new Error('A coach cannot check themselves in as a player.');
    }

    const playerRef = adminDb.collection('players').doc(trimmedPlayerId);
    const attendanceRef = adminDb.collection('attendance').doc();

    return await adminDb.runTransaction(async (transaction) => {
      const playerDoc = await transaction.get(playerRef);
      if (!playerDoc.exists) {
        throw new Error('Player does not exist in academy database.');
      }

      const data = playerDoc.data() || {};
      const isActive = data.isActive !== false;
      if (!isActive) {
        throw new Error('Player account is currently deactivated.');
      }

      const isAllowed = data.isAllowedPlayer !== false;
      const schemaVersion = data.schemaVersion || 1;
      const rawPaid = data.sessionsPaid ?? data.sessionPaid ?? 0;
      const rawAttended = data.sessionsAttended ?? 0;

      const totalLifetimePaid = schemaVersion >= 2 ? rawPaid : (rawPaid + rawAttended);
      const remainingBeforeCheckIn = totalLifetimePaid - rawAttended;

      if (remainingBeforeCheckIn <= 0 && !isAllowed) {
        throw new Error('Player has 0 remaining sessions and is not authorized for overdraft check-in.');
      }

      // Duplicate check: 15 minutes window
      if (data.lastAttendance) {
        const lastAttDate = data.lastAttendance.toDate
          ? data.lastAttendance.toDate()
          : new Date(data.lastAttendance);
        const diffMinutes = (scanTime.getTime() - lastAttDate.getTime()) / (1000 * 60);
        if (diffMinutes < 15 && diffMinutes >= 0) {
          throw new Error(`Duplicate check-in detected. Player already checked in ${Math.floor(diffMinutes)} minute(s) ago.`);
        }
      }

      const currentBalance = Number(data.balance ?? data.paymentBalance ?? 0);
      const newAttended = rawAttended + 1;
      const newBalance = currentBalance - sessionPrice;

      // Update player
      transaction.update(playerRef, {
        schemaVersion: 2,
        sessionsPaid: totalLifetimePaid,
        sessionsAttended: newAttended,
        balance: newBalance,
        lastAttendance: scanTime,
      });

      // Create attendance
      transaction.set(attendanceRef, {
        id: attendanceRef.id,
        playerId: trimmedPlayerId,
        playerName: data.name || 'Player',
        coachId: trimmedCoachId,
        coachName: coachName,
        date: scanTime,
        status: 'present',
        type: type,
        createdAt: scanTime,
      });

      return {
        attendanceId: attendanceRef.id,
        newAttended,
        remainingSessions: totalLifetimePaid - newAttended,
        newBalance,
      };
    });
  }

  // CASE A: Standard attendance
  it('CASE A: Normal attendance records attendance and decrements remaining sessions', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const adminDb = context.firestore();
      await adminDb.collection('players').doc('player_a').set({
        name: 'Player A',
        sessionsPaid: 10,
        sessionsAttended: 4,
        balance: 1000.0,
        isAllowedPlayer: false,
        isActive: true,
        schemaVersion: 2,
      });

      const result = await recordAttendanceAtomic(adminDb, {
        playerId: 'player_a',
        coachId: 'coach_1',
        type: 'fitness',
      });

      assert.strictEqual(result.newAttended, 5);
      assert.strictEqual(result.remainingSessions, 5);

      // Verify player doc
      const playerSnap = await adminDb.collection('players').doc('player_a').get();
      assert.strictEqual(playerSnap.data().sessionsAttended, 5);
      assert.strictEqual(playerSnap.data().sessionsPaid - playerSnap.data().sessionsAttended, 5);

      // Verify exactly one attendance doc created
      const attDoc = await adminDb.collection('attendance').doc(result.attendanceId).get();
      assert.strictEqual(attDoc.exists, true);
    });
  });

  // CASE B: Concurrency test - two simultaneous transactions with 1 remaining session
  it('CASE B: Two simultaneous attendance transactions with 1 session remaining -> exactly 1 succeeds, 1 fails', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const adminDb = context.firestore();
      await adminDb.collection('players').doc('player_b').set({
        name: 'Player B',
        sessionsPaid: 1,
        sessionsAttended: 0,
        balance: 100.0,
        isAllowedPlayer: false, // Disallowed overdraft
        isActive: true,
        schemaVersion: 2,
      });

      // Launch two simultaneous transactions
      const tx1 = recordAttendanceAtomic(adminDb, {
        playerId: 'player_b',
        coachId: 'coach_1',
        type: 'fitness',
      });
      const tx2 = recordAttendanceAtomic(adminDb, {
        playerId: 'player_b',
        coachId: 'coach_2',
        type: 'fitness',
      });

      const results = await Promise.allSettled([tx1, tx2]);

      const successes = results.filter((r) => r.status === 'fulfilled');
      const failures = results.filter((r) => r.status === 'rejected');

      assert.strictEqual(successes.length, 1, 'Exactly one transaction must succeed');
      assert.strictEqual(failures.length, 1, 'Exactly one transaction must fail');
      assert.match(failures[0].reason.message, /0 remaining sessions/);

      // Verify final state
      const playerSnap = await adminDb.collection('players').doc('player_b').get();
      const data = playerSnap.data();
      assert.strictEqual(data.sessionsAttended, 1, 'sessionsAttended must be exactly 1, never 2');
      const remaining = data.sessionsPaid - data.sessionsAttended;
      assert.strictEqual(remaining, 0, 'remaining must be 0, never -1');

      // Exactly one attendance document created
      const successfulResult = successes[0].value;
      const attDoc = await adminDb.collection('attendance').doc(successfulResult.attendanceId).get();
      assert.strictEqual(attDoc.exists, true);
    });
  });

  // CASE C: 0 sessions remaining, isAllowedPlayer = false -> must fail
  it('CASE C: 0 sessions remaining and isAllowedPlayer = false must fail', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const adminDb = context.firestore();
      await adminDb.collection('players').doc('player_c').set({
        name: 'Player C',
        sessionsPaid: 5,
        sessionsAttended: 5,
        isAllowedPlayer: false,
        isActive: true,
        schemaVersion: 2,
      });

      await assert.rejects(
        () =>
          recordAttendanceAtomic(adminDb, {
            playerId: 'player_c',
            coachId: 'coach_1',
          }),
        /0 remaining sessions/
      );
    });
  });

  // CASE D: isAllowedPlayer = true -> overdraft permitted, sessionsAttended may exceed sessionsPaid
  it('CASE D: isAllowedPlayer = true allows overdraft (sessionsAttended exceeds sessionsPaid)', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const adminDb = context.firestore();
      await adminDb.collection('players').doc('player_d').set({
        name: 'Player D (VIP)',
        sessionsPaid: 5,
        sessionsAttended: 5,
        isAllowedPlayer: true,
        isActive: true,
        schemaVersion: 2,
      });

      const result = await recordAttendanceAtomic(adminDb, {
        playerId: 'player_d',
        coachId: 'coach_1',
      });

      assert.strictEqual(result.newAttended, 6);
      assert.strictEqual(result.remainingSessions, -1);

      const playerSnap = await adminDb.collection('players').doc('player_d').get();
      assert.strictEqual(playerSnap.data().sessionsAttended, 6);
    });
  });

  // CASE E: coachId == playerId -> must fail
  it('CASE E: coach scanning themselves as player must fail', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const adminDb = context.firestore();
      await adminDb.collection('players').doc('user_123').set({
        name: 'Self Coach Player',
        sessionsPaid: 10,
        sessionsAttended: 0,
        isActive: true,
        schemaVersion: 2,
      });

      await assert.rejects(
        () =>
          recordAttendanceAtomic(adminDb, {
            playerId: 'user_123',
            coachId: 'user_123',
          }),
        /A coach cannot check themselves in as a player/
      );
    });
  });

  // CASE F: Deactivated player -> must fail
  it('CASE F: Deactivated player must fail check-in', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const adminDb = context.firestore();
      await adminDb.collection('players').doc('player_f').set({
        name: 'Inactive Player',
        sessionsPaid: 10,
        sessionsAttended: 0,
        isActive: false, // Deactivated
        schemaVersion: 2,
      });

      await assert.rejects(
        () =>
          recordAttendanceAtomic(adminDb, {
            playerId: 'player_f',
            coachId: 'coach_1',
          }),
        /Player account is currently deactivated/
      );
    });
  });

  // CASE G: Duplicate scan inside 15-minute window -> must fail
  it('CASE G: Duplicate check-in within 15 minutes must fail', async () => {
    const now = new Date();
    const tenMinutesAgo = new Date(now.getTime() - 10 * 60 * 1000);

    await testEnv.withSecurityRulesDisabled(async (context) => {
      const adminDb = context.firestore();
      await adminDb.collection('players').doc('player_g').set({
        name: 'Player G',
        sessionsPaid: 10,
        sessionsAttended: 1,
        lastAttendance: tenMinutesAgo,
        isActive: true,
        schemaVersion: 2,
      });

      await assert.rejects(
        () =>
          recordAttendanceAtomic(adminDb, {
            playerId: 'player_g',
            coachId: 'coach_1',
            scanTime: now,
          }),
        /Duplicate check-in detected/
      );
    });
  });

  // CASE H: Fitness attendance record type
  it('CASE H: Fitness attendance records type "fitness"', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const adminDb = context.firestore();
      await adminDb.collection('players').doc('player_h').set({
        name: 'Player H',
        sessionsPaid: 5,
        sessionsAttended: 0,
        isActive: true,
        schemaVersion: 2,
      });

      const result = await recordAttendanceAtomic(adminDb, {
        playerId: 'player_h',
        coachId: 'coach_1',
        type: 'fitness',
      });

      const attDoc = await adminDb.collection('attendance').doc(result.attendanceId).get();
      assert.strictEqual(attDoc.data().type, 'fitness');
    });
  });

  // CASE I: Recovery attendance record type
  it('CASE I: Recovery attendance records type "recovery"', async () => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const adminDb = context.firestore();
      await adminDb.collection('players').doc('player_i').set({
        name: 'Player I',
        sessionsPaid: 5,
        sessionsAttended: 0,
        isActive: true,
        schemaVersion: 2,
      });

      const result = await recordAttendanceAtomic(adminDb, {
        playerId: 'player_i',
        coachId: 'coach_1',
        type: 'recovery',
      });

      const attDoc = await adminDb.collection('attendance').doc(result.attendanceId).get();
      assert.strictEqual(attDoc.data().type, 'recovery');
    });
  });
});
