import { test, expect } from '@playwright/test';

test('Verify MS AI UI Flow and Functionality', async ({ page }) => {
  // 1. Visit App
  await page.goto('http://localhost:5173/');

  // 2. Onboarding Screen Check
  await expect(page.locator('#onboarding-headline')).toHaveText('Discover Intelligence with MS AI');
  await page.click('#btn-get-started-onboarding');

  // 3. Auth Screen Check
  await expect(page.locator('#auth-title')).toHaveText('Sign In To Your Account.');

  // Fill credentials and sign in
  await page.fill('#auth-email', 'test.user@example.com');
  await page.fill('#auth-password', 'password123');
  await page.click('#btn-auth-submit');

  // 4. Main Chat Interface Check
  await expect(page.locator('.empty-state-heading')).toHaveText('What can I help with?');

  // Test Quick Action pill
  await page.click('button[data-action="code"]');
  const inputVal = await page.inputValue('#empty-chat-input');
  expect(inputVal).toContain('Write a clean TypeScript function');

  // Test sending message
  await page.click('#btn-send-empty');

  // Active thread should be visible
  await expect(page.locator('#active-thread-view')).toBeVisible();

  // Wait for AI response message bubble
  await page.waitForSelector('.message-row.model');
  const responseBubble = page.locator('.message-row.model .message-bubble');
  await expect(responseBubble).not.toBeEmpty();

  // Capture screenshot
  await page.screenshot({ path: 'verification_screenshot.png', fullPage: true });
});
