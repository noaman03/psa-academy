/**
 * Full Admin UI Interaction Acceptance Suite
 * Validates real Flutter Web UI controls with Puppeteer
 */
const path = require('path');
const fs = require('fs');
const {
  createBrowser,
  setupPage,
  enableFlutterSemantics,
  typeIntoInput,
  clickButtonByText,
  clickCardByText,
  getAllVisibleText,
  waitForText,
  loginViaUI,
} = require('./ui_test_harness');

const DOWNLOAD_DIR = path.resolve(__dirname, '../test/downloads');

async function runAdminJourney() {
  console.log('====================================================');
  console.log('STARTING REAL FLUTTER WEB ADMIN UI ACCEPTANCE SUITE');
  console.log('Target: https://psa-academy-staging.web.app');
  console.log('====================================================\n');

  // Clean downloads directory
  if (!fs.existsSync(DOWNLOAD_DIR)) fs.mkdirSync(DOWNLOAD_DIR, { recursive: true });
  fs.readdirSync(DOWNLOAD_DIR).forEach((f) => fs.unlinkSync(path.join(DOWNLOAD_DIR, f)));

  const browser = await createBrowser();
  const { page, errors } = await setupPage(browser, { downloadPath: DOWNLOAD_DIR });

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
    // 1. LOGIN
    console.log('--- 1. ADMIN LOGIN VIA REAL UI ---');
    await loginViaUI(page, 'staging-admin@psa-academy.test', 'Password123!');
    const loggedIn = await waitForText(page, 'Operations Dashboard', 15000);
    assert('Admin Login & Dashboard Render', loggedIn);

    if (!loggedIn) {
      throw new Error('Admin login failed: dashboard did not render');
    }

    // 2. NAVIGATE TO USERS
    console.log('\n--- 2. USERS TAB & PLAYER CREATION ---');
    const clickedUsers = await clickButtonByText(page, 'Users');
    assert('Click Users Tab', clickedUsers);
    await new Promise((r) => setTimeout(r, 2500));

    const usersLoaded = await waitForText(page, 'User Management', 10000);
    assert('Users Management Screen Render', usersLoaded);

    // Click Add User
    console.log('Clicking Add User button...');
    const clickedAdd = await clickButtonByText(page, 'Add User');
    assert('Open Add User Modal', clickedAdd);
    await new Promise((r) => setTimeout(r, 2000));

    const modalOpen = await waitForText(page, 'Create New Player', 5000);
    assert('Create New Player Dialog Displayed', modalOpen);

    // Fill Player Form inside modal
    const testPlayerName = `UI Player ${Date.now().toString().slice(-4)}`;
    const testPlayerEmail = `ui.player.${Date.now()}@psa-academy.test`;

    const formInputs = await page.$$('form input');
    console.log(`Found ${formInputs.length} inputs in Create User dialog form`);

    if (formInputs.length >= 3) {
      await typeIntoInput(page, formInputs[0], testPlayerName);
      await typeIntoInput(page, formInputs[1], testPlayerEmail);
      await typeIntoInput(page, formInputs[2], '+201099988877');
      if (formInputs[3]) await typeIntoInput(page, formInputs[3], '5');
    }

    console.log(`Submitting Create User for "${testPlayerName}"...`);
    const clickedCreate = await clickButtonByText(page, 'Create User');
    assert('Click Create User Button', clickedCreate);
    await new Promise((r) => setTimeout(r, 4000));

    // Confirm player appears in list
    const playerInList = await waitForText(page, testPlayerName, 10000);
    assert('Created Player Appears in List', playerInList, testPlayerName);

    // 3. OPEN PLAYER DETAILS & SUSPEND / REACTIVATE
    console.log('\n--- 3. PLAYER DETAILS & SUSPENSION TOGGLE ---');
    const clickedCard = await clickCardByText(page, testPlayerName);
    assert('Open Player Details Sheet', clickedCard);
    await new Promise((r) => setTimeout(r, 2500));

    const detailsOpen = await waitForText(page, 'Player Information', 5000);
    assert('Player Details Sheet Displayed', detailsOpen);

    // Suspend player
    console.log('Clicking Suspend button in bottom sheet...');
    const clickedSuspend = await clickButtonByText(page, 'Suspend');
    assert('Click Suspend Button', clickedSuspend);
    await new Promise((r) => setTimeout(r, 3000));

    // Re-open details
    await clickCardByText(page, testPlayerName);
    await new Promise((r) => setTimeout(r, 2500));

    // Activate player
    console.log('Clicking Activate button in bottom sheet...');
    const clickedActivate = await clickButtonByText(page, 'Activate');
    assert('Click Activate Button', clickedActivate);
    await new Promise((r) => setTimeout(r, 3000));

    // 4. FINANCE TAB & RECORD PAYMENT / EXPENSE
    console.log('\n--- 4. FINANCE TAB INTERACTIONS ---');
    const clickedFinance = await clickButtonByText(page, 'Finance');
    assert('Click Finance Tab', clickedFinance);
    await new Promise((r) => setTimeout(r, 2500));

    const financeLoaded = await waitForText(page, 'Finance & Treasury', 10000);
    assert('Finance Screen Render', financeLoaded);

    // Record Payment
    console.log('Opening Record Payment Dialog...');
    await clickButtonByText(page, 'Record Payment');
    await new Promise((r) => setTimeout(r, 2000));

    const paymentModalOpen = await waitForText(page, 'Record New Payment', 5000);
    assert('Record Payment Dialog Displayed', paymentModalOpen);

    const fInputs = await page.$$('form input');
    if (fInputs.length >= 2) {
      await typeIntoInput(page, fInputs[0], testPlayerName);
      await typeIntoInput(page, fInputs[1], '1200');
    }

    const clickedSavePayment = await clickButtonByText(page, 'Save Payment');
    assert('Click Save Payment', clickedSavePayment);
    await new Promise((r) => setTimeout(r, 3000));

    // Record Expense
    console.log('Opening Record Expense Dialog...');
    await clickButtonByText(page, 'Record Expense');
    await new Promise((r) => setTimeout(r, 2000));

    const expenseModalOpen = await waitForText(page, 'Record New Expense', 5000);
    assert('Record Expense Dialog Displayed', expenseModalOpen);

    const expInputs = await page.$$('form input');
    if (expInputs.length >= 2) {
      await typeIntoInput(page, expInputs[0], 'Training Cones & Agility Ladders');
      await typeIntoInput(page, expInputs[1], '450');
    }

    const clickedSaveExpense = await clickButtonByText(page, 'Save Expense');
    assert('Click Save Expense', clickedSaveExpense);
    await new Promise((r) => setTimeout(r, 3000));

    // 5. TRAINING TEMPLATES TAB
    console.log('\n--- 5. TRAINING TEMPLATES TAB INTERACTIONS ---');
    const clickedTemplates = await clickButtonByText(page, 'Templates');
    assert('Click Templates Tab', clickedTemplates);
    await new Promise((r) => setTimeout(r, 2500));

    const templatesLoaded = await waitForText(page, 'Workout Templates', 10000);
    assert('Templates Screen Render', templatesLoaded);

    // Create Template
    console.log('Opening Create Template Dialog...');
    await clickButtonByText(page, 'New Workout Template');
    await new Promise((r) => setTimeout(r, 2000));

    const tModalOpen = await waitForText(page, 'Create Training Template', 5000);
    assert('Create Template Dialog Displayed', tModalOpen);

    const templateName = `Drill Set ${Date.now().toString().slice(-4)}`;
    const tInputs = await page.$$('form input');
    if (tInputs.length >= 1) {
      await typeIntoInput(page, tInputs[0], templateName);
    }

    // Click Add Exercise
    await clickButtonByText(page, 'Add Exercise');
    await new Promise((r) => setTimeout(r, 500));

    const clickedSaveTemplate = await clickButtonByText(page, 'Save Template');
    assert('Click Save Template', clickedSaveTemplate);
    await new Promise((r) => setTimeout(r, 3000));

    // Confirm template appears in list
    const templateInList = await waitForText(page, templateName, 8000);
    assert('Template Created and Visible in List', templateInList, templateName);

    // Reload page to confirm persistence
    console.log('Reloading browser to confirm persistence...');
    await page.goto('https://psa-academy-staging.web.app/admin', { waitUntil: 'domcontentloaded' });
    await new Promise((r) => setTimeout(r, 3000));
    await enableFlutterSemantics(page);

    await clickButtonByText(page, 'Templates');
    await new Promise((r) => setTimeout(r, 2000));

    const recheckTemplate = await waitForText(page, templateName, 10000);
    assert('Template Persisted Across Reload', recheckTemplate, templateName);

    // 6. EXPORT PDF DOWNLOAD
    console.log('\n--- 6. REAL PDF EXPORT & DOWNLOAD ---');
    await clickButtonByText(page, 'Finance');
    await new Promise((r) => setTimeout(r, 2000));

    console.log('Clicking Export PDF button...');
    await clickButtonByText(page, 'Export PDF');
    console.log('Waiting for PDF file to save into downloads directory...');
    await new Promise((r) => setTimeout(r, 5000));

    const downloadedFiles = fs.readdirSync(DOWNLOAD_DIR);
    console.log('Files in download directory:', downloadedFiles);

    assert('PDF File Downloaded', downloadedFiles.length > 0);
    if (downloadedFiles.length > 0) {
      const pdfFile = path.join(DOWNLOAD_DIR, downloadedFiles[0]);
      const stat = fs.statSync(pdfFile);
      const buffer = fs.readFileSync(pdfFile);
      const header = buffer.slice(0, 5).toString('ascii');

      assert('Downloaded File Size > 0', stat.size > 0, `Size: ${stat.size} bytes`);
      assert('Valid PDF Signature (%PDF-)', header === '%PDF-', `Header: ${header}`);
      assert('Useful Filename Format', downloadedFiles[0].startsWith('psa_finance_report_'), downloadedFiles[0]);
    }

    // 7. LOGOUT
    console.log('\n--- 7. ADMIN LOGOUT ---');
    const clickedLogout = await clickButtonByText(page, 'Logout');
    assert('Click Logout Button', clickedLogout);
    await new Promise((r) => setTimeout(r, 3000));

    const onLogin = await waitForText(page, 'Sign in to access', 10000);
    assert('Redirected to Login Screen on Logout', onLogin);
  } finally {
    await browser.close();
  }

  console.log('\n====================================================');
  console.log(`ADMIN UI ACCEPTANCE SUITE FINISHED: ${passes} PASSED, ${fails} FAILED`);
  console.log('====================================================');

  if (fails > 0) process.exit(1);
}

runAdminJourney().catch((err) => {
  console.error('Admin UI Journey Failed:', err);
  process.exit(1);
});
