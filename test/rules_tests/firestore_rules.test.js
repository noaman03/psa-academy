const { describe, it, before, after, beforeEach } = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');

const PROJECT_ID = 'psa-academy-65088';

describe('Firestore Security Rules', () => {
  let testEnv;

  before(async () => {
    const rulesPath = path.resolve(__dirname, '../../firestore.rules');
    const rules = fs.readFileSync(rulesPath, 'utf8');

    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        rules,
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

    // Seed basic user roles using admin context
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();
      await db.collection('users').doc('player_1').set({
        id: 'player_1',
        role: 'player',
        email: 'player1@psa.com',
        name: 'Player One',
      });
      await db.collection('users').doc('coach_1').set({
        id: 'coach_1',
        role: 'coach',
        email: 'coach1@psa.com',
        name: 'Coach One',
      });
      await db.collection('users').doc('admin_1').set({
        id: 'admin_1',
        role: 'admin',
        email: 'admin1@psa.com',
        name: 'Admin One',
      });

      // Seed player document
      await db.collection('players').doc('player_1').set({
        userId: 'player_1',
        name: 'Player One',
        sessionsPaid: 10,
        sessionsAttended: 2,
        balance: 1000.0,
        isAllowedPlayer: true,
        schemaVersion: 2,
      });

      // Seed coach document
      await db.collection('coaches').doc('coach_1').set({
        userId: 'coach_1',
        name: 'Coach One',
        hourlyRate: 75.0,
        totalWorkedHours: 10.0,
        isAllowedCoach: true,
      });

      // Seed payments and expenses
      await db.collection('payments').doc('pay_1').set({
        playerId: 'player_1',
        amount: 500.0,
        status: 'paid',
      });
      await db.collection('expenses').doc('exp_1').set({
        title: 'Balls',
        amount: 200.0,
      });
    });
  });

  describe('Unauthenticated User', () => {
    it('must fail to read players', async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(db.collection('players').get());
    });

    it('must fail to read coaches', async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(db.collection('coaches').get());
    });

    it('must fail to read admins', async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(db.collection('admin').get());
    });

    it('must fail to read payments', async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(db.collection('payments').get());
    });

    it('must fail to read expenses', async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(db.collection('expenses').get());
    });

    it('must fail to create attendance', async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(
        db.collection('attendance').add({
          playerId: 'player_1',
          date: new Date(),
        })
      );
    });

    it('must fail to change user data', async () => {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(
        db.collection('users').doc('player_1').update({ name: 'Hacked' })
      );
    });
  });

  describe('Player User', () => {
    it('allowed to read players, coaches, and own user doc', async () => {
      const db = testEnv.authenticatedContext('player_1').firestore();
      await assertSucceeds(db.collection('players').doc('player_1').get());
      await assertSucceeds(db.collection('coaches').doc('coach_1').get());
      await assertSucceeds(db.collection('users').doc('player_1').get());
    });

    it('must NOT be able to modify own role', async () => {
      const db = testEnv.authenticatedContext('player_1').firestore();
      await assertFails(
        db.collection('users').doc('player_1').update({ role: 'admin' })
      );
    });

    it('must NOT be able to create user doc with admin or coach role', async () => {
      const db = testEnv.authenticatedContext('new_user').firestore();
      await assertFails(
        db.collection('users').doc('new_user').set({
          id: 'new_user',
          role: 'admin',
        })
      );
      await assertFails(
        db.collection('users').doc('new_user').set({
          id: 'new_user',
          role: 'coach',
        })
      );
    });

    it('must NOT be able to modify another player profile', async () => {
      const db = testEnv.authenticatedContext('player_1').firestore();
      await assertFails(
        db.collection('players').doc('player_2').set({
          userId: 'player_2',
          name: 'Player Two',
        })
      );
    });

    it('must NOT be able to increase sessionsPaid, decrease sessionsAttended, or alter balance', async () => {
      const db = testEnv.authenticatedContext('player_1').firestore();
      // Increase sessionsPaid
      await assertFails(
        db.collection('players').doc('player_1').update({ sessionsPaid: 20 })
      );
      // Decrease sessionsAttended
      await assertFails(
        db.collection('players').doc('player_1').update({ sessionsAttended: 0 })
      );
      // Alter balance
      await assertFails(
        db.collection('players').doc('player_1').update({ balance: 5000.0 })
      );
    });

    it('must NOT be able to change isAllowedPlayer or schemaVersion', async () => {
      const db = testEnv.authenticatedContext('player_1').firestore();
      await assertFails(
        db.collection('players').doc('player_1').update({ isAllowedPlayer: false })
      );
      await assertFails(
        db.collection('players').doc('player_1').update({ schemaVersion: 99 })
      );
    });

    it('must NOT be able to change payment records or expenses', async () => {
      const db = testEnv.authenticatedContext('player_1').firestore();
      await assertFails(
        db.collection('payments').doc('pay_1').update({ amount: 0.0 })
      );
      await assertFails(
        db.collection('expenses').doc('exp_1').update({ amount: 0.0 })
      );
      await assertFails(
        db.collection('expenses').get()
      );
    });

    it('must NOT be able to create arbitrary attendance', async () => {
      const db = testEnv.authenticatedContext('player_1').firestore();
      await assertFails(
        db.collection('attendance').add({
          playerId: 'player_1',
          date: new Date(),
        })
      );
    });

    it('must NOT be able to edit coach or admin documents', async () => {
      const db = testEnv.authenticatedContext('player_1').firestore();
      await assertFails(
        db.collection('coaches').doc('coach_1').update({ hourlyRate: 200 })
      );
      await assertFails(
        db.collection('admin').doc('admin_1').set({ secret: 'compromised' })
      );
    });
  });

  describe('Coach User', () => {
    it('allowed to create attendance', async () => {
      const db = testEnv.authenticatedContext('coach_1').firestore();
      await assertSucceeds(
        db.collection('attendance').add({
          playerId: 'player_1',
          coachId: 'coach_1',
          type: 'fitness',
          date: new Date(),
        })
      );
    });

    it('allowed to create coachWorkSessions for own UID', async () => {
      const db = testEnv.authenticatedContext('coach_1').firestore();
      await assertSucceeds(
        db.collection('coachWorkSessions').add({
          coachId: 'coach_1',
          checkIn: new Date(),
          checkOut: null,
        })
      );
    });

    it('must NOT be able to create coachWorkSessions for another coach', async () => {
      const db = testEnv.authenticatedContext('coach_1').firestore();
      await assertFails(
        db.collection('coachWorkSessions').add({
          coachId: 'coach_2',
          checkIn: new Date(),
          checkOut: null,
        })
      );
    });

    it('must NOT be able to edit or delete payment records', async () => {
      const db = testEnv.authenticatedContext('coach_1').firestore();
      await assertFails(
        db.collection('payments').doc('pay_1').update({ amount: 10.0 })
      );
      await assertFails(
        db.collection('payments').doc('pay_1').delete()
      );
    });

    it('must NOT be able to read, create or edit expenses', async () => {
      const db = testEnv.authenticatedContext('coach_1').firestore();
      await assertFails(db.collection('expenses').get());
      await assertFails(
        db.collection('expenses').add({ title: 'Snacks', amount: 50.0 })
      );
    });

    it('must NOT be able to modify player identity fields or permission status', async () => {
      const db = testEnv.authenticatedContext('coach_1').firestore();
      // Cannot alter player name or isAllowedPlayer
      await assertFails(
        db.collection('players').doc('player_1').update({
          name: 'Tampered Name',
        })
      );
      await assertFails(
        db.collection('players').doc('player_1').update({
          isAllowedPlayer: false,
        })
      );
    });

    it('must NOT be able to alter own hourlyRate or isAllowedCoach', async () => {
      const db = testEnv.authenticatedContext('coach_1').firestore();
      await assertFails(
        db.collection('coaches').doc('coach_1').update({
          hourlyRate: 500.0,
        })
      );
      await assertFails(
        db.collection('coaches').doc('coach_1').update({
          isAllowedCoach: false,
        })
      );
    });
  });

  describe('Admin User', () => {
    it('allowed all intended management operations', async () => {
      const db = testEnv.authenticatedContext('admin_1').firestore();

      // Read/Write expenses
      await assertSucceeds(db.collection('expenses').get());
      await assertSucceeds(
        db.collection('expenses').add({ title: 'Rent', amount: 5000.0 })
      );

      // Edit payments
      await assertSucceeds(
        db.collection('payments').doc('pay_1').update({ status: 'refunded' })
      );

      // Manage players & coaches
      await assertSucceeds(
        db.collection('players').doc('player_1').update({
          sessionsPaid: 15,
          balance: 1500.0,
        })
      );
      await assertSucceeds(
        db.collection('coaches').doc('coach_1').update({
          hourlyRate: 100.0,
        })
      );
    });
  });
});
