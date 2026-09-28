import * as vscode from 'vscode';
import { SoundManager } from '../audio/soundManager';

export class SettingsManager {
    private soundManager: SoundManager;

    constructor(soundManager: SoundManager) {
        this.soundManager = soundManager;
    }

    public registerChangeListener(context: vscode.ExtensionContext) {
        context.subscriptions.push(
            vscode.workspace.onDidChangeConfiguration((e) => {
                if (e.affectsConfiguration('keyboardSound')) {
                    this.soundManager.reloadConfiguration();
                }
            })
        );
    }
}
