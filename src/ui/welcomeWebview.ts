import * as vscode from 'vscode';

export function showWelcomeWebview(context: vscode.ExtensionContext) {
    const hasShown = context.globalState.get<boolean>('keyboardSoundWelcomeShown', false);
    if (hasShown) {
        return;
    }

    const panel = vscode.window.createWebviewPanel(
        'keyboardSoundWelcome',
        'Welcome to Keyboard Sound',
        vscode.ViewColumn.One,
        { enableScripts: true }
    );

    panel.webview.html = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Keyboard Sound</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            padding: 2rem;
            line-height: 1.6;
            color: var(--vscode-foreground);
            background-color: var(--vscode-editor-background);
            max-width: 680px;
            margin: 0 auto;
        }
        h1 {
            font-size: 2.2rem;
            margin-bottom: 0.5rem;
            color: var(--vscode-textLink-foreground);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .subtitle {
            font-size: 1.1rem;
            color: var(--vscode-descriptionForeground);
            margin-bottom: 2rem;
        }
        .feature-card {
            background-color: var(--vscode-card-background, rgba(255, 255, 255, 0.05));
            border: 1px solid var(--vscode-widget-border, rgba(255, 255, 255, 0.1));
            border-radius: 8px;
            padding: 1.2rem;
            margin-bottom: 1rem;
        }
        .feature-card h3 {
            margin-top: 0;
            margin-bottom: 0.5rem;
            color: var(--vscode-symbolIcon-propertyForeground);
        }
        .btn-group {
            margin-top: 2rem;
            display: flex;
            gap: 1rem;
        }
        button {
            background-color: var(--vscode-button-background);
            color: var(--vscode-button-foreground);
            border: none;
            padding: 0.7rem 1.4rem;
            font-size: 1rem;
            font-weight: 600;
            border-radius: 4px;
            cursor: pointer;
        }
        button:hover {
            background-color: var(--vscode-button-hoverBackground);
        }
        .meta {
            margin-top: 3rem;
            font-size: 0.9rem;
            color: var(--vscode-descriptionForeground);
            border-top: 1px solid var(--vscode-widget-border, rgba(255, 255, 255, 0.1));
            padding-top: 1rem;
        }
        a {
            color: var(--vscode-textLink-foreground);
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <h1>⌨ KEYBOARD SOUND</h1>
    <div class="subtitle">Make coding sound mechanical with zero typing latency.</div>

    <div class="feature-card">
        <h3>⚡ Ultra-Fast Response</h3>
        <p>Pre-decoded Web Audio API buffers guarantee instant tactile switch clicks on every keystroke without delaying VS Code.</p>
    </div>

    <div class="feature-card">
        <h3>🎧 Multiple Sound Packs</h3>
        <p>Choose between <b>Mechanical</b> switches, deep <b>Thock</b>, or vintage <b>Typewriter</b> audio profiles.</p>
    </div>

    <div class="feature-card">
        <h3>🎛 Custom Volume & Special Key Audio</h3>
        <p>Control audio volume (0%–100%) and enjoy realistic distinct audio sounds for Space, Enter, Backspace, Tab, and Delete.</p>
    </div>

    <div class="btn-group">
        <button id="testBtn">🎵 Test Sound</button>
        <button id="settingsBtn">⚙ Open Settings</button>
    </div>

    <div class="meta">
        Developer: <b>Aadi Soni</b><br>
        GitHub: <a href="https://github.com/aadisoni8044-code">aadisoni8044-code</a> |
        Instagram: <a href="https://www.instagram.com/aadisoni8044/">@aadisoni8044</a> |
        LinkedIn: <a href="https://www.linkedin.com/in/aadi-soni-a9ba35394/?isSelfProfile=true">Aadi Soni</a>
    </div>

    <script>
        const vscode = acquireVsCodeApi();
        document.getElementById('testBtn').addEventListener('click', () => {
            vscode.postMessage({ command: 'test' });
        });
        document.getElementById('settingsBtn').addEventListener('click', () => {
            vscode.postMessage({ command: 'settings' });
        });
    </script>
</body>
</html>`;

    panel.webview.onDidReceiveMessage((message) => {
        if (message.command === 'test') {
            vscode.commands.executeCommand('keyboardSound.testSound');
        } else if (message.command === 'settings') {
            vscode.commands.executeCommand('keyboardSound.openSettings');
        }
    });

    context.globalState.update('keyboardSoundWelcomeShown', true);
}
