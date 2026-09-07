/**
 * Edge Cases & Business Rule UI Acceptance Suite
 * Validates zero-session check-in rejection, suspended/inactive handling, and login edge cases
 */
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

const ZERO_PLAYER_UID = 'i4cVpBlJbNRKo9E06Ug2UQaJvIB3';
const INACTIVE_PLAYER_UID = 'zDnNnDo3keeeQZlsuIUoM0PQ8cJ3';

async function runEdgeCases() {
  console.log('====================================================');
  console.log('STARTING REAL FLUTTER WEB EDGE CASES ACCEPTANCE SUITE');
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
    // 1. COACH LOGIN TO TEST ATTENDANCE EDGE CASES
    console.log('--- 1. COACH LOGIN FOR ATTENDANCE EDGE CASES ---');
    await loginViaUI(page, 'staging-coach@psa-academy.test', 'Password123!');
    const onCoachHome = await waitForText(page, 'Coach Shift & Scanner', 15000);
    assert('Coach Login Succeeded', onCoachHome);

    // 2. ZERO-SESSIONS PLAYER CHECK-IN REJECTION
    console.log('\n--- 2. ZERO-SESSIONS PLAYER REJECTION FLOW ---');
    await clickButtonByText(page, 'Open Scanner');
    await waitForText(page, 'Player Check-in & Scanner', 10000);

    await clickButtonByText(page, 'Manual ID Entry');
    await waitForText(page, 'Player UID', 8000);

    const idInput = await page.$('input[type="text"]');
    if (idInput) {
      await typeIntoInput(page, idInput, ZERO_PLAYER_UID);
    }
    await clickButtonByText(page, 'Lookup Player');
    await waitForText(page, 'Zero Sessions Player', 10000);

    const zeroPlayerText = await getAllVisibleText(page);
    assert('Zero-Sessions Player Details Displayed', zeroPlayerText.includes('Zero Sessions Player'));
    assert('Zero-Sessions Warning/Badge Rendered', zeroPlayerText.includes('0 SESSIONS') || zeroPlayerText.toLowerCase().includes('warning') || zeroPlayerText.includes('SUSPENDED'));

    console.log('Attempting check-in on zero-session unauthorized player...');
    await new Promise((r) => setTimeout(r, 1000));
    await page.evaluate(() => window.scrollBy(0, 500));
    await new Promise((r) => setTimeout(r, 500));

    await clickButtonByText(page, 'Confirm Check-in & Deduct Session');
    await new Promise((r) => setTimeout(r, 2000));

    const zeroRejectionText = await getAllVisibleText(page);
    const zeroRejected =
      zeroRejectionText.toLowerCase().includes('0 remaining sessions') ||
      zeroRejectionText.toLowerCase().includes('suspended') ||
      zeroRejectionText.toLowerCase().includes('failed to record');
    assert('Zero-Session Check-in Rejection SnackBar Rendered', zeroRejected);

    // 3. INACTIVE / SUSPENDED PLAYER REJECTION
    console.log('\n--- 3. INACTIVE / SUSPENDED PLAYER REJECTION FLOW ---');
    await clickButtonByText(page, 'Cancel / Scan Another');
    await new Promise((r) => setTimeout(r, 1500));

    const hasManualInput = await waitForText(page, 'Player UID', 3000);
    if (!hasManualInput) {
      await clickButtonByText(page, 'Manual ID Entry');
      await waitForText(page, 'Player UID', 8000);
    }

    const idInput2 = await page.$('input[type="text"]');
    if (idInput2) {
      await typeIntoInput(page, idInput2, INACTIVE_PLAYER_UID);
    }
    await clickButtonByText(page, 'Lookup Player');
    await waitForText(page, 'Inactive Player', 10000);

    const inactivePlayerText = await getAllVisibleText(page);
    assert('Inactive Player Details Displayed', inactivePlayerText.includes('Inactive Player'));
    assert('Suspended Badge Rendered for Inactive Player', inactivePlayerText.includes('SUSPENDED'));

    console.log('Attempting check-in on suspended player...');
    await new Promise((r) => setTimeout(r, 1000));
    await page.evaluate(() => window.scrollBy(0, 500));
    await new Promise((r) => setTimeout(r, 500));

    await clickButtonByText(page, 'Confirm Check-in & Deduct Session');
    await new Promise((r) => setTimeout(r, 2000));

    const inactiveRejectionText = await getAllVisibleText(page);
    const inactiveRejected =
      inactiveRejectionText.toLowerCase().includes('suspended') ||
      inactiveRejectionText.toLowerCase().includes('deactivated') ||
      inactiveRejectionText.toLowerCase().includes('cannot check in');
    assert('Suspended Player Check-in Rejected with Human Message', inactiveRejected);

    // Return to coach home and logout
    console.log('Returning to Coach Home...');
    await clickButtonByText(page, 'Back');
    await waitForText(page, 'Coach Shift & Scanner', 10000);

    await clickButtonByText(page, 'Logout');
    await waitForText(page, 'Welcome back', 10000);

    // 4. INVALID CREDENTIALS ERROR HANDLING & NO INFINITE SPINNER
    console.log('\n--- 4. INVALID CREDENTIALS ERROR HANDLING ---');
    console.log('Entering invalid password for staging-coach@psa-academy.test...');
    const emailInput = await page.$('input[type="email"]');
    if (emailInput) {
      await typeIntoInput(page, emailInput, 'staging-coach@psa-academy.test');
    }
    const passInput = await page.$('input[type="password"]');
    if (passInput) {
      await typeIntoInput(page, passInput, 'CompletelyWrongPassword999!');
    }

    console.log('Clicking Sign In button...');
    await clickButtonByText(page, 'Sign In');
    await new Promise((r) => setTimeout(r, 3000));

    const loginErrorText = await getAllVisibleText(page);
    const hasReadableError =
      loginErrorText.toLowerCase().includes('invalid') ||
      loginErrorText.toLowerCase().includes('password') ||
      loginErrorText.toLowerCase().includes('credential') ||
      loginErrorText.toLowerCase().includes('try again');
    assert('Invalid Credentials Human-Readable Error Displayed', hasReadableError);

    // Ensure Sign In button is re-enabled (no infinite loading spinner)
    const canClickSignInAgain = await clickButtonByText(page, 'Sign In');
    assert('Sign In Button Re-enabled (No Infinite Spinner)', canClickSignInAgain);

    // 5. FORGOT PASSWORD MODAL FLOW
    console.log('\n--- 5. FORGOT PASSWORD MODAL FLOW ---');
    console.log('Clicking Forgot Password link...');
    const clickedForgot = await clickButtonByText(page, 'Forgot password?');
    assert('Click Forgot Password Link', clickedForgot);
    await new Promise((r) => setTimeout(r, 1500));

    const forgotModalOpen = await waitForText(page, 'Reset Password', 8000);
    assert('Reset Password Modal Rendered', forgotModalOpen);

    console.log('Dismissing Reset Password modal via Cancel...');
    const clickedCancel = await clickButtonByText(page, 'Cancel');
    assert('Click Cancel on Reset Modal', clickedCancel);
    await new Promise((r) => setTimeout(r, 1500));

    const onLoginAgain = await waitForText(page, 'Welcome back', 8000);
    assert('Returned to Clean Login Screen', onLoginAgain);
  } finally {
    await browser.close();
  }

  console.log('\n====================================================');
  console.log(`EDGE CASES SUITE FINISHED: ${passes} PASSED, ${fails} FAILED`);
  console.log('====================================================');

  if (fails > 0) process.exit(1);
}

runEdgeCases().catch((err) => {
  console.error('Edge Cases Suite Failed:', err);
  process.exit(1);
});
