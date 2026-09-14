const { chromium } = require('playwright');

(async () => {
    const browser = await chromium.launch({ headless: true });
    const page = await browser.newPage({ viewport: { width: 1280, height: 720 } });

    page.on('console', msg => console.log('PAGE LOG:', msg.text()));
    page.on('pageerror', err => console.error('PAGE ERROR:', err.message));

    console.log('Navigating to game...');
    await page.goto('http://localhost:8080/index.html');
    await page.waitForTimeout(1000);

    console.log('Clicking NEW GAME...');
    await page.click('#btn-play');
    await page.waitForTimeout(1000);

    console.log('Simulating player movement & actions (Jump, Attack, Dash)...');
    await page.keyboard.press('KeyD');
    await page.waitForTimeout(300);
    await page.keyboard.press('Space');
    await page.waitForTimeout(300);
    await page.keyboard.press('KeyJ');
    await page.waitForTimeout(300);
    await page.keyboard.press('ShiftLeft');
    await page.waitForTimeout(500);

    console.log('Capturing game screenshot...');
    await page.screenshot({ path: 'screenshot_game.png' });

    console.log('Testing Mobile Viewport...');
    const mobileContext = await browser.newContext({
        viewport: { width: 844, height: 390 },
        isMobile: true,
        hasTouch: true
    });
    const mobilePage = await mobileContext.newPage();
    await mobilePage.goto('http://localhost:8080/index.html');
    await mobilePage.waitForTimeout(1000);
    await mobilePage.click('#btn-play');
    await mobilePage.waitForTimeout(1000);
    await mobilePage.screenshot({ path: 'screenshot_mobile.png' });

    await browser.close();
    console.log('Verification Complete!');
})();
