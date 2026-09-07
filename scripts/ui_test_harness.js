/**
 * Reusable Flutter Web UI Test Helper for Puppeteer Automation
 */
const puppeteer = require('../test/rules_tests/node_modules/puppeteer-core');
const path = require('path');
const fs = require('fs');

const CHROME_PATH = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';
const EDGE_PATH = 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe';

async function createBrowser(options = {}) {
  const browserPath = options.browser === 'edge' ? EDGE_PATH : CHROME_PATH;
  const browser = await puppeteer.launch({
    executablePath: browserPath,
    headless: options.headless !== undefined ? options.headless : true,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--window-size=1440,900',
    ],
  });
  return browser;
}

async function setupPage(browser, options = {}) {
  const page = await browser.newPage();
  const width = options.width || 1440;
  const height = options.height || 900;
  await page.setViewport({ width, height });

  if (options.downloadPath) {
    const client = await page.target().createCDPSession();
    await client.send('Page.setDownloadBehavior', {
      behavior: 'allow',
      downloadPath: path.resolve(options.downloadPath),
    });
  }

  const errors = [];
  page.on('pageerror', (err) => errors.push(err.message));
  page.on('console', (msg) => {
    if (msg.type() === 'error') errors.push(msg.text());
  });

  return { page, errors };
}

async function enableFlutterSemantics(page) {
  await page.waitForSelector('flt-semantics-placeholder', { timeout: 20000 }).catch(() => {});
  await page.evaluate(() => {
    const p = document.querySelector('flt-semantics-placeholder');
    if (p) p.click();
  });
  await new Promise((r) => setTimeout(r, 1500));
}

async function typeIntoInput(page, inputHandle, text) {
  if (!inputHandle) return;
  await inputHandle.focus();
  await inputHandle.click({ clickCount: 3 });
  await page.keyboard.press('Backspace');
  await page.evaluate((el) => {
    el.value = '';
  }, inputHandle);
  await new Promise((r) => setTimeout(r, 100));
  await page.keyboard.type(text, { delay: 30 });
  await new Promise((r) => setTimeout(r, 200));
}

async function clickButtonByText(page, buttonText) {
  return page.evaluate((text) => {
    const target = text.trim().toLowerCase();
    const selector = 'flt-semantics[role="button"], flt-semantics[role="tab"], button';
    const elements = Array.from(document.querySelectorAll(selector));

    // 1. Try exact match first
    let found = elements.find((el) => {
      const t = (el.innerText || el.textContent || el.getAttribute('aria-label') || '').trim().toLowerCase();
      return t === target;
    });

    // 2. Fallback: starts with target
    if (!found) {
      found = elements.find((el) => {
        const t = (el.innerText || el.textContent || el.getAttribute('aria-label') || '').trim().toLowerCase();
        return t.startsWith(target);
      });
    }

    // 3. Fallback: contains target on element without nested buttons
    if (!found) {
      found = elements.find((el) => {
        const t = (el.innerText || el.textContent || el.getAttribute('aria-label') || '').trim().toLowerCase();
        return t.includes(target);
      });
    }

    if (found) {
      found.click();
      return true;
    }
    return false;
  }, buttonText);
}

async function clickCardByText(page, text) {
  return page.evaluate((t) => {
    const target = t.trim().toLowerCase();
    const selector = 'flt-semantics[role="group"], flt-semantics[role="button"], flt-semantics';
    const elements = Array.from(document.querySelectorAll(selector));
    for (const el of elements) {
      const aria = (el.getAttribute('aria-label') || '').trim().toLowerCase();
      const inner = (el.innerText || el.textContent || '').trim().toLowerCase();
      if (aria.includes(target) || inner.includes(target)) {
        el.click();
        return true;
      }
    }
    return false;
  }, text);
}

async function getAllVisibleText(page) {
  return page.evaluate(() => {
    const host = document.querySelector('flt-semantics-host') || document.body;
    const all = Array.from(host.querySelectorAll('*'));
    const strings = all.map((el) => {
      const text = (el.innerText || el.textContent || '').trim();
      const aria = (el.getAttribute('aria-label') || '').trim();
      return `${text} ${aria}`;
    });
    const announcements = Array.from(
      document.querySelectorAll('flt-announcement-polite, flt-announcement-assertive')
    ).map((el) => (el.innerText || el.textContent || '').trim());
    return `${strings.join('\n')}\n${announcements.join('\n')}`;
  });
}

async function waitForText(page, text, timeout = 10000) {
  const start = Date.now();
  while (Date.now() - start < timeout) {
    const content = await getAllVisibleText(page);
    if (content.toLowerCase().includes(text.toLowerCase())) {
      return true;
    }
    await new Promise((r) => setTimeout(r, 300));
  }
  return false;
}

async function loginViaUI(page, email, password) {
  await page.goto('https://psa-academy-staging.web.app/login', { waitUntil: 'domcontentloaded', timeout: 30000 });
  await new Promise((r) => setTimeout(r, 2000));
  await enableFlutterSemantics(page);

  const emailInput = (await page.$('input[type="email"]')) || (await page.$('input[type="text"]'));
  const pwdInput = await page.$('input[type="password"]');

  if (!emailInput || !pwdInput) {
    throw new Error('Login form inputs not found');
  }

  await typeIntoInput(page, emailInput, email);
  await typeIntoInput(page, pwdInput, password);

  await clickButtonByText(page, 'Sign In');
  await new Promise((r) => setTimeout(r, 5000));
}

module.exports = {
  createBrowser,
  setupPage,
  enableFlutterSemantics,
  typeIntoInput,
  clickButtonByText,
  clickCardByText,
  getAllVisibleText,
  waitForText,
  loginViaUI,
};
