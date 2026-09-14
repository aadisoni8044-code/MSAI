/* SYLVAN WHISPERS - WEB AUDIO PROCEDURAL SYNTHESIZER */
window.AudioManager = (function() {
    let ctx = null;
    let musicMasterGain = null;
    let sfxMasterGain = null;
    let isMuted = false;
    let musicVolume = 0.7;
    let sfxVolume = 0.8;
    let ambientTimer = null;
    let isAmbientPlaying = false;

    function init() {
        try {
            const AudioCtx = window.AudioContext || window.webkitAudioContext;
            if (AudioCtx) {
                ctx = new AudioCtx();
                musicMasterGain = ctx.createGain();
                sfxMasterGain = ctx.createGain();

                musicMasterGain.gain.value = musicVolume;
                sfxMasterGain.gain.value = sfxVolume;

                musicMasterGain.connect(ctx.destination);
                sfxMasterGain.connect(ctx.destination);
            }
        } catch (e) {
            console.warn('Web Audio API not supported or blocked:', e);
        }
    }

    function resumeCtx() {
        if (ctx && ctx.state === 'suspended') {
            ctx.resume();
        }
    }

    function setMusicVolume(vol) {
        musicVolume = Math.max(0, Math.min(1, vol));
        if (musicMasterGain && ctx) {
            musicMasterGain.gain.setValueAtTime(musicVolume, ctx.currentTime);
        }
    }

    function setSfxVolume(vol) {
        sfxVolume = Math.max(0, Math.min(1, vol));
        if (sfxMasterGain && ctx) {
            sfxMasterGain.gain.setValueAtTime(sfxVolume, ctx.currentTime);
        }
    }

    // --- PROCEDURAL SOUND EFFECTS ---
    function playJumpSound() {
        if (!ctx || sfxVolume <= 0) return;
        resumeCtx();

        const osc = ctx.createOscillator();
        const gain = ctx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(150, ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(380, ctx.currentTime + 0.15);

        gain.gain.setValueAtTime(0.3 * sfxVolume, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.15);

        osc.connect(gain);
        gain.connect(sfxMasterGain);

        osc.start();
        osc.stop(ctx.currentTime + 0.15);
    }

    function playSlashSound() {
        if (!ctx || sfxVolume <= 0) return;
        resumeCtx();

        // White noise slash effect
        const bufferSize = ctx.sampleRate * 0.1;
        const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
        const data = buffer.getChannelData(0);
        for (let i = 0; i < bufferSize; i++) {
            data[i] = Math.random() * 2 - 1;
        }

        const noise = ctx.createBufferSource();
        noise.buffer = buffer;

        const filter = ctx.createBiquadFilter();
        filter.type = 'bandpass';
        filter.frequency.setValueAtTime(1000, ctx.currentTime);
        filter.frequency.exponentialRampToValueAtTime(300, ctx.currentTime + 0.1);
        filter.Q.value = 3;

        const gain = ctx.createGain();
        gain.gain.setValueAtTime(0.4 * sfxVolume, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.1);

        noise.connect(filter);
        filter.connect(gain);
        gain.connect(sfxMasterGain);

        noise.start();
        noise.stop(ctx.currentTime + 0.1);
    }

    function playHitSound() {
        if (!ctx || sfxVolume <= 0) return;
        resumeCtx();

        const osc = ctx.createOscillator();
        const gain = ctx.createGain();

        osc.type = 'triangle';
        osc.frequency.setValueAtTime(120, ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(40, ctx.currentTime + 0.12);

        gain.gain.setValueAtTime(0.5 * sfxVolume, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.12);

        osc.connect(gain);
        gain.connect(sfxMasterGain);

        osc.start();
        osc.stop(ctx.currentTime + 0.12);
    }

    function playCoinSound() {
        if (!ctx || sfxVolume <= 0) return;
        resumeCtx();

        const osc = ctx.createOscillator();
        const gain = ctx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(600, ctx.currentTime);
        osc.frequency.setValueAtTime(900, ctx.currentTime + 0.08);

        gain.gain.setValueAtTime(0.3 * sfxVolume, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.2);

        osc.connect(gain);
        gain.connect(sfxMasterGain);

        osc.start();
        osc.stop(ctx.currentTime + 0.2);
    }

    function playCheckpointSound() {
        if (!ctx || sfxVolume <= 0) return;
        resumeCtx();

        const notes = [440, 554.37, 659.25, 880];
        notes.forEach((freq, idx) => {
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();

            osc.type = 'sine';
            osc.frequency.setValueAtTime(freq, ctx.currentTime + idx * 0.08);

            gain.gain.setValueAtTime(0.2 * sfxVolume, ctx.currentTime + idx * 0.08);
            gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + idx * 0.08 + 0.3);

            osc.connect(gain);
            gain.connect(sfxMasterGain);

            osc.start(ctx.currentTime + idx * 0.08);
            osc.stop(ctx.currentTime + idx * 0.08 + 0.3);
        });
    }

    function playDamageSound() {
        if (!ctx || sfxVolume <= 0) return;
        resumeCtx();

        const osc = ctx.createOscillator();
        const gain = ctx.createGain();

        osc.type = 'sawtooth';
        osc.frequency.setValueAtTime(180, ctx.currentTime);
        osc.frequency.linearRampToValueAtTime(60, ctx.currentTime + 0.2);

        gain.gain.setValueAtTime(0.4 * sfxVolume, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.2);

        osc.connect(gain);
        gain.connect(sfxMasterGain);

        osc.start();
        osc.stop(ctx.currentTime + 0.2);
    }

    function playClickSound() {
        if (!ctx || sfxVolume <= 0) return;
        resumeCtx();

        const osc = ctx.createOscillator();
        const gain = ctx.createGain();

        osc.type = 'sine';
        osc.frequency.setValueAtTime(400, ctx.currentTime);
        osc.frequency.exponentialRampToValueAtTime(200, ctx.currentTime + 0.04);

        gain.gain.setValueAtTime(0.2 * sfxVolume, ctx.currentTime);
        gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.04);

        osc.connect(gain);
        gain.connect(sfxMasterGain);

        osc.start();
        osc.stop(ctx.currentTime + 0.04);
    }

    // Ambient Forest Music Synthesizer Loop
    function startAmbientMusic() {
        if (isAmbientPlaying) return;
        isAmbientPlaying = true;
        playAmbientChord();
        ambientTimer = setInterval(playAmbientChord, 6000);
    }

    function stopAmbientMusic() {
        isAmbientPlaying = false;
        if (ambientTimer) clearInterval(ambientTimer);
    }

    function playAmbientChord() {
        if (!ctx || musicVolume <= 0 || !isAmbientPlaying) return;
        resumeCtx();

        const chordNotes = [
            [130.81, 196.00, 246.94, 329.63], // Cmaj7 low pad
            [146.83, 220.00, 261.63, 349.23], // Dm7
            [110.00, 164.81, 246.94, 293.66], // Am7
            [174.61, 220.00, 261.63, 329.63]  // Fmaj7
        ];

        const chosenChord = chordNotes[Math.floor(Math.random() * chordNotes.length)];
        chosenChord.forEach(freq => {
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();

            osc.type = 'sine';
            osc.frequency.setValueAtTime(freq, ctx.currentTime);

            gain.gain.setValueAtTime(0.001, ctx.currentTime);
            gain.gain.linearRampToValueAtTime(0.04 * musicVolume, ctx.currentTime + 2.0);
            gain.gain.linearRampToValueAtTime(0.001, ctx.currentTime + 5.5);

            osc.connect(gain);
            gain.connect(musicMasterGain);

            osc.start();
            osc.stop(ctx.currentTime + 5.8);
        });
    }

    return {
        init,
        setMusicVolume,
        setSfxVolume,
        playJump: playJumpSound,
        playSlash: playSlashSound,
        playHit: playHitSound,
        playCoin: playCoinSound,
        playCheckpoint: playCheckpointSound,
        playDamage: playDamageSound,
        playClick: playClickSound,
        startMusic: startAmbientMusic,
        stopMusic: stopAmbientMusic
    };
})();
