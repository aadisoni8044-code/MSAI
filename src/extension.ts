import * as vscode from 'vscode';
import { AudioPlayer } from './audio/audioPlayer';
import { SoundManager } from './audio/soundManager';
import { StatusBarManager } from './statusBar/statusBar';
import { registerCommands } from './commands/commands';
import { SettingsManager } from './settings/settings';
import { showWelcomeWebview } from './ui/welcomeWebview';

export function activate(context: vscode.ExtensionContext) {
    console.log('[Keyboard Sound] Extension activating...');

    // 1. Initialize Audio Engine Panel
    const audioPlayer = new AudioPlayer(context.extensionUri);

    // 2. Initialize Sound Manager
    const soundManager = new SoundManager(audioPlayer, context.extensionUri);

    // 3. Initialize Settings Manager
    const settingsManager = new SettingsManager(soundManager);
    settingsManager.registerChangeListener(context);

    // 4. Initialize Status Bar Manager
    const statusBarManager = new StatusBarManager(soundManager);
    context.subscriptions.push(statusBarManager);

    // 5. Register Extension Commands
    registerCommands(context, soundManager, statusBarManager);

    // 6. Register Text Document Typing Listener (Ultra-low latency typing event capture)
    context.subscriptions.push(
        vscode.workspace.onDidChangeTextDocument((event: vscode.TextDocumentChangeEvent) => {
            if (!event.contentChanges || event.contentChanges.length === 0) {
                return;
            }

            const change = event.contentChanges[0];
            const insertedText = change.text;

            soundManager.handleTypingEvent(insertedText);
        })
    );

    // 7. Show Welcome Webview on First Launch
    showWelcomeWebview(context);

    console.log('[Keyboard Sound] Extension successfully activated.');
}

export function deactivate() {
    console.log('[Keyboard Sound] Extension deactivated.');
}
