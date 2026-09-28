import * as vscode from 'vscode';
import { SoundManager } from '../audio/soundManager';
import { StatusBarManager } from '../statusBar/statusBar';

export function registerCommands(
    context: vscode.ExtensionContext,
    soundManager: SoundManager,
    statusBarManager: StatusBarManager
) {
    const updateConfig = async (key: string, value: any) => {
        const config = vscode.workspace.getConfiguration('keyboardSound');
        await config.update(key, value, vscode.ConfigurationTarget.Global);
        soundManager.reloadConfiguration();
        statusBarManager.update();
    };

    // Enable Command
    context.subscriptions.push(
        vscode.commands.registerCommand('keyboardSound.enable', async () => {
            await updateConfig('enabled', true);
            vscode.window.showInformationMessage('🔊 Keyboard Sound Enabled');
        })
    );

    // Disable Command
    context.subscriptions.push(
        vscode.commands.registerCommand('keyboardSound.disable', async () => {
            await updateConfig('enabled', false);
            vscode.window.showInformationMessage('🔇 Keyboard Sound Disabled');
        })
    );

    // Toggle Command
    context.subscriptions.push(
        vscode.commands.registerCommand('keyboardSound.toggle', async () => {
            const config = vscode.workspace.getConfiguration('keyboardSound');
            const current = config.get<boolean>('enabled', true);
            await updateConfig('enabled', !current);
            const msg = !current ? '🔊 Keyboard Sound Enabled' : '🔇 Keyboard Sound Disabled';
            vscode.window.showInformationMessage(msg);
        })
    );

    // Test Sound Command
    context.subscriptions.push(
        vscode.commands.registerCommand('keyboardSound.testSound', async () => {
            vscode.window.showInformationMessage('🎵 Playing Mechanical Keyboard Sound Test...');
            await soundManager.playTestSequence();
        })
    );

    // Open Settings Command
    context.subscriptions.push(
        vscode.commands.registerCommand('keyboardSound.openSettings', () => {
            vscode.commands.executeCommand('workbench.action.openSettings', 'keyboardSound');
        })
    );

    // Select Sound Pack Command
    context.subscriptions.push(
        vscode.commands.registerCommand('keyboardSound.selectSoundPack', async () => {
            const items: vscode.QuickPickItem[] = [
                {
                    label: '$(symbol-key) Mechanical',
                    description: 'Classic mechanical switch key sound pack',
                    detail: 'mechanical'
                },
                {
                    label: '$(layers) Thock',
                    description: 'Deep mechanical thock sound pack',
                    detail: 'thock'
                },
                {
                    label: '$(edit) Typewriter',
                    description: 'Classic tactile typewriter sound pack',
                    detail: 'typewriter'
                }
            ];

            const selected = await vscode.window.showQuickPick(items, {
                placeHolder: 'Select active mechanical keyboard sound pack'
            });

            if (selected && selected.detail) {
                await updateConfig('soundPack', selected.detail);
                soundManager.playSpecialSound('click');
                vscode.window.showInformationMessage(`Keyboard Sound Pack set to: ${selected.label}`);
            }
        })
    );

    // Set Volume Command
    context.subscriptions.push(
        vscode.commands.registerCommand('keyboardSound.setVolume', async () => {
            const presets: vscode.QuickPickItem[] = [
                { label: '🔇 Mute (0%)', detail: '0' },
                { label: '🔈 Low (30%)', detail: '30' },
                { label: '🔉 Medium (50%)', detail: '50' },
                { label: '🔊 High (70%)', detail: '70' },
                { label: '💥 Very High (100%)', detail: '100' },
                { label: '⚙ Custom Volume...', detail: 'custom' }
            ];

            const selected = await vscode.window.showQuickPick(presets, {
                placeHolder: 'Select Volume Level'
            });

            if (!selected) return;

            let newVol = 70;
            if (selected.detail === 'custom') {
                const input = await vscode.window.showInputBox({
                    prompt: 'Enter volume percentage (0 - 100)',
                    value: soundManager.getVolume().toString(),
                    validateInput: (val) => {
                        const num = parseInt(val, 10);
                        if (isNaN(num) || num < 0 || num > 100) {
                            return 'Please enter a valid number between 0 and 100';
                        }
                        return null;
                    }
                });
                if (input !== undefined) {
                    newVol = parseInt(input, 10);
                } else {
                    return;
                }
            } else if (selected.detail) {
                newVol = parseInt(selected.detail, 10);
            }

            await updateConfig('volume', newVol);
            soundManager.playSpecialSound('click');
            vscode.window.showInformationMessage(`Keyboard Sound Volume set to: ${newVol}%`);
        })
    );
}
