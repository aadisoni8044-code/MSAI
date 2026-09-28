import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';

export interface SoundFileMap {
    click: string[];
    space: string;
    enter: string;
    backspace: string;
    tab: string;
    delete: string;
}

export class AudioPlayer {
    private _panel?: vscode.WebviewPanel;
    private extensionUri: vscode.Uri;
    private isReady: boolean = false;
    private pendingMessages: any[] = [];

    constructor(extensionUri: vscode.Uri) {
        this.extensionUri = extensionUri;
        this.createHiddenPanel();
    }

    private createHiddenPanel() {
        if (this._panel) return;

        this._panel = vscode.window.createWebviewPanel(
            'keyboardSoundAudioEngine',
            'Keyboard Sound Engine',
            { viewColumn: vscode.ViewColumn.Eight, preserveFocus: true },
            {
                enableScripts: true,
                retainContextWhenHidden: true,
                localResourceRoots: [this.extensionUri]
            }
        );

        this._panel.webview.html = this.getHtmlForWebview();

        this._panel.webview.onDidReceiveMessage((message) => {
            if (message.type === 'ready') {
                this.isReady = true;
                this.flushPendingMessages();
            } else if (message.type === 'error') {
                console.error('[Keyboard Sound AudioEngine]', message.message);
            }
        });

        this._panel.onDidDispose(() => {
            this._panel = undefined;
            this.isReady = false;
        });
    }

    private ensurePanel() {
        if (!this._panel) {
            this.createHiddenPanel();
        }
    }

    private flushPendingMessages() {
        if (this._panel && this.isReady) {
            while (this.pendingMessages.length > 0) {
                const msg = this.pendingMessages.shift();
                this._panel.webview.postMessage(msg);
            }
        }
    }

    private sendMessage(message: any) {
        this.ensurePanel();
        if (this._panel && this.isReady) {
            this._panel.webview.postMessage(message);
        } else {
            this.pendingMessages.push(message);
        }
    }

    public loadSoundPack(packName: string, soundMap: SoundFileMap) {
        const loadedSounds: Record<string, string> = {};

        try {
            soundMap.click.forEach((relPath, index) => {
                const fullPath = path.join(this.extensionUri.fsPath, relPath);
                if (fs.existsSync(fullPath)) {
                    const data = fs.readFileSync(fullPath).toString('base64');
                    loadedSounds[`click${index + 1}`] = `data:audio/wav;base64,${data}`;
                }
            });

            const specialKeys: (keyof Omit<SoundFileMap, 'click'>)[] = ['space', 'enter', 'backspace', 'tab', 'delete'];
            specialKeys.forEach((key) => {
                const relPath = soundMap[key];
                const fullPath = path.join(this.extensionUri.fsPath, relPath);
                if (fs.existsSync(fullPath)) {
                    const data = fs.readFileSync(fullPath).toString('base64');
                    loadedSounds[key] = `data:audio/wav;base64,${data}`;
                }
            });

            this.sendMessage({
                type: 'loadPack',
                packName,
                sounds: loadedSounds
            });
        } catch (err) {
            console.error('Error reading sound files for Web Audio engine:', err);
            vscode.window.showErrorMessage('Keyboard Sound: Unable to load sound pack files.');
        }
    }

    public playSound(soundKey: string, volume: number) {
        this.sendMessage({
            type: 'playSound',
            soundKey,
            volume: Math.max(0, Math.min(100, volume))
        });
    }

    public setVolume(volume: number) {
        this.sendMessage({
            type: 'setVolume',
            volume: Math.max(0, Math.min(100, volume))
        });
    }

    private getHtmlForWebview(): string {
        return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Keyboard Sound Audio Engine</title>
</head>
<body>
    <script>
        const vscode = acquireVsCodeApi();
        let audioCtx = null;
        const soundBuffers = new Map();
        let globalVolume = 0.7;

        function initAudio() {
            if (!audioCtx) {
                const AudioContext = window.AudioContext || window.webkitAudioContext;
                audioCtx = new AudioContext();
            }
            if (audioCtx.state === 'suspended') {
                audioCtx.resume();
            }
        }

        window.addEventListener('message', async (event) => {
            const message = event.data;
            initAudio();

            switch (message.type) {
                case 'loadPack':
                    soundBuffers.clear();
                    for (const [key, dataUri] of Object.entries(message.sounds)) {
                        try {
                            const res = await fetch(dataUri);
                            const arrayBuffer = await res.arrayBuffer();
                            const audioBuffer = await audioCtx.decodeAudioData(arrayBuffer);
                            soundBuffers.set(key, audioBuffer);
                        } catch (err) {
                            vscode.postMessage({ type: 'error', message: 'Failed to decode sound: ' + key });
                        }
                    }
                    break;

                case 'setVolume':
                    globalVolume = message.volume / 100;
                    break;

                case 'playSound':
                    if (!audioCtx) return;
                    const buffer = soundBuffers.get(message.soundKey);
                    if (!buffer) return;

                    const vol = (message.volume !== undefined ? message.volume / 100 : globalVolume);
                    if (vol <= 0) return;

                    const source = audioCtx.createBufferSource();
                    source.buffer = buffer;

                    const gainNode = audioCtx.createGain();
                    gainNode.gain.value = Math.pow(vol, 1.5) * 1.2;

                    source.connect(gainNode);
                    gainNode.connect(audioCtx.destination);

                    source.start(0);
                    break;
            }
        });

        vscode.postMessage({ type: 'ready' });
    </script>
</body>
</html>`;
    }
}
