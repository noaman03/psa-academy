/**
 * Route Guards & Navigation Security Acceptance Suite
 * Validates real Flutter Web route protections (SplashGate sanitization, RoleGuard, and URL manipulation defense)
 */
const {
  createBrowser,
  setupPage,
  enableFlutterSemantics,
  clickButtonByText,
  getAllVisibleText,
  waitForText,
  loginViaUI,
} = require('./ui_test_harness');

const BASE_URL = 'https://psa-academy-staging.web.app';

async function runRouteGuards() {
  console.log('====================================================');
  console.log('STARTING REAL FLUTTER WEB ROUTE GUARDS ACCEPTANCE SUITE');
  console.log('Target: ' + BASE_URL);
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
    // 1. UNAUTHENTICATED URL MANIPULATION DEFENSE
    console.log('--- 1. UNAUTHENTICATED URL ACCESS TO /admin ---');
    await page.goto(`${BASE_URL}/#/admin`, { waitUntil: 'domcontentloaded' });
    await enableFlutterSemantics(page);
    const unauthAdminOnLogin = await waitForText(page, 'Welcome back', 25000);
    assert('Unauthenticated /admin Blocked & Redirected to Login', unauthAdminOnLogin);

    console.log('\n--- 2. UNAUTHENTICATED URL ACCESS TO /coach ---');
    await page.goto(`${BASE_URL}/#/coach`, { waitUntil: 'domcontentloaded' });
    await enableFlutterSemantics(page);
    const unauthCoachOnLogin = await waitForText(page, 'Welcome back', 15000);
    assert('Unauthenticated /coach Blocked & Redirected to Login', unauthCoachOnLogin);

    console.log('\n--- 3. UNAUTHENTICATED URL ACCESS TO /player ---');
    await page.goto(`${BASE_URL}/#/player`, { waitUntil: 'domcontentloaded' });
    await enableFlutterSemantics(page);
    const unauthPlayerOnLogin = await waitForText(page, 'Welcome back', 15000);
    assert('Unauthenticated /player Blocked & Redirected to Login', unauthPlayerOnLogin);

    // 2. PLAYER ATTEMPTING TO ACCESS /admin WORKSPACE
    console.log('\n--- 4. AUTHENTICATED PLAYER ACCESSING /admin ---');
    console.log('Logging in as active player...');
    await loginViaUI(page, 'staging-player-active@psa-academy.test', 'Password123!');
    await waitForText(page, 'Player Membership & Pass', 15000);

    console.log('Directly navigating player to /#/admin URL...');
    await page.goto(`${BASE_URL}/#/admin`, { waitUntil: 'domcontentloaded' });
    await enableFlutterSemantics(page);

    // Player should be sanitized and blocked from admin, landing safely on player workspace
    const playerSafelyContained =
      (await waitForText(page, 'Player Membership & Pass', 15000)) ||
      (await waitForText(page, 'Access Restricted', 5000));
    assert('Player Prevented from Accessing /admin', playerSafelyContained);

    const playerPageContent = await getAllVisibleText(page);
    assert('Admin Data NOT Leaked to Player', !playerPageContent.includes('Admin Dashboard & Operations') && !playerPageContent.includes('Record Payment'));

    // Logout player
    console.log('Logging out player...');
    await clickButtonByText(page, 'Logout');
    await waitForText(page, 'Welcome back', 10000);

    // 3. COACH ATTEMPTING TO ACCESS /admin WORKSPACE
    console.log('\n--- 5. AUTHENTICATED COACH ACCESSING /admin ---');
    console.log('Logging in as coach...');
    await loginViaUI(page, 'staging-coach@psa-academy.test', 'Password123!');
    await waitForText(page, 'Coach Shift & Scanner', 15000);

    console.log('Directly navigating coach to /#/admin URL...');
    await page.goto(`${BASE_URL}/#/admin`, { waitUntil: 'domcontentloaded' });
    await enableFlutterSemantics(page);

    const coachSafelyContained =
      (await waitForText(page, 'Coach Shift & Scanner', 15000)) ||
      (await waitForText(page, 'Access Restricted', 5000));
    assert('Coach Prevented from Accessing /admin', coachSafelyContained);

    const coachPageContent = await getAllVisibleText(page);
    assert('Admin Data NOT Leaked to Coach', !coachPageContent.includes('Admin Dashboard & Operations') && !coachPageContent.includes('Record Payment'));

    // Logout coach
    console.log('Logging out coach...');
    await clickButtonByText(page, 'Logout');
    await waitForText(page, 'Welcome back', 10000);
  } finally {
    await browser.close();
  }

  console.log('\n====================================================');
  console.log(`ROUTE GUARDS SUITE FINISHED: ${passes} PASSED, ${fails} FAILED`);
  console.log('====================================================');

  if (fails > 0) process.exit(1);
}

runRouteGuards().catch((err) => {
  console.error('Route Guards Suite Failed:', err);
  process.exit(1);
});
