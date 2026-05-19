// Synthesized sound effects using Web Audio API. Zero dependencies, zero
// audio assets. AudioContext is lazy-created on first play() call so we
// satisfy browser autoplay rules.

'use client';

export type SFXKind =
  | 'tap' | 'swoosh' | 'draw' | 'shuffle' | 'nope' | 'boom' | 'defuse'
  | 'snatch' | 'sparkle' | 'reverse' | 'tick' | 'fanfare' | 'fail';

const STORE_KEY = 'ek:sfx';

interface Prefs { muted: boolean; volume: number; }

let prefs: Prefs = { muted: false, volume: 0.6 };
let ctx: AudioContext | null = null;
let master: GainNode | null = null;

function loadPrefs() {
  if (typeof window === 'undefined') return;
  try {
    const raw = localStorage.getItem(STORE_KEY);
    if (raw) {
      const p = JSON.parse(raw);
      if (typeof p.muted === 'boolean') prefs.muted = p.muted;
      if (typeof p.volume === 'number') prefs.volume = Math.max(0, Math.min(1, p.volume));
    }
  } catch {}
}
function savePrefs() {
  if (typeof window === 'undefined') return;
  try { localStorage.setItem(STORE_KEY, JSON.stringify(prefs)); } catch {}
}
loadPrefs();

function audio(): AudioContext | null {
  if (typeof window === 'undefined') return null;
  if (!ctx) {
    const Ctor = (window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext);
    if (!Ctor) return null;
    ctx = new Ctor();
    master = ctx.createGain();
    master.gain.value = prefs.volume;
    master.connect(ctx.destination);
  }
  if (ctx.state === 'suspended') ctx.resume().catch(() => {});
  return ctx;
}

// ---- primitives ----

function tone(c: AudioContext, freq: number, dur: number, delay = 0, type: OscillatorType = 'sine', gain = 0.3) {
  const t0 = c.currentTime + delay;
  const osc = c.createOscillator();
  osc.type = type;
  osc.frequency.setValueAtTime(freq, t0);
  const g = c.createGain();
  g.gain.setValueAtTime(0.0001, t0);
  g.gain.exponentialRampToValueAtTime(gain, t0 + 0.01);
  g.gain.exponentialRampToValueAtTime(0.0001, t0 + dur);
  osc.connect(g).connect(master!);
  osc.start(t0);
  osc.stop(t0 + dur + 0.02);
}

function noiseBurst(c: AudioContext, dur: number, lowpass: number, gain: number, delay = 0) {
  const t0 = c.currentTime + delay;
  const len = Math.max(1, Math.floor(c.sampleRate * dur));
  const buf = c.createBuffer(1, len, c.sampleRate);
  const data = buf.getChannelData(0);
  for (let i = 0; i < len; i++) data[i] = (Math.random() * 2 - 1);
  const src = c.createBufferSource();
  src.buffer = buf;
  const filt = c.createBiquadFilter();
  filt.type = 'lowpass';
  filt.frequency.value = lowpass;
  const g = c.createGain();
  g.gain.setValueAtTime(gain, t0);
  g.gain.exponentialRampToValueAtTime(0.0001, t0 + dur);
  src.connect(filt).connect(g).connect(master!);
  src.start(t0);
  src.stop(t0 + dur + 0.02);
}

function sweep(c: AudioContext, from: number, to: number, dur: number, type: OscillatorType = 'sine', gain = 0.3) {
  const t0 = c.currentTime;
  const osc = c.createOscillator();
  osc.type = type;
  osc.frequency.setValueAtTime(from, t0);
  osc.frequency.exponentialRampToValueAtTime(to, t0 + dur);
  const g = c.createGain();
  g.gain.setValueAtTime(0.0001, t0);
  g.gain.exponentialRampToValueAtTime(gain, t0 + 0.01);
  g.gain.exponentialRampToValueAtTime(0.0001, t0 + dur);
  osc.connect(g).connect(master!);
  osc.start(t0);
  osc.stop(t0 + dur + 0.02);
}

// ---- sounds ----

const recipes: Record<SFXKind, (c: AudioContext) => void> = {
  tap: (c) => { tone(c, 1200, 0.05, 0, 'triangle', 0.15); },
  swoosh: (c) => { noiseBurst(c, 0.18, 2000, 0.18); sweep(c, 600, 200, 0.18, 'triangle', 0.12); },
  draw: (c) => { noiseBurst(c, 0.08, 4000, 0.15); tone(c, 880, 0.06, 0.02, 'triangle', 0.18); },
  shuffle: (c) => {
    // Three quick filtered noise riffles.
    for (let i = 0; i < 3; i++) noiseBurst(c, 0.12, 3000 - i * 600, 0.18, i * 0.09);
  },
  nope: (c) => {
    // Rubber-stamp thud + clack.
    tone(c, 220, 0.12, 0, 'triangle', 0.4);
    noiseBurst(c, 0.06, 2500, 0.25, 0.04);
    tone(c, 110, 0.18, 0.02, 'sine', 0.3);
  },
  boom: (c) => {
    // Bass thud
    const t0 = c.currentTime;
    const osc = c.createOscillator();
    osc.type = 'sine';
    osc.frequency.setValueAtTime(160, t0);
    osc.frequency.exponentialRampToValueAtTime(35, t0 + 0.45);
    const g = c.createGain();
    g.gain.setValueAtTime(0.0001, t0);
    g.gain.exponentialRampToValueAtTime(0.7, t0 + 0.02);
    g.gain.exponentialRampToValueAtTime(0.0001, t0 + 0.55);
    osc.connect(g).connect(master!);
    osc.start(t0); osc.stop(t0 + 0.6);
    // Noise crack
    noiseBurst(c, 0.45, 1200, 0.4);
    noiseBurst(c, 0.18, 4000, 0.25, 0.01);
  },
  defuse: (c) => {
    // C5-E5-G5 ascending arpeggio
    [523.25, 659.25, 783.99].forEach((f, i) => tone(c, f, 0.18, i * 0.07, 'sine', 0.28));
    tone(c, 1046.5, 0.3, 0.21, 'sine', 0.2);
  },
  snatch: (c) => {
    sweep(c, 1800, 600, 0.18, 'sawtooth', 0.18);
    noiseBurst(c, 0.05, 6000, 0.12, 0.18);
  },
  sparkle: (c) => {
    // Three random high pings
    const pitches = [1400, 1800, 2200];
    pitches.forEach((p, i) => tone(c, p + Math.random() * 300, 0.12, i * 0.05, 'sine', 0.18));
  },
  reverse: (c) => {
    sweep(c, 200, 900, 0.25, 'sawtooth', 0.18);
    sweep(c, 900, 200, 0.25, 'sawtooth', 0.18);
  },
  tick: (c) => { tone(c, 1600, 0.03, 0, 'square', 0.1); },
  fanfare: (c) => {
    // I-iii-V-VIII arpeggio
    const notes = [261.63, 329.63, 392.0, 523.25, 659.25, 783.99];
    notes.forEach((f, i) => tone(c, f, 0.25, i * 0.08, 'triangle', 0.25));
    tone(c, 1046.5, 0.6, 0.5, 'sine', 0.22);
  },
  fail: (c) => {
    sweep(c, 400, 180, 0.3, 'sawtooth', 0.22);
    tone(c, 110, 0.25, 0.05, 'triangle', 0.18);
  },
};

// ---- public API ----

export function play(kind: SFXKind) {
  if (prefs.muted) return;
  const c = audio();
  if (!c || !master) return;
  master.gain.value = prefs.volume;
  try { recipes[kind](c); } catch {}
}

export function isMuted(): boolean { return prefs.muted; }
export function setMuted(m: boolean) { prefs.muted = m; savePrefs(); }
export function getVolume(): number { return prefs.volume; }
export function setVolume(v: number) {
  prefs.volume = Math.max(0, Math.min(1, v));
  if (master) master.gain.value = prefs.volume;
  savePrefs();
}

// Subscribe to mute changes (used by SoundToggle to re-render).
type Listener = () => void;
const listeners = new Set<Listener>();
export function subscribe(fn: Listener): () => void {
  listeners.add(fn);
  return () => { listeners.delete(fn); };
}
function notify() { listeners.forEach(fn => fn()); }
// Patch setMuted/setVolume to notify.
const _setMuted = setMuted;
export const sfx = {
  play,
  isMuted,
  setMuted: (m: boolean) => { _setMuted(m); notify(); },
  getVolume,
  setVolume: (v: number) => { setVolume(v); notify(); },
  subscribe,
};
