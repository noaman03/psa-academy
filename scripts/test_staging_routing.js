const puppeteer = require('../test/rules_tests/node_modules/puppeteer-core');

async function testRouting() {
  console.log('=== Testing Hosted Staging Routing with Chrome ===');
  const browser = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });
  const page = await browser.newPage();

  const errors = [];
  page.on('pageerror', (err) => errors.push(err.message));
  page.on('console', (msg) => {
    if (msg.type() === 'error') errors.push(msg.text());
  });

  const routes = ['/', '/admin', '/coach', '/player'];
  for (const route of routes) {
    const url = 'https://psa-academy-staging.web.app' + route;
    const res = await page.goto(url, { waitUntil: 'networkidle0', timeout: 30000 });
    const title = await page.title();
    console.log(`Route [${route}]: HTTP Status = ${res.status()}, Final URL = ${page.url()}, Title = ${title}`);
  }

  // Refresh test
  await page.goto('https://psa-academy-staging.web.app/admin', { waitUntil: 'networkidle0' });
  const refreshRes = await page.reload({ waitUntil: 'networkidle0' });
  console.log(`Reload [/admin]: HTTP Status = ${refreshRes.status()}, Final URL = ${page.url()}`);

  // Browser back & forward test
  try {
    await page.goto('https://psa-academy-staging.web.app/', { waitUntil: 'networkidle0' });
    await page.goto('https://psa-academy-staging.web.app/login', { waitUntil: 'networkidle0' });
    if (await page.goBack({ waitUntil: 'networkidle0' })) {
      console.log(`GoBack: Final URL = ${page.url()}`);
    }
    if (await page.goForward({ waitUntil: 'networkidle0' })) {
      console.log(`GoForward: Final URL = ${page.url()}`);
    }
  } catch (histErr) {
    console.log('History navigation note:', histErr.message);
  }

  console.log('Console / Page Errors count:', errors.length);
  if (errors.length > 0) {
    console.log('Errors:', errors.slice(0, 5));
  }

  await browser.close();
  console.log('=== Routing Tests Finished ===');
}

testRouting().catch((err) => {
  console.error('Routing Test Failed:', err);
  process.exit(1);
});
