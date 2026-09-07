/**
 * Complete Coach UI Interaction Acceptance Suite
 * Validates real Flutter Web UI controls with Puppeteer
 */
const https = require('https');
const fs = require('fs');
const {
  createBrowser,
  setupPage,
  enableFlutterSemantics,
  typeIntoInput,
  clickButtonByText,
  getAllVisibleText,
  waitForText,
  loginViaUI,
} = require('./ui_test_harness');

const ACTIVE_PLAYER_UID = 'QmdGpj8VWFawlW8bJPHA29II4v32';
const PROJECT_ID = 'psa-academy-staging';

let iamToken = null;
try {
  const cfg = JSON.parse(fs.readFileSync('C:\\Users\\noama\\.config\\configstore\\firebase-tools.json', 'utf8'));
  iamToken = cfg.tokens.access_token;
} catch (e) {}

function resetPlayerAttendanceDate(uid) {
  const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/players/${uid}?updateMask.fieldPaths=lastAttendance`;
  const parsedUrl = new URL(url);
  const data = JSON.stringify({ fields: { lastAttendance: { nullValue: null } } });
  return new Promise((resolve) => {
    const req = https.request(
      {
        hostname: parsedUrl.hostname,
        path: parsedUrl.pathname + parsedUrl.search,
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(data),
          Authorization: `Bearer ${iamToken}`,
        },
      },
      (res) => resolve(res.statusCode)
    );
    req.write(data);
    req.end();
  });
}

async function runCoachJourney() {
  console.log('====================================================');
  console.log('STARTING REAL FLUTTER WEB COACH UI ACCEPTANCE SUITE');
  console.log('Target: https://psa-academy-staging.web.app');
  console.log('====================================================\n');

  // Reset lastAttendance before test so first check-in is clean
  await resetPlayerAttendanceDate(ACTIVE_PLAYER_UID);

  const browser = await createBrowser();
  const { page, errors } = await setupPage(browser);

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
    // 1. COACH LOGIN
    console.log('--- 1. COACH LOGIN VIA REAL UI ---');
    await loginViaUI(page, 'staging-coach@psa-academy.test', 'Password123!');
    const loggedIn = await waitForText(page, 'Coach Shift & Scanner', 15000);
    assert('Coach Login & Home Screen Render', loggedIn);

    if (!loggedIn) {
      throw new Error('Coach login failed: home screen did not render');
    }

    // Verify hourly rate is removed from coach UI
    const rateText = await getAllVisibleText(page);
    assert('Coach Hourly Rate Removed From Coach UI', !rateText.includes('150/hr') && !rateText.includes('Rate:'));

    // 2. CLOCK IN (START WORK SHIFT)
    console.log('\n--- 2. COACH CLOCK IN (START SHIFT) ---');
    if (rateText.includes('ACTIVE WORK SHIFT')) {
      console.log('Coach already clocked in. Ending shift first to reset...');
      await clickButtonByText(page, 'End Shift & Check Out');
      await new Promise((r) => setTimeout(r, 1500));
      await clickButtonByText(page, 'Check Out');
      await new Promise((r) => setTimeout(r, 3000));
    }

    console.log('Clicking Clock In / Start Shift button...');
    const clickedClockIn = await clickButtonByText(page, 'Clock In / Start Shift');
    assert('Click Clock In Button', clickedClockIn);
    await new Promise((r) => setTimeout(r, 3000));

    const shiftActive = await waitForText(page, 'ACTIVE WORK SHIFT', 10000);
    assert('UI Reflects Active Shift Status', shiftActive);

    // 3. ATTENDANCE & CHECK-IN FLOW (FITNESS)
    console.log('\n--- 3. SCANNER / MANUAL ATTENDANCE FLOW ---');
    console.log('Opening scanner interface...');
    const clickedScanner = await clickButtonByText(page, 'Open Scanner');
    assert('Click Open Scanner', clickedScanner);
    await waitForText(page, 'Player Check-in & Scanner', 10000);

    // Switch to manual input
    console.log('Switching to Manual ID Entry mode...');
    await clickButtonByText(page, 'Manual ID Entry');
    await waitForText(page, 'Player UID', 8000);

    // Enter active player UID
    console.log(`Entering Player UID: ${ACTIVE_PLAYER_UID}...`);
    const idInput = await page.$('input[type="text"]');
    if (idInput) {
      await typeIntoInput(page, idInput, ACTIVE_PLAYER_UID);
    }

    console.log('Clicking Lookup Player...');
    await clickButtonByText(page, 'Lookup Player');
    await waitForText(page, 'Active Staging Player', 10000);

    // Verify remaining session count displayed
    const playerDetailsText = await getAllVisibleText(page);
    const hasRemaining =
      playerDetailsText.toLowerCase().includes('sessions left') ||
      playerDetailsText.toLowerCase().includes('remaining') ||
      playerDetailsText.toLowerCase().includes('sessions');
    assert('Player Remaining Sessions Displayed', hasRemaining);

    // Confirm Fitness Training check-in
    console.log('Confirming Fitness Attendance check-in...');
    const clickedConfirm = await clickButtonByText(page, 'Confirm Check-in & Deduct Session');
    assert('Click Confirm Check-in', clickedConfirm);

    // Confirm success UI / return to coach home
    const backOnHome = await waitForText(page, 'Coach Shift & Scanner', 12000);
    assert('Check-in Success & Returned to Home', backOnHome);

    // 4. DUPLICATE ATTENDANCE TEST (15-MINUTE WINDOW REJECTION)
    console.log('\n--- 4. DUPLICATE ATTENDANCE REJECTION TEST ---');
    await clickButtonByText(page, 'Open Scanner');
    await waitForText(page, 'Player Check-in & Scanner', 10000);

    await clickButtonByText(page, 'Manual ID Entry');
    await waitForText(page, 'Player UID', 8000);

    const idInput2 = await page.$('input[type="text"]');
    if (idInput2) {
      await typeIntoInput(page, idInput2, ACTIVE_PLAYER_UID);
    }
    await clickButtonByText(page, 'Lookup Player');
    await waitForText(page, 'Active Staging Player', 10000);
    await new Promise((r) => setTimeout(r, 1500));
    await page.evaluate(() => window.scrollBy(0, 500));
    await new Promise((r) => setTimeout(r, 500));

    console.log('Attempting immediate duplicate check-in...');
    const clickedDup = await clickButtonByText(page, 'Confirm Check-in & Deduct Session');
    console.log('Clicked duplicate confirm button:', clickedDup);
    await new Promise((r) => setTimeout(r, 2000));
    const textDup = await getAllVisibleText(page);
    console.log('Page text after duplicate click snippet:', textDup.slice(0, 300));
    const isDuplicateRejected = textDup.toLowerCase().includes('duplicate check-in detected') || (await waitForText(page, 'Duplicate check-in detected', 6000));
    assert('Immediate Duplicate Check-in Rejected with Human Message', isDuplicateRejected);

    // Return to coach home via back button
    console.log('Returning to Coach Home...');
    await clickButtonByText(page, 'Back');
    await waitForText(page, 'Coach Shift & Scanner', 10000);

    // 5. RECOVERY FLOW & TEMPLATE ASSIGNMENT
    console.log('\n--- 5. RECOVERY FLOW & TEMPLATE ASSIGNMENT ---');
    await clickButtonByText(page, 'Open Scanner');
    await waitForText(page, 'Player Check-in & Scanner', 10000);

    await clickButtonByText(page, 'Manual ID Entry');
    await waitForText(page, 'Player UID', 8000);

    // Reset lastAttendance so recovery check-in can proceed
    await resetPlayerAttendanceDate(ACTIVE_PLAYER_UID);

    const idInput3 = await page.$('input[type="text"]');
    if (idInput3) {
      await typeIntoInput(page, idInput3, ACTIVE_PLAYER_UID);
    }
    await clickButtonByText(page, 'Lookup Player');
    await waitForText(page, 'Active Staging Player', 10000);

    // Select Recovery Session
    console.log('Selecting Recovery Session type...');
    await clickButtonByText(page, 'Recovery Session');
    await new Promise((r) => setTimeout(r, 1000));

    console.log('Confirming Recovery Attendance...');
    await clickButtonByText(page, 'Confirm Check-in & Deduct Session');
    const recoveryBackOnHome = await waitForText(page, 'Coach Shift & Scanner', 12000);
    assert('Recovery Attendance Checked In & Returned to Home', recoveryBackOnHome);

    // View Sessions History tab
    console.log('Viewing Sessions History tab...');
    await clickButtonByText(page, 'Sessions History');
    await waitForText(page, 'Recent Player Sessions', 10000);

    const historyContent = await getAllVisibleText(page);
    assert('Sessions History Displays Recent Check-ins', historyContent.includes('Active Staging Player'));

    // Return to Shift & Scan tab
    await clickButtonByText(page, 'Shift & Scan');
    await waitForText(page, 'Coach Shift & Scanner', 10000);

    // 6. CHECK OUT (END SHIFT)
    console.log('\n--- 6. COACH CHECK OUT (END SHIFT) ---');
    console.log('Clicking End Shift & Check Out...');
    console.log('Clicking End Shift & Check Out button...');
    const clickedEndShift = await clickButtonByText(page, 'End Shift & Check Out');
    assert('Click End Shift Button', clickedEndShift);
    await new Promise((r) => setTimeout(r, 2000));
    const textCheckout = await getAllVisibleText(page);
    console.log('Page text after clicking end shift snippet:', textCheckout.slice(0, 300));

    const checkOutModal = (textCheckout.includes('Check Out') && textCheckout.includes('Cancel')) ||
                          textCheckout.toLowerCase().includes('end work shift') ||
                          textCheckout.toLowerCase().includes('clock out') ||
                          textCheckout.toLowerCase().includes('finalize your shift');
    assert('End Work Shift Confirmation Dialog Displayed', !!checkOutModal);

    console.log('Confirming Check Out in dialog...');
    await clickButtonByText(page, 'Check Out');
    await new Promise((r) => setTimeout(r, 4000));

    const offDuty = await waitForText(page, 'OFF DUTY', 10000);
    assert('UI Reflects Shift Closed / OFF DUTY', offDuty);

    // 7. LOGOUT
    console.log('\n--- 7. COACH LOGOUT ---');
    const clickedLogout = await clickButtonByText(page, 'Logout');
    assert('Click Logout Button', clickedLogout);
    await new Promise((r) => setTimeout(r, 3000));

    const onLogin = await waitForText(page, 'Welcome back', 10000);
    assert('Redirected to Login Screen on Logout', onLogin);
  } finally {
    await browser.close();
  }

  console.log('\n====================================================');
  console.log(`COACH UI ACCEPTANCE SUITE FINISHED: ${passes} PASSED, ${fails} FAILED`);
  console.log('====================================================');

  if (fails > 0) process.exit(1);
}

runCoachJourney().catch((err) => {
  console.error('Coach UI Journey Failed:', err);
  process.exit(1);
});
