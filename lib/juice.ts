// Diffs successive PublicState objects and fires SFX + particles + UI cues
// for the events the engine emits. Talks to JuiceLayer via an EventTarget bus.

'use client';

import { sfx } from './sfx';
import { burst, flash } from './particles';
import type { PublicState } from './gameEngine';

// ---- Event bus for visual cues that need React (floating text, screen shake) ----

export type JuiceEvent =
  | { type: 'floating-text'; text: string; color: string; x?: number; y?: number; big?: boolean }
  | { type: 'shake'; level: 'light' | 'medium' | 'heavy' };

const bus = typeof window !== 'undefined' ? new EventTarget() : null;

export function on(handler: (e: JuiceEvent) => void) {
  if (!bus) return () => {};
  const fn = (ev: Event) => handler((ev as CustomEvent<JuiceEvent>).detail);
  bus.addEventListener('juice', fn as EventListener);
  return () => bus.removeEventListener('juice', fn as EventListener);
}
function emit(e: JuiceEvent) {
  if (!bus) return;
  bus.dispatchEvent(new CustomEvent('juice', { detail: e }));
}

// ---- helpers ----

function reduceMotion(): boolean {
  if (typeof window === 'undefined' || !window.matchMedia) return false;
  return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

function vibrate(pattern: number | number[]) {
  if (typeof navigator !== 'undefined' && 'vibrate' in navigator) {
    try { navigator.vibrate(pattern); } catch {}
  }
}

function discardCenter(): { x: number; y: number } {
  if (typeof document === 'undefined') return { x: 0, y: 0 };
  // We look for the discard pile by the styled empty slot OR the rendered card.
  // The card.module.css class names are hashed, so use a known parent class.
  const piles = document.querySelectorAll<HTMLElement>('[class*="discardWrap"], [class*="cardSlot"]');
  const el = piles[piles.length - 1] || piles[0];
  if (!el) return { x: window.innerWidth / 2, y: window.innerHeight / 2 };
  const r = el.getBoundingClientRect();
  return { x: r.left + r.width / 2, y: r.top + r.height / 2 };
}

function center(): { x: number; y: number } {
  if (typeof window === 'undefined') return { x: 0, y: 0 };
  return { x: window.innerWidth / 2, y: window.innerHeight / 2 };
}

// ---- Public: call on every state update ----

export function onStateChange(prev: PublicState | null, next: PublicState) {
  const motion = !reduceMotion();
  const prevLogLen = prev?.log.length ?? 0;
  const newEntries = next.log.slice(prevLogLen).map(e => e.text);

  // -- Per-log-entry triggers --
  for (const text of newEntries) {
    if (/BOOM!/.test(text)) {
      sfx.play('boom');
      vibrate([60, 40, 80]);
      if (motion) {
        const p = discardCenter();
        burst('explosion', p.x, p.y);
        emit({ type: 'shake', level: 'heavy' });
        emit({ type: 'floating-text', text: 'BOOM!', color: '#ff3b30', big: true });
      }
      continue;
    }
    if (/defused it!/.test(text)) {
      sfx.play('defuse');
      vibrate([20, 30, 20]);
      if (motion) {
        const p = discardCenter();
        burst('sparkle', p.x, p.y, { count: 20 });
        flash('gold');
        emit({ type: 'floating-text', text: 'DEFUSED!', color: '#f1c40f' });
      }
      continue;
    }
    if (/played Nope\.?$/i.test(text)) {
      sfx.play('nope');
      vibrate(15);
      if (motion) {
        flash('red');
        emit({ type: 'shake', level: 'light' });
        emit({ type: 'floating-text', text: 'NOPE!', color: '#ffd166', big: true });
      }
      continue;
    }
    if (/Action was Noped/i.test(text)) {
      sfx.play('fail');
      if (motion) flash('gray');
      continue;
    }
    if (/stole a card from|took a .+ from/i.test(text)) {
      sfx.play('snatch');
      if (motion) {
        const p = discardCenter();
        burst('sparkle', p.x, p.y, { count: 12 });
        emit({ type: 'floating-text', text: 'STOLEN!', color: '#ff7a18' });
      }
      continue;
    }
    if (/Deck shuffled/i.test(text)) {
      sfx.play('shuffle');
      continue;
    }
    if (/Turn order reversed/i.test(text)) {
      sfx.play('reverse');
      if (motion) emit({ type: 'floating-text', text: 'REVERSE!', color: '#1abc9c' });
      continue;
    }
    if (/drew a card/i.test(text)) {
      // Only chirp; the topDiscard didn't change so no card-play sfx will fire.
      sfx.play('draw');
      continue;
    }
    // Cat pair/trio playing (engine logs "X played pair of TYPE" or "trio of TYPE")
    if (/played (pair|trio) of /i.test(text)) {
      // already covered by topDiscard change → swoosh; nothing extra
      continue;
    }
  }

  // -- topDiscard change → generic card-play sfx + smoke puff (if not already strong) --
  const prevTop = prev?.topDiscard?.id ?? null;
  const nextTop = next.topDiscard?.id ?? null;
  if (nextTop && nextTop !== prevTop) {
    // Skip if a boom/defuse/nope already played for this tick — those carry their own sounds.
    const noisyEntry = newEntries.some(t =>
      /BOOM!|defused it!|played Nope/i.test(t)
    );
    if (!noisyEntry) {
      sfx.play('swoosh');
      if (motion) {
        const p = discardCenter();
        burst('smoke', p.x, p.y, { count: 6 });
      }
    }
  }

  // -- Pending window opening (Nope window) --
  if (!prev?.pending && next.pending) {
    sfx.play('tick');
  }

  // -- Game over --
  if (prev?.status !== 'ended' && next.status === 'ended') {
    sfx.play('fanfare');
    vibrate([30, 60, 30, 60, 60]);
    if (motion) {
      burst('confetti', 0, 0);
      const winner = next.players.find(p => p.id === next.winnerId);
      emit({
        type: 'floating-text',
        text: winner ? `${winner.name} wins!` : 'Game Over',
        color: '#f1c40f',
        big: true,
      });
    }
  }
}
