import * as vscode from 'vscode';
import { SoundManager } from '../audio/soundManager';

export class StatusBarManager {
    private statusBarItem: vscode.StatusBarItem;
    private soundManager: SoundManager;

    constructor(soundManager: SoundManager) {
        this.soundManager = soundManager;
        this.statusBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Right,
            100
        );
        this.statusBarItem.command = 'keyboardSound.toggle';
        this.update();
        this.statusBarItem.show();
    }

    public update() {
        const enabled = this.soundManager.isEnabled();
        const vol = this.soundManager.getVolume();
        const pack = this.soundManager.getSoundPack();

        if (enabled) {
            this.statusBarItem.text = `$(volume) Keyboard Sound: ON (${vol}%)`;
            this.statusBarItem.tooltip = `Keyboard Sound: Enabled | Pack: ${pack} | Volume: ${vol}%\nClick to disable`;
        } else {
            this.statusBarItem.text = `$(mute) Keyboard Sound: OFF`;
            this.statusBarItem.tooltip = `Keyboard Sound: Disabled\nClick to enable`;
        }
    }

    public dispose() {
        this.statusBarItem.dispose();
    }
}
