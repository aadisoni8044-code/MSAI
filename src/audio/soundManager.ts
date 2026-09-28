import * as vscode from 'vscode';
import * as path from 'path';
import { AudioPlayer, SoundFileMap } from './audioPlayer';

export class SoundManager {
    private audioPlayer: AudioPlayer;
    private extensionUri: vscode.Uri;

    private enabled: boolean = true;
    private volume: number = 70;
    private soundPack: string = 'mechanical';
    private specialKeySounds: boolean = true;
    private randomizeSounds: boolean = true;
    private onlyWhenEditorFocused: boolean = true;

    constructor(audioPlayer: AudioPlayer, extensionUri: vscode.Uri) {
        this.audioPlayer = audioPlayer;
        this.extensionUri = extensionUri;
        this.reloadConfiguration();
    }

    public reloadConfiguration() {
        const config = vscode.workspace.getConfiguration('keyboardSound');
        this.enabled = config.get<boolean>('enabled', true);
        this.volume = config.get<number>('volume', 70);
        this.soundPack = config.get<string>('soundPack', 'mechanical');
        this.specialKeySounds = config.get<boolean>('specialKeySounds', true);
        this.randomizeSounds = config.get<boolean>('randomizeSounds', true);
        this.onlyWhenEditorFocused = config.get<boolean>('onlyWhenEditorFocused', true);

        this.loadCurrentSoundPack();
        this.audioPlayer.setVolume(this.volume);
    }

    public loadCurrentSoundPack() {
        const packDir = path.join('sounds', this.soundPack);
        const map: SoundFileMap = {
            click: [
                path.join(packDir, 'click1.wav'),
                path.join(packDir, 'click2.wav'),
                path.join(packDir, 'click3.wav'),
                path.join(packDir, 'click4.wav')
            ],
            space: path.join(packDir, 'space.wav'),
            enter: path.join(packDir, 'enter.wav'),
            backspace: path.join(packDir, 'backspace.wav'),
            tab: path.join(packDir, 'tab.wav'),
            delete: path.join(packDir, 'delete.wav')
        };

        this.audioPlayer.loadSoundPack(this.soundPack, map);
    }

    public handleTypingEvent(text: string) {
        if (!this.enabled) {
            return;
        }

        if (this.onlyWhenEditorFocused) {
            const activeEditor = vscode.window.activeTextEditor;
            if (!activeEditor) {
                return;
            }
        }

        let soundKey = 'click1';

        if (this.specialKeySounds) {
            if (text === ' ' || text === '  ') {
                soundKey = 'space';
            } else if (text === '\n' || text === '\r\n' || text === '\r') {
                soundKey = 'enter';
            } else if (text === '\t') {
                soundKey = 'tab';
            } else if (text === '') {
                // Deletion / backspace key action
                soundKey = 'backspace';
            } else if (text === 'delete' || text === '\x7f' || text === '\x1b[3~') {
                soundKey = 'delete';
            } else {
                soundKey = this.getRandomClickSound();
            }
        } else {
            soundKey = this.getRandomClickSound();
        }

        this.audioPlayer.playSound(soundKey, this.volume);
    }

    public playSpecialSound(key: 'click' | 'space' | 'enter' | 'backspace' | 'tab' | 'delete') {
        let soundKey = 'click1';
        if (key === 'click') {
            soundKey = this.getRandomClickSound();
        } else {
            soundKey = key;
        }
        this.audioPlayer.playSound(soundKey, this.volume);
    }

    private getRandomClickSound(): string {
        if (this.randomizeSounds) {
            const idx = Math.floor(Math.random() * 4) + 1;
            return `click${idx}`;
        }
        return 'click1';
    }

    public async playTestSequence() {
        const delay = (ms: number) => new Promise(res => setTimeout(res, ms));
        const currentVol = this.volume > 0 ? this.volume : 70;

        const seq = ['click1', 'click2', 'click3', 'click4', 'space', 'enter'];
        for (const sound of seq) {
            this.audioPlayer.playSound(sound, currentVol);
            await delay(120);
        }
    }

    public setVolume(volume: number) {
        this.volume = volume;
        this.audioPlayer.setVolume(volume);
    }

    public setEnabled(enabled: boolean) {
        this.enabled = enabled;
    }

    public isEnabled(): boolean {
        return this.enabled;
    }

    public getVolume(): number {
        return this.volume;
    }

    public getSoundPack(): string {
        return this.soundPack;
    }
}
