/**
 * Real hosted Storage verification against psa-academy-staging
 */
const https = require('https');

const STAGING_API_KEY = 'AIzaSyAZGATfJNnu32cNOk7kS5z15f63ofcITpI';
const BUCKET = 'psa-academy-staging.firebasestorage.app';

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

function uploadFile(path, content, contentType, idToken) {
  const encodedPath = encodeURIComponent(path);
  const url = `https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o?name=${encodedPath}`;
  return new Promise((resolve, reject) => {
    const parsedUrl = new URL(url);
    const headers = {
      'Content-Type': contentType,
      'Content-Length': Buffer.byteLength(content),
    };
    if (idToken) {
      headers['Authorization'] = `Firebase ${idToken}`;
    }
    const req = https.request(
      {
        hostname: parsedUrl.hostname,
        path: parsedUrl.pathname + parsedUrl.search,
        method: 'POST',
        headers,
      },
      (res) => {
        let body = '';
        res.on('data', (chunk) => (body += chunk));
        res.on('end', () => {
          try {
            const parsed = JSON.parse(body);
            resolve({ status: res.statusCode, data: parsed });
          } catch (e) {
            resolve({ status: res.statusCode, body });
          }
        });
      }
    );
    req.on('error', reject);
    req.write(content);
    req.end();
  });
}

async function runStorageValidation() {
  console.log('=== REAL STORAGE ACCEPTANCE ON PSA-ACADEMY-STAGING ===');

  // 1. Sign in as Active Player
  const signInUrl = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${STAGING_API_KEY}`;
  const playerAuth = await postJson(signInUrl, {
    email: 'staging-player-active@psa-academy.test',
    password: 'Password123!',
    returnSecureToken: true,
  });
  console.log(`[AUTH] Signed in Active Player: ${playerAuth.localId}`);
  const playerToken = playerAuth.idToken;
  const playerUid = playerAuth.localId;

  // 2. Upload valid JPEG
  const jpegContent = Buffer.from([0xff, 0xd8, 0xff, 0xe0, 0x00, 0x10, 0x4a, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xff, 0xd9]);
  const jpegRes = await uploadFile(`player_documents/${playerUid}/profile_pic.jpg`, jpegContent, 'image/jpeg', playerToken);
  console.log(`[PASS CHECK] JPEG Upload: HTTP ${jpegRes.status} (Expected 200) ->`, jpegRes.status === 200 ? 'PASS' : 'FAIL');

  // 3. Upload valid PNG
  const pngContent = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00, 0x0a, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0d, 0x0a, 0x2d, 0xb4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82]);
  const pngRes = await uploadFile(`player_documents/${playerUid}/certificate.png`, pngContent, 'image/png', playerToken);
  console.log(`[PASS CHECK] PNG Upload: HTTP ${pngRes.status} (Expected 200) ->`, pngRes.status === 200 ? 'PASS' : 'FAIL');

  // 4. Upload valid PDF
  const pdfContent = Buffer.from('%PDF-1.4\n1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] >>\nendobj\nxref\n0 4\n0000000000 65535 f \n0000000009 00000 n \n0000000058 00000 n \n0000000115 00000 n \ntrailer\n<< /Size 4 /Root 1 0 R >>\nstartxref\n190\n%%EOF');
  const pdfRes = await uploadFile(`player_documents/${playerUid}/medical_clearance.pdf`, pdfContent, 'application/pdf', playerToken);
  console.log(`[PASS CHECK] PDF Upload: HTTP ${pdfRes.status} (Expected 200) ->`, pdfRes.status === 200 ? 'PASS' : 'FAIL');

  // 5. Unsupported MIME denial check (e.g. text/html)
  const htmlRes = await uploadFile(`player_documents/${playerUid}/malicious.html`, '<html><body>XSS</body></html>', 'text/html', playerToken);
  console.log(`[SECURITY CHECK] Unsupported MIME (text/html): HTTP ${htmlRes.status} (Expected 403) ->`, htmlRes.status === 403 ? 'PASS (Correctly Denied)' : 'FAIL');

  // 6. Cross-player storage denial check
  const crossRes = await uploadFile('player_documents/other_player_uid/stolen.jpg', jpegContent, 'image/jpeg', playerToken);
  console.log(`[SECURITY CHECK] Cross-Player Access: HTTP ${crossRes.status} (Expected 403) ->`, crossRes.status === 403 ? 'PASS (Correctly Denied)' : 'FAIL');

  // 7. Unauthenticated upload denial check
  const unauthRes = await uploadFile(`player_documents/${playerUid}/unauth.jpg`, jpegContent, 'image/jpeg', null);
  console.log(`[SECURITY CHECK] Unauthenticated Upload: HTTP ${unauthRes.status} (Expected 403) ->`, unauthRes.status === 403 ? 'PASS (Correctly Denied)' : 'FAIL');

  console.log('=== Storage Validation Complete ===');
}

runStorageValidation().catch(console.error);
