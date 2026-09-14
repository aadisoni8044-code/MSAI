/* Web Audio API Synthesizer & Audio Manager */
class AudioManager {
    constructor() {
        this.ctx = null;
        this.musicVolume = 0.7;
        this.sfxVolume = 0.8;
        this.isMuted = false;
        this.currentBgm = null;
        this.bgmOscillators = [];
        this.bgmTimer = null;

        this.initialized = false;
    }

    init() {
        if (this.initialized) return;
        try {
            const AudioContext = window.AudioContext || window.webkitAudioContext;
            if (AudioContext) {
                this.ctx = new AudioContext();
                this.initialized = true;
            }
        } catch (e) {
            console.warn('AudioContext not supported:', e);
        }
    }

    ensureContext() {
        if (!this.ctx) this.init();
        if (this.ctx && this.ctx.state === 'suspended') {
            this.ctx.resume();
        }
    }

    setMusicVolume(vol) {
        this.musicVolume = Math.max(0, Math.min(1, vol));
    }

    setSfxVolume(vol) {
        this.sfxVolume = Math.max(0, Math.min(1, vol));
    }

    playJump() {
        if (!this.sfxVolume) return;
        this.ensureContext();
        if (!this.ctx) return;

        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();

        osc.type = 'sine';
        const now = this.ctx.currentTime;
        osc.frequency.setValueAtTime(150, now);
        osc.frequency.exponentialRampToValueAtTime(400, now + 0.15);

        gain.gain.setValueAtTime(0.3 * this.sfxVolume, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + 0.15);

        osc.connect(gain);
        gain.connect(this.ctx.destination);

        osc.start(now);
        osc.stop(now + 0.15);
    }

    playAttack() {
        if (!this.sfxVolume) return;
        this.ensureContext();
        if (!this.ctx) return;

        const now = this.ctx.currentTime;
        // Sword slash noise + frequency drop
        const bufferSize = this.ctx.sampleRate * 0.12;
        const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
        const data = buffer.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
            data[i] = Math.random() * 2 - 1;
        }

        const noise = this.ctx.createBufferSource();
        noise.buffer = buffer;

        const filter = this.ctx.createBiquadFilter();
        filter.type = 'bandpass';
        filter.frequency.setValueAtTime(800, now);
        filter.frequency.exponentialRampToValueAtTime(200, now + 0.12);
        filter.Q.value = 3;

        const gain = this.ctx.createGain();
        gain.gain.setValueAtTime(0.4 * this.sfxVolume, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + 0.12);

        noise.connect(filter);
        filter.connect(gain);
        gain.connect(this.ctx.destination);

        noise.start(now);
    }

    playDash() {
        if (!this.sfxVolume) return;
        this.ensureContext();
        if (!this.ctx) return;

        const now = this.ctx.currentTime;
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();

        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(300, now);
        osc.frequency.exponentialRampToValueAtTime(80, now + 0.18);

        gain.gain.setValueAtTime(0.35 * this.sfxVolume, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + 0.18);

        osc.connect(gain);
        gain.connect(this.ctx.destination);

        osc.start(now);
        osc.stop(now + 0.18);
    }

    playHit() {
        if (!this.sfxVolume) return;
        this.ensureContext();
        if (!this.ctx) return;

        const now = this.ctx.currentTime;
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();

        osc.type = 'square';
        osc.frequency.setValueAtTime(120, now);
        osc.frequency.exponentialRampToValueAtTime(30, now + 0.2);

        gain.gain.setValueAtTime(0.5 * this.sfxVolume, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + 0.2);

        osc.connect(gain);
        gain.connect(this.ctx.destination);

        osc.start(now);
        osc.stop(now + 0.2);
    }

    playCollect(type = 'coin') {
        if (!this.sfxVolume) return;
        this.ensureContext();
        if (!this.ctx) return;

        const now = this.ctx.currentTime;
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();

        osc.type = 'sine';

        if (type === 'crystal') {
            osc.frequency.setValueAtTime(523.25, now); // C5
            osc.frequency.setValueAtTime(659.25, now + 0.08); // E5
            osc.frequency.setValueAtTime(783.99, now + 0.16); // G5
        } else if (type === 'key') {
            osc.frequency.setValueAtTime(440, now);
            osc.frequency.setValueAtTime(880, now + 0.1);
        } else {
            // coin
            osc.frequency.setValueAtTime(987.77, now); // B5
            osc.frequency.setValueAtTime(1318.51, now + 0.08); // E6
        }

        gain.gain.setValueAtTime(0.25 * this.sfxVolume, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + 0.25);

        osc.connect(gain);
        gain.connect(this.ctx.destination);

        osc.start(now);
        osc.stop(now + 0.25);
    }

    playVictory() {
        if (!this.sfxVolume) return;
        this.ensureContext();
        if (!this.ctx) return;

        const notes = [261.63, 329.63, 392.00, 523.25]; // C E G C
        notes.forEach((freq, idx) => {
            const now = this.ctx.currentTime + idx * 0.12;
            const osc = this.ctx.createOscillator();
            const gain = this.ctx.createGain();

            osc.type = 'triangle';
            osc.frequency.setValueAtTime(freq, now);

            gain.gain.setValueAtTime(0.3 * this.sfxVolume, now);
            gain.gain.exponentialRampToValueAtTime(0.01, now + 0.3);

            osc.connect(gain);
            gain.connect(this.ctx.destination);

            osc.start(now);
            osc.stop(now + 0.3);
        });
    }

    playBossRoar() {
        if (!this.sfxVolume) return;
        this.ensureContext();
        if (!this.ctx) return;

        const now = this.ctx.currentTime;
        const osc = this.ctx.createOscillator();
        const gain = this.ctx.createGain();

        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(60, now);
        osc.frequency.linearRampToValueAtTime(120, now + 0.4);
        osc.frequency.exponentialRampToValueAtTime(40, now + 0.8);

        gain.gain.setValueAtTime(0.6 * this.sfxVolume, now);
        gain.gain.exponentialRampToValueAtTime(0.01, now + 0.8);

        osc.connect(gain);
        gain.connect(this.ctx.destination);

        osc.start(now);
        osc.stop(now + 0.8);
    }

    startBgm(type = 'forest') {
        this.stopBgm();
        this.ensureContext();
        if (!this.ctx || !this.musicVolume) return;

        this.currentBgm = type;
        const playAmbientLoop = () => {
            if (this.currentBgm !== type) return;
            const now = this.ctx.currentTime;
            const scale = type === 'boss'
                ? [110, 123.47, 130.81, 146.83, 164.81] // Dark minor pentatonic
                : [220, 246.94, 277.18, 329.63, 369.99]; // Ethereal pad scale

            const freq = scale[Math.floor(Math.random() * scale.length)];
            const osc = this.ctx.createOscillator();
            const gain = this.ctx.createGain();

            osc.type = type === 'boss' ? 'sawtooth' : 'sine';
            osc.frequency.setValueAtTime(freq, now);

            const duration = type === 'boss' ? 0.4 : 1.2;
            gain.gain.setValueAtTime(0.01, now);
            gain.gain.linearRampToValueAtTime(0.08 * this.musicVolume, now + 0.2);
            gain.gain.exponentialRampToValueAtTime(0.001, now + duration);

            osc.connect(gain);
            gain.connect(this.ctx.destination);

            osc.start(now);
            osc.stop(now + duration);

            const nextInterval = type === 'boss' ? 400 : 900;
            this.bgmTimer = setTimeout(playAmbientLoop, nextInterval);
        };

        playAmbientLoop();
    }

    stopBgm() {
        this.currentBgm = null;
        if (this.bgmTimer) {
            clearTimeout(this.bgmTimer);
            this.bgmTimer = null;
        }
    }
}

window.audioManager = new AudioManager();
