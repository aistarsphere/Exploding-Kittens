// Lightweight canvas particle engine. No dependencies. Auto-stops the rAF
// loop when no particles remain so it doesn't burn battery on idle.

'use client';

export type BurstKind = 'explosion' | 'confetti' | 'sparkle' | 'smoke' | 'flash';

interface Particle {
  kind: BurstKind;
  x: number;
  y: number;
  vx: number;
  vy: number;
  life: number;     // seconds remaining
  maxLife: number;
  size: number;
  rot: number;
  vrot: number;
  color: string;
  gravity: number;
  alpha: number;
}

let canvas: HTMLCanvasElement | null = null;
let cctx: CanvasRenderingContext2D | null = null;
let dpr = 1;
const particles: Particle[] = [];
let rafId = 0;
let lastT = 0;

function resize() {
  if (!canvas) return;
  dpr = Math.max(1, Math.min(2, window.devicePixelRatio || 1));
  canvas.width = window.innerWidth * dpr;
  canvas.height = window.innerHeight * dpr;
  canvas.style.width = window.innerWidth + 'px';
  canvas.style.height = window.innerHeight + 'px';
}

export function startEngine(c: HTMLCanvasElement) {
  canvas = c;
  cctx = c.getContext('2d');
  resize();
  window.addEventListener('resize', resize);
}
export function stopEngine() {
  if (rafId) cancelAnimationFrame(rafId);
  rafId = 0;
  particles.length = 0;
  window.removeEventListener('resize', resize);
}

function ensureLoop() {
  if (rafId || !cctx) return;
  lastT = performance.now();
  const tick = (t: number) => {
    if (!cctx || !canvas) { rafId = 0; return; }
    const dt = Math.min(0.05, (t - lastT) / 1000);
    lastT = t;
    cctx.clearRect(0, 0, canvas.width, canvas.height);
    for (let i = particles.length - 1; i >= 0; i--) {
      const p = particles[i];
      p.life -= dt;
      if (p.life <= 0) { particles.splice(i, 1); continue; }
      p.vy += p.gravity * dt;
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.rot += p.vrot * dt;
      const lifeFrac = p.life / p.maxLife;
      const alpha = Math.max(0, Math.min(1, p.alpha * lifeFrac));
      drawParticle(cctx, p, alpha);
    }
    if (particles.length === 0) { rafId = 0; return; }
    rafId = requestAnimationFrame(tick);
  };
  rafId = requestAnimationFrame(tick);
}

function drawParticle(g: CanvasRenderingContext2D, p: Particle, alpha: number) {
  g.save();
  g.globalAlpha = alpha;
  g.translate(p.x * dpr, p.y * dpr);
  g.rotate(p.rot);
  const s = p.size * dpr;
  switch (p.kind) {
    case 'explosion': {
      g.fillStyle = p.color;
      g.beginPath();
      g.arc(0, 0, s, 0, Math.PI * 2);
      g.fill();
      break;
    }
    case 'confetti': {
      g.fillStyle = p.color;
      g.fillRect(-s, -s * 0.5, s * 2, s);
      break;
    }
    case 'sparkle': {
      g.fillStyle = p.color;
      // 4-point star
      g.beginPath();
      for (let i = 0; i < 8; i++) {
        const ang = (i / 8) * Math.PI * 2;
        const r = i % 2 === 0 ? s : s * 0.4;
        const x = Math.cos(ang) * r;
        const y = Math.sin(ang) * r;
        if (i === 0) g.moveTo(x, y); else g.lineTo(x, y);
      }
      g.closePath();
      g.fill();
      break;
    }
    case 'smoke': {
      g.fillStyle = p.color;
      g.beginPath();
      g.arc(0, 0, s, 0, Math.PI * 2);
      g.fill();
      break;
    }
    case 'flash': {
      // Flash particles are full-screen quads; size encodes radius.
      g.fillStyle = p.color;
      g.fillRect(-canvas!.width, -canvas!.height, canvas!.width * 2, canvas!.height * 2);
      break;
    }
  }
  g.restore();
}

function rand(min: number, max: number) { return min + Math.random() * (max - min); }

export interface BurstOpts {
  count?: number;
  spread?: number;     // initial speed multiplier
}

export function burst(kind: BurstKind, x: number, y: number, opts: BurstOpts = {}) {
  switch (kind) {
    case 'explosion': {
      const count = opts.count ?? 36;
      for (let i = 0; i < count; i++) {
        const ang = rand(0, Math.PI * 2);
        const speed = rand(140, 380) * (opts.spread ?? 1);
        const colors = ['#ff7a18', '#ffb142', '#ff3b30', '#ffd166', '#e74c3c'];
        particles.push({
          kind, x, y,
          vx: Math.cos(ang) * speed,
          vy: Math.sin(ang) * speed,
          life: rand(0.6, 1.1),
          maxLife: 1.1,
          size: rand(2.5, 6),
          rot: 0, vrot: 0,
          color: colors[Math.floor(Math.random() * colors.length)],
          gravity: 420,
          alpha: 1,
        });
      }
      // central smoke poof
      for (let i = 0; i < 12; i++) {
        const ang = rand(0, Math.PI * 2);
        const speed = rand(20, 90);
        particles.push({
          kind: 'smoke', x, y,
          vx: Math.cos(ang) * speed,
          vy: Math.sin(ang) * speed - 50,
          life: rand(0.8, 1.6),
          maxLife: 1.6,
          size: rand(14, 28),
          rot: 0, vrot: 0,
          color: 'rgba(60,40,30,0.55)',
          gravity: -30,
          alpha: 0.8,
        });
      }
      break;
    }
    case 'confetti': {
      const count = opts.count ?? 80;
      const colors = ['#f1c40f', '#e74c3c', '#27ae60', '#3498db', '#9b59b6', '#fff', '#e67e22'];
      const w = window.innerWidth;
      for (let i = 0; i < count; i++) {
        particles.push({
          kind, x: rand(0, w), y: rand(-40, -160),
          vx: rand(-50, 50),
          vy: rand(120, 260),
          life: rand(2.5, 4),
          maxLife: 4,
          size: rand(4, 7),
          rot: rand(0, Math.PI * 2),
          vrot: rand(-6, 6),
          color: colors[Math.floor(Math.random() * colors.length)],
          gravity: 240,
          alpha: 1,
        });
      }
      break;
    }
    case 'sparkle': {
      const count = opts.count ?? 14;
      const colors = ['#f1c40f', '#ffe066', '#fff8c4', '#ffd166'];
      for (let i = 0; i < count; i++) {
        const ang = rand(0, Math.PI * 2);
        const speed = rand(80, 220);
        particles.push({
          kind, x, y,
          vx: Math.cos(ang) * speed,
          vy: Math.sin(ang) * speed,
          life: rand(0.6, 1.0),
          maxLife: 1.0,
          size: rand(4, 8),
          rot: rand(0, Math.PI * 2),
          vrot: rand(-8, 8),
          color: colors[Math.floor(Math.random() * colors.length)],
          gravity: 60,
          alpha: 1,
        });
      }
      break;
    }
    case 'smoke': {
      const count = opts.count ?? 8;
      for (let i = 0; i < count; i++) {
        const ang = rand(-Math.PI, 0);
        const speed = rand(20, 70);
        particles.push({
          kind, x, y,
          vx: Math.cos(ang) * speed,
          vy: Math.sin(ang) * speed,
          life: rand(0.6, 1.0),
          maxLife: 1.0,
          size: rand(10, 18),
          rot: 0, vrot: 0,
          color: 'rgba(220,200,170,0.4)',
          gravity: -20,
          alpha: 0.7,
        });
      }
      break;
    }
    case 'flash': {
      // Single particle that paints a full-screen colored quad fading out.
      particles.push({
        kind, x: 0, y: 0,
        vx: 0, vy: 0,
        life: 0.35, maxLife: 0.35,
        size: 0, rot: 0, vrot: 0,
        color: opts.spread === 2 ? 'rgba(120,120,120,0.5)'
             : opts.spread === 3 ? 'rgba(241,196,15,0.45)'
             : 'rgba(231,76,60,0.5)',
        gravity: 0,
        alpha: 1,
      });
      break;
    }
  }
  ensureLoop();
}

// Helper: flash with a named color
export function flash(color: 'red' | 'gray' | 'gold') {
  const map = { red: 1, gray: 2, gold: 3 } as const;
  burst('flash', 0, 0, { spread: map[color] });
}
