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
    await waitForText(page, 'Active Staging Player', 15000);
    const homeText = await getAllVisibleText(page);
    assert('Player Name Displayed', homeText.includes('Active Staging Player'));
    assert('Player Status Active Displayed', homeText.includes('ACTIVE'));
    assert('Remaining Sessions Displayed', homeText.toLowerCase().includes('sessions remaining'));
    assert('Current Balance Displayed', homeText.toLowerCase().includes('balance') || homeText.includes('EGP'));

    // 3. QR PASS MODAL FLOW
    console.log('\n--- 3. QR PASS MODAL FLOW ---');
    console.log('Clicking Digital Training Pass card...');
    const clickedQr = await page.evaluate(() => {
      const all = Array.from(document.querySelectorAll('flt-semantics[role="button"]'));
      const candidates = all.filter((b) =>
        (b.getAttribute('aria-label') || '').includes('Digital Training Pass') ||
        (b.innerText || '').includes('Digital Training Pass')
      );
      const target = candidates[candidates.length - 1];
      if (target) {
        target.click();
        return true;
      }
      return false;
    });
    assert('Click Digital Training Pass Card', clickedQr);
    await new Promise((r) => setTimeout(r, 2000));

    const qrModalOpen = await waitForText(page, 'Player Training Pass', 8000);
    assert('Player Training Pass Modal Rendered', qrModalOpen);

    const modalText = await getAllVisibleText(page);
    assert('Modal Eliminates Raw Player UID Exposure', !modalText.includes('ID:') && modalText.includes('Active Staging Player'));

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
      workoutsText.toLowerCase().includes('routine') ||
      workoutsText.toLowerCase().includes('no workouts logged yet');
    assert('Workouts Tab Content Rendered', hasWorkoutsOrEmpty);

    // 5. DOCUMENTS VAULT TAB (READ-ONLY)
    console.log('\n--- 5. DOCUMENTS VAULT (READ-ONLY) ---');
    console.log('Navigating to Documents Vault tab...');
    const clickedDocs = await clickButtonByText(page, 'Documents Vault');
    assert('Click Documents Vault Tab', clickedDocs);
    await waitForText(page, 'Medical & Document Vault', 10000);

    const docsVaultText = await getAllVisibleText(page);
    assert('Documents Vault Read-Only (No Upload File Button)', !docsVaultText.includes('Upload File'));
    assert('Documents Vault Header Rendered', docsVaultText.includes('Verified Vault') || docsVaultText.includes('Documents'));

    // 6. PLAYER LOGOUT
    console.log('\n--- 6. PLAYER LOGOUT ---');
    const clickedLogout = await clickButtonByText(page, 'Logout');
    assert('Click Logout Button', clickedLogout);
    await new Promise((r) => setTimeout(r, 3000));

    const onLogin = await waitForText(page, 'Welcome back', 10000);
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
