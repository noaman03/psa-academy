/**
 * Multi-device UI Screenshot Capture Suite
 * Captures clean, high-resolution desktop (1440x900) and mobile (390x844) screenshots of all key screens
 */
const path = require('path');
const fs = require('fs');
const {
  createBrowser,
  setupPage,
  enableFlutterSemantics,
  clickButtonByText,
  waitForText,
  loginViaUI,
} = require('./ui_test_harness');

const BASE_URL = 'https://psa-academy-staging.web.app';
const DESKTOP_DIR = path.resolve(__dirname, '../docs/screenshots/desktop');
const MOBILE_DIR = path.resolve(__dirname, '../docs/screenshots/mobile');

async function captureForViewport(browser, isMobile) {
  const width = isMobile ? 390 : 1440;
  const height = isMobile ? 844 : 900;
  const outDir = isMobile ? MOBILE_DIR : DESKTOP_DIR;
  const mode = isMobile ? 'MOBILE (390x844)' : 'DESKTOP (1440x900)';

  console.log(`\n====================================================`);
  console.log(`CAPTURING SCREENSHOTS FOR ${mode}`);
  console.log(`Output Directory: ${outDir}`);
  console.log(`====================================================`);

  const { page } = await setupPage(browser, { width, height });

  try {
    // 1. LOGIN SCREEN
    console.log('1. Capturing 01_login.png...');
    await page.goto(`${BASE_URL}/#/login`, { waitUntil: 'domcontentloaded' });
    await enableFlutterSemantics(page);
    await waitForText(page, 'Sign in to access', 12000);
    await new Promise((r) => setTimeout(r, 2000));
    await page.screenshot({ path: path.join(outDir, '01_login.png') });

    // 2. ADMIN FLOW
    console.log('2. Logging in as Admin...');
    await loginViaUI(page, 'staging-admin@psa-academy.test', 'Password123!');
    await waitForText(page, 'Admin Dashboard & Operations', 15000);
    await new Promise((r) => setTimeout(r, 2000));
    await page.screenshot({ path: path.join(outDir, '02_admin_dashboard.png') });

    console.log('Capturing 03_admin_users.png...');
    await clickButtonByText(page, 'Users Management');
    await waitForText(page, 'Academy Members & Staff', 10000);
    await new Promise((r) => setTimeout(r, 2000));
    await page.screenshot({ path: path.join(outDir, '03_admin_users.png') });

    console.log('Capturing 04_admin_finance.png...');
    await clickButtonByText(page, 'Financials');
    await waitForText(page, 'Financial Intelligence & Ledger', 10000);
    await new Promise((r) => setTimeout(r, 2000));
    await page.screenshot({ path: path.join(outDir, '04_admin_finance.png') });

    console.log('Capturing 05_admin_templates.png...');
    await clickButtonByText(page, 'Training Templates');
    await waitForText(page, 'Workout Programs & Drills', 10000);
    await new Promise((r) => setTimeout(r, 2000));
    await page.screenshot({ path: path.join(outDir, '05_admin_templates.png') });

    // Logout Admin
    await clickButtonByText(page, 'Logout');
    await waitForText(page, 'Sign in to access', 10000);

    // 3. COACH FLOW
    console.log('3. Logging in as Coach...');
    await loginViaUI(page, 'staging-coach@psa-academy.test', 'Password123!');
    await waitForText(page, 'Coach Shift & Scanner', 15000);
    await new Promise((r) => setTimeout(r, 2000));
    await page.screenshot({ path: path.join(outDir, '06_coach_dashboard.png') });

    console.log('Capturing 07_coach_scanner.png...');
    await clickButtonByText(page, 'Open Scanner');
    await waitForText(page, 'Player Check-in & Scanner', 10000);
    await new Promise((r) => setTimeout(r, 2000));
    await page.screenshot({ path: path.join(outDir, '07_coach_scanner.png') });

    console.log('Returning to Coach Home...');
    await clickButtonByText(page, 'Back');
    await waitForText(page, 'Coach Shift & Scanner', 10000);

    console.log('Capturing 08_coach_sessions.png...');
    await clickButtonByText(page, 'Sessions History');
    await waitForText(page, 'Recent Player Sessions', 10000);
    await new Promise((r) => setTimeout(r, 2000));
    await page.screenshot({ path: path.join(outDir, '08_coach_sessions.png') });

    // Logout Coach
    await clickButtonByText(page, 'Logout');
    await waitForText(page, 'Sign in to access', 10000);

    // 4. PLAYER FLOW
    console.log('4. Logging in as Player...');
    await loginViaUI(page, 'staging-player-active@psa-academy.test', 'Password123!');
    await waitForText(page, 'Player Membership & Pass', 15000);
    await new Promise((r) => setTimeout(r, 2000));
    await page.screenshot({ path: path.join(outDir, '09_player_dashboard.png') });

    console.log('Capturing 10_player_qr_pass.png...');
    await clickButtonByText(page, 'View QR Pass');
    await waitForText(page, 'Player Training Pass', 8000);
    await new Promise((r) => setTimeout(r, 2000));
    await page.screenshot({ path: path.join(outDir, '10_player_qr_pass.png') });

    await clickButtonByText(page, 'Done');
    await new Promise((r) => setTimeout(r, 1000));

    console.log('Capturing 11_player_workouts.png...');
    await clickButtonByText(page, 'My Workouts');
    await waitForText(page, 'Session History & Workouts', 10000);
    await new Promise((r) => setTimeout(r, 2000));
    await page.screenshot({ path: path.join(outDir, '11_player_workouts.png') });

    console.log('Capturing 12_player_documents.png...');
    await clickButtonByText(page, 'Documents Vault');
    await waitForText(page, 'Medical & Document Vault', 10000);
    await new Promise((r) => setTimeout(r, 2000));
    await page.screenshot({ path: path.join(outDir, '12_player_documents.png') });

    // Logout Player
    await clickButtonByText(page, 'Logout');
    await waitForText(page, 'Sign in to access', 10000);

    console.log(`SUCCESS: Captured all screenshots for ${mode}!`);
  } finally {
    await page.close();
  }
}

async function run() {
  const browser = await createBrowser();
  try {
    // 1. Desktop
    await captureForViewport(browser, false);
    // 2. Mobile
    await captureForViewport(browser, true);
  } finally {
    await browser.close();
  }
}

run().catch((err) => {
  console.error('Screenshot capture failed:', err);
  process.exit(1);
});
