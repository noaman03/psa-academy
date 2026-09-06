/**
 * Complete Player UI Interaction Acceptance Suite
 * Validates real Flutter Web UI controls, QR pass, workouts, and real Storage document upload
 */
const path = require('path');
const fs = require('fs');
const {
  createBrowser,
  setupPage,
  enableFlutterSemantics,
  clickButtonByText,
  getAllVisibleText,
  waitForText,
  loginViaUI,
} = require('./ui_test_harness');

async function runPlayerJourney() {
  console.log('====================================================');
  console.log('STARTING REAL FLUTTER WEB PLAYER UI ACCEPTANCE SUITE');
  console.log('Target: https://psa-academy-staging.web.app');
  console.log('====================================================\n');

  const browser = await createBrowser();
  const { page } = await setupPage(browser);

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

  try {
    // 1. PLAYER LOGIN VIA REAL UI
    console.log('--- 1. PLAYER LOGIN VIA REAL UI ---');
    await loginViaUI(page, 'staging-player-active@psa-academy.test', 'Password123!');
    const onPlayerScreen = await waitForText(page, 'Player Membership & Pass', 15000);
    assert('Player Login & Screen Render', onPlayerScreen);

    if (!onPlayerScreen) {
      throw new Error('Player login failed: home screen did not render');
    }

    // 2. VERIFY DASHBOARD METRICS & PROFILE
    console.log('\n--- 2. VERIFY METRICS & PROFILE ---');
    const homeText = await getAllVisibleText(page);
    assert('Player Name Displayed', homeText.includes('Active Staging Player'));
    assert('Player Status Active Displayed', homeText.includes('ACTIVE'));
    assert('Remaining Sessions Displayed', homeText.toLowerCase().includes('sessions remaining'));
    assert('Current Balance Displayed', homeText.toLowerCase().includes('balance') || homeText.includes('EGP'));

    // 3. QR PASS DIALOG
    console.log('\n--- 3. QR PASS MODAL FLOW ---');
    console.log('Clicking View QR Pass...');
    const clickedQr = await clickButtonByText(page, 'View QR Pass');
    assert('Click View QR Pass Button', clickedQr);
    await new Promise((r) => setTimeout(r, 2000));

    const qrModalOpen = await waitForText(page, 'Player Training Pass', 8000);
    assert('Player Training Pass Modal Rendered', qrModalOpen);

    const modalText = await getAllVisibleText(page);
    assert('Modal Displays Player UID', modalText.includes('QmdGpj8VWFawlW8bJPHA29II4v32') || modalText.includes('ID:'));

    console.log('Dismissing QR dialog via Done button...');
    const clickedDone = await clickButtonByText(page, 'Done');
    assert('Click Done Button', clickedDone);
    await new Promise((r) => setTimeout(r, 1500));

    // 4. WORKOUTS / ATTENDANCE HISTORY TAB
    console.log('\n--- 4. WORKOUTS & ATTENDANCE HISTORY TAB ---');
    console.log('Navigating to My Workouts tab...');
    const clickedWorkouts = await clickButtonByText(page, 'My Workouts');
    assert('Click My Workouts Tab', clickedWorkouts);
    await waitForText(page, 'Session History & Workouts', 10000);

    const workoutsText = await getAllVisibleText(page);
    const hasWorkoutsOrEmpty =
      workoutsText.toLowerCase().includes('coach') ||
      workoutsText.toLowerCase().includes('fitness') ||
      workoutsText.toLowerCase().includes('recovery') ||
      workoutsText.toLowerCase().includes('no workouts logged yet');
    assert('Workouts Tab Content Rendered', hasWorkoutsOrEmpty);

    // 5. DOCUMENTS VAULT TAB & FILE UPLOAD
    console.log('\n--- 5. DOCUMENTS VAULT & FILE UPLOAD FLOW ---');
    console.log('Navigating to Documents Vault tab...');
    const clickedDocs = await clickButtonByText(page, 'Documents Vault');
    assert('Click Documents Vault Tab', clickedDocs);
    await waitForText(page, 'Medical & Document Vault', 10000);

    const docFixturePdf = path.resolve(__dirname, '../test/fixtures/sample_doc.pdf');
    const docFixturePng = path.resolve(__dirname, '../test/fixtures/sample_cert.png');

    // Test PDF upload
    console.log(`Uploading PDF document fixture: ${path.basename(docFixturePdf)}...`);
    const [fileChooserPdf] = await Promise.all([
      page.waitForFileChooser({ timeout: 10000 }),
      clickButtonByText(page, 'Upload File'),
    ]);
    await fileChooserPdf.accept([docFixturePdf]);

    console.log('Waiting for upload completion SnackBar...');
    const pdfUploadSuccess = await waitForText(page, 'Document uploaded successfully', 15000);
    assert('PDF Document Upload Succeeded', pdfUploadSuccess);
    await new Promise((r) => setTimeout(r, 2000));

    // Test PNG/Image upload
    console.log(`Uploading PNG document fixture: ${path.basename(docFixturePng)}...`);
    const [fileChooserPng] = await Promise.all([
      page.waitForFileChooser({ timeout: 10000 }),
      clickButtonByText(page, 'Upload File'),
    ]);
    await fileChooserPng.accept([docFixturePng]);

    const pngUploadSuccess = await waitForText(page, 'Document uploaded successfully', 15000);
    assert('PNG Document Upload Succeeded', pngUploadSuccess);
    await new Promise((r) => setTimeout(r, 2000));

    // Verify documents list updated
    const docsListText = await getAllVisibleText(page);
    assert('Documents List Contains Uploaded File', docsListText.includes('sample_doc') || docsListText.includes('sample_cert') || docsListText.includes('PDF'));

    // Reload page to verify persistence from Firebase Storage + Firestore
    console.log('Reloading page to verify persistence...');
    await page.reload({ waitUntil: 'domcontentloaded' });
    await enableFlutterSemantics(page);
    await waitForText(page, 'Player Membership & Pass', 15000);
    await new Promise((r) => setTimeout(r, 2000));

    console.log('Navigating back to Documents Vault after reload...');
    const clickedDocsAfterReload = await clickButtonByText(page, 'Documents Vault');
    assert('Click Documents Vault Tab After Reload', clickedDocsAfterReload);
    await waitForText(page, 'Medical & Document Vault', 10000);
    await new Promise((r) => setTimeout(r, 1000));

    const persistedDocsText = await getAllVisibleText(page);
    assert('Uploaded Documents Persist Across Page Reload', persistedDocsText.includes('sample_doc') || persistedDocsText.includes('sample_cert'));

    // 6. PLAYER LOGOUT
    console.log('\n--- 6. PLAYER LOGOUT ---');
    const clickedLogout = await clickButtonByText(page, 'Logout');
    assert('Click Logout Button', clickedLogout);
    await new Promise((r) => setTimeout(r, 3000));

    const onLogin = await waitForText(page, 'Sign in to access', 10000);
    assert('Redirected to Login Screen on Logout', onLogin);
  } finally {
    await browser.close();
  }

  console.log('\n====================================================');
  console.log(`PLAYER UI ACCEPTANCE SUITE FINISHED: ${passes} PASSED, ${fails} FAILED`);
  console.log('====================================================');

  if (fails > 0) process.exit(1);
}

runPlayerJourney().catch((err) => {
  console.error('Player UI Journey Failed:', err);
  process.exit(1);
});
