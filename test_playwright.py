import asyncio
from playwright.async_api import async_playwright

async def function_test():
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)

        # Test Desktop View
        page = await browser.new_page(viewport={'width': 1280, 'height': 800})
        await page.goto('http://localhost:8080')
        await page.wait_for_timeout(1000)

        # Screenshot Desktop
        await page.screenshot(path='screenshot_desktop.png', full_page=True)
        print("Desktop screenshot captured.")

        # Verify Download links
        win_href = await page.get_attribute('a.btn-windows', 'href')
        win_download = await page.get_attribute('a.btn-windows', 'download')
        apk_href = await page.get_attribute('a.btn-android', 'href')
        apk_download = await page.get_attribute('a.btn-android', 'download')

        print(f"Windows link: {win_href}, download: {win_download}")
        print(f"Android link: {apk_href}, download: {apk_download}")

        # Test Sound Toggle
        sound_btn = page.locator('#soundToggle')
        await sound_btn.click()
        btn_text = await sound_btn.text_content()
        print(f"Sound toggle after click: {btn_text.strip()}")

        # Test Mobile View
        mobile_context = await browser.new_context(viewport={'width': 375, 'height': 667})
        mobile_page = await mobile_context.new_page()
        await mobile_page.goto('http://localhost:8080')
        await mobile_page.wait_for_timeout(1000)
        await mobile_page.screenshot(path='screenshot_mobile.png', full_page=True)
        print("Mobile screenshot captured.")

        # Test Mobile Menu
        menu_btn = mobile_page.locator('#menuToggle')
        await menu_btn.click()
        await mobile_page.wait_for_timeout(500)
        await mobile_page.screenshot(path='screenshot_mobile_menu.png')
        print("Mobile menu screenshot captured.")

        await browser.close()

asyncio.run(function_test())
