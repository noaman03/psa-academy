const { describe, it, before, after, beforeEach } = require('node:test');
const fs = require('node:fs');
const path = require('node:path');
const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');

const PROJECT_ID = 'psa-academy-65088';

describe('Storage Security Rules', () => {
  let testEnv;

  before(async () => {
    const storageRulesPath = path.resolve(__dirname, '../../storage.rules');
    const storageRules = fs.readFileSync(storageRulesPath, 'utf8');

    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      storage: {
        rules: storageRules,
        host: '127.0.0.1',
        port: 9199,
      },
    });
  });

  after(async () => {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  beforeEach(async () => {
    await testEnv.clearStorage();
  });

  describe('Unauthenticated User', () => {
    it('must fail to upload or read any files', async () => {
      const storage = testEnv.unauthenticatedContext().storage();
      const fileRef = storage.ref('player_documents/player_1/passport.pdf');
      const dummyBuffer = Buffer.from('dummy-pdf-content');

      await assertFails(
        fileRef.put(dummyBuffer, { contentType: 'application/pdf' })
      );
      await assertFails(fileRef.getDownloadURL());
    });
  });

  describe('Player User', () => {
    it('allowed to upload valid PDF or Image to own directory (< 15MB)', async () => {
      const storage = testEnv.authenticatedContext('player_1').storage();
      const pdfRef = storage.ref('player_documents/player_1/medical.pdf');
      const imgRef = storage.ref('player_documents/player_1/photo.jpg');

      const dummyBuffer = Buffer.from('dummy-content');

      await assertSucceeds(
        pdfRef.put(dummyBuffer, { contentType: 'application/pdf' })
      );
      await assertSucceeds(
        imgRef.put(dummyBuffer, { contentType: 'image/jpeg' })
      );
    });

    it('must NOT be able to upload into another player directory', async () => {
      const storage = testEnv.authenticatedContext('player_1').storage();
      const targetRef = storage.ref('player_documents/player_2/hacked.pdf');

      await assertFails(
        targetRef.put(Buffer.from('hacked'), { contentType: 'application/pdf' })
      );
    });

    it('must NOT be able to upload invalid MIME types (e.g. executables, html)', async () => {
      const storage = testEnv.authenticatedContext('player_1').storage();
      const exeRef = storage.ref('player_documents/player_1/malware.exe');
      const htmlRef = storage.ref('player_documents/player_1/script.html');

      await assertFails(
        exeRef.put(Buffer.from('binary'), {
          contentType: 'application/x-msdownload',
        })
      );
      await assertFails(
        htmlRef.put(Buffer.from('<html></html>'), {
          contentType: 'text/html',
        })
      );
    });

    it('must NOT be able to upload files exceeding 15MB limit', async () => {
      const storage = testEnv.authenticatedContext('player_1').storage();
      const largeRef = storage.ref('player_documents/player_1/large.pdf');

      // Create a buffer larger than 15MB (16MB)
      const oversizedBuffer = Buffer.alloc(16 * 1024 * 1024);

      await assertFails(
        largeRef.put(oversizedBuffer, { contentType: 'application/pdf' })
      );
    });

    it('must NOT be able to upload to root or arbitrary directories', async () => {
      const storage = testEnv.authenticatedContext('player_1').storage();
      const rootRef = storage.ref('root_file.pdf');
      const adminRef = storage.ref('admin_docs/secret.pdf');

      await assertFails(
        rootRef.put(Buffer.from('data'), { contentType: 'application/pdf' })
      );
      await assertFails(
        adminRef.put(Buffer.from('data'), { contentType: 'application/pdf' })
      );
    });

    it('allowed to delete own files, but NOT other player files', async () => {
      const storage = testEnv.authenticatedContext('player_1').storage();
      const ownRef = storage.ref('player_documents/player_1/doc.pdf');

      await assertSucceeds(
        ownRef.put(Buffer.from('content'), { contentType: 'application/pdf' })
      );
      await assertSucceeds(ownRef.delete());

      const otherRef = storage.ref('player_documents/player_2/doc.pdf');
      await assertFails(otherRef.delete());
    });
  });
});
