const fs = require('fs');
const path = require('path');

function createWavBuffer(samples, sampleRate = 44100) {
    const numChannels = 1;
    const bitsPerSample = 16;
    const byteRate = sampleRate * numChannels * (bitsPerSample / 8);
    const blockAlign = numChannels * (bitsPerSample / 8);
    const dataSize = samples.length * (bitsPerSample / 8);
    const buffer = Buffer.alloc(44 + dataSize);

    // RIFF header
    buffer.write('RIFF', 0);
    buffer.writeUInt32LE(36 + dataSize, 4);
    buffer.write('WAVE', 8);

    // fmt chunk
    buffer.write('fmt ', 12);
    buffer.writeUInt32LE(16, 16); // Chunk size
    buffer.writeUInt16LE(1, 20);  // Audio format (PCM)
    buffer.writeUInt16LE(numChannels, 22);
    buffer.writeUInt32LE(sampleRate, 24);
    buffer.writeUInt32LE(byteRate, 28);
    buffer.writeUInt16LE(blockAlign, 32);
    buffer.writeUInt16LE(bitsPerSample, 34);

    // data chunk
    buffer.write('data', 36);
    buffer.writeUInt32LE(dataSize, 40);

    for (let i = 0; i < samples.length; i++) {
        let s = Math.max(-1, Math.min(1, samples[i]));
        let val = s < 0 ? s * 0x8000 : s * 0x7FFF;
        buffer.writeInt16LE(Math.round(val), 44 + i * 2);
    }

    return buffer;
}

function synthesizeSound(style, type, variation = 0) {
    const sampleRate = 44100;
    let duration = 0.08; // seconds

    if (type === 'space') duration = 0.12;
    else if (type === 'enter') duration = 0.11;
    else if (type === 'backspace') duration = 0.09;
    else if (type === 'tab') duration = 0.08;
    else if (type === 'delete') duration = 0.08;

    const numSamples = Math.floor(sampleRate * duration);
    const samples = new Float32Array(numSamples);

    // Base pitch & characteristics per pack
    let baseFreq = 1200;
    let noiseMix = 0.6;
    let thockFactor = 1.0;

    if (style === 'mechanical') {
        baseFreq = 1400 + variation * 120;
        noiseMix = 0.5;
        thockFactor = 1.0;
    } else if (style === 'thock') {
        baseFreq = 320 + variation * 40;
        noiseMix = 0.3;
        thockFactor = 2.5;
    } else if (style === 'typewriter') {
        baseFreq = 2200 + variation * 200;
        noiseMix = 0.7;
        thockFactor = 0.6;
    }

    if (type === 'space') {
        baseFreq *= 0.6;
        noiseMix += 0.15;
    } else if (type === 'enter') {
        baseFreq *= 0.75;
    } else if (type === 'backspace') {
        baseFreq *= 1.1;
    } else if (type === 'tab') {
        baseFreq *= 1.25;
    } else if (type === 'delete') {
        baseFreq *= 0.95;
    }

    for (let i = 0; i < numSamples; i++) {
        const t = i / sampleRate;

        // Fast attack, exponential decay envelope
        const env = Math.exp(-t * (40 / thockFactor));

        // Initial high-frequency transient (the sharp keycap contact)
        const transientEnv = Math.exp(-t * 250);
        const transient = (Math.random() * 2 - 1) * transientEnv * 0.8;

        // Tonal switch tactile click / spring resonance
        const tone1 = Math.sin(2 * Math.PI * baseFreq * t);
        const tone2 = Math.sin(2 * Math.PI * (baseFreq * 1.5) * t);
        const subTone = Math.sin(2 * Math.PI * (baseFreq * 0.4) * t) * (style === 'thock' ? 1.5 : 0.3);

        // Filtered noise body
        const whiteNoise = Math.random() * 2 - 1;
        const noise = whiteNoise * noiseMix;

        // Composite sound sample
        let sample = (transient * 0.5) + (tone1 * 0.3 + tone2 * 0.2 + subTone * 0.3) * (1 - noiseMix) + (noise * 0.4);
        sample *= env;

        // Secondary bottom-out click for realistic dual-stage switch feel
        const bottomOutDelay = 0.018; // 18ms after initial stroke
        if (t > bottomOutDelay) {
            const t2 = t - bottomOutDelay;
            const env2 = Math.exp(-t2 * (60 / thockFactor));
            const toneBottom = Math.sin(2 * Math.PI * (baseFreq * 0.8) * t2);
            sample += toneBottom * env2 * 0.4;
        }

        samples[i] = sample;
    }

    return createWavBuffer(samples, sampleRate);
}

const packs = ['mechanical', 'thock', 'typewriter'];
const keys = [
    { name: 'click1.wav', type: 'click', var: 0 },
    { name: 'click2.wav', type: 'click', var: 1 },
    { name: 'click3.wav', type: 'click', var: 2 },
    { name: 'click4.wav', type: 'click', var: 3 },
    { name: 'space.wav', type: 'space', var: 0 },
    { name: 'enter.wav', type: 'enter', var: 0 },
    { name: 'backspace.wav', type: 'backspace', var: 0 },
    { name: 'tab.wav', type: 'tab', var: 0 },
    { name: 'delete.wav', type: 'delete', var: 0 }
];

packs.forEach(pack => {
    const dir = path.join(__dirname, '..', 'sounds', pack);
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
    keys.forEach(k => {
        const filePath = path.join(dir, k.name);
        const wavData = synthesizeSound(pack, k.type, k.var);
        fs.writeFileSync(filePath, wavData);
        console.log(`Generated: ${filePath} (${wavData.length} bytes)`);
    });
});

console.log('Audio synthesis complete.');
