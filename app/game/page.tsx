'use client';

import { Suspense, useEffect, useMemo, useRef, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { useSocket, emitAck } from '@/lib/useSocket';
import { TYPES, type Card as CardData } from '@/lib/cardTypes';
import type { PublicState } from '@/lib/gameEngine';
import Card from '@/components/Card';
import Hand from '@/components/Hand';
import Opponents from '@/components/Opponents';
import NopeBanner from '@/components/NopeBanner';
import PromptModal from '@/components/PromptModal';
import PickTarget from '@/components/PickTarget';
import GameOver from '@/components/GameOver';
import JuiceLayer from '@/components/JuiceLayer';
import SoundToggle from '@/components/SoundToggle';
import { onStateChange as juiceOnStateChange } from '@/lib/juice';
import { sfx } from '@/lib/sfx';
import styles from './game.module.css';

export default function GamePage() {
  return (
    <Suspense fallback={<div style={{ padding: 40, textAlign: 'center' }}>Loading…</div>}>
      <GameInner />
    </Suspense>
  );
}

function GameInner() {
  const { socket } = useSocket();
  const router = useRouter();
  const params = useSearchParams();
  const myRoomCode = params.get('room') || '';
  const myPlayerId = params.get('pid') || '';

  const [state, setState] = useState<PublicState | null>(null);
  const [hand, setHand] = useState<CardData[]>([]);
  const [selectedIds, setSelectedIds] = useState<Set<string>>(new Set());
  const [toast, setToast] = useState<string | null>(null);
  const [favorPick, setFavorPick] = useState<string[] | null>(null); // pending Favor card IDs awaiting target
  const [turnFlash, setTurnFlash] = useState(false);
  const prevTurnRef = useRef<string | null>(null);

  // Resume / join the room on mount.
  useEffect(() => {
    if (!myRoomCode || !myPlayerId) {
      router.push('/');
      return;
    }
    emitAck<{ ok: boolean; error?: string }>(socket, 'lobby:resume', {
      code: myRoomCode, playerId: myPlayerId,
    }).then((res) => {
      if (!res?.ok) {
        alert(res?.error || 'Could not rejoin room.');
        router.push('/');
      }
    });
  }, [socket, myRoomCode, myPlayerId, router]);

  // Wire events.
  const prevStateRef = useRef<PublicState | null>(null);
  useEffect(() => {
    const onState = (s: PublicState) => {
      // Fire juice (sound + particles + floating text) before storing the new
      // state. The previous state is held in a ref so this comparison is
      // deterministic regardless of React's render timing.
      juiceOnStateChange(prevStateRef.current, s);
      prevStateRef.current = s;
      setState(s);
      setSelectedIds(prev => {
        // No-op; hand-id pruning happens below when hand arrives.
        return prev;
      });
    };
    const onHand = ({ hand: h }: { hand: CardData[] }) => {
      setHand(h);
      setSelectedIds(prev => {
        const ids = new Set(h.map(c => c.id));
        const next = new Set<string>();
        for (const id of prev) if (ids.has(id)) next.add(id);
        return next;
      });
    };
    const onErr = ({ message }: { message: string }) => {
      setToast(message);
      setTimeout(() => setToast(null), 2500);
    };

    socket.on('game:state', onState);
    socket.on('game:hand', onHand);
    socket.on('error:msg', onErr);
    return () => {
      socket.off('game:state', onState);
      socket.off('game:hand', onHand);
      socket.off('error:msg', onErr);
    };
  }, [socket]);

  const isMyTurn = state?.currentPlayerId === myPlayerId;
  const canAct = isMyTurn && state?.status === 'playing' && !state.pending && !state.prompt;

  // Flash a "Your turn!" banner when turn transitions to me.
  useEffect(() => {
    if (!state) return;
    const cur = state.currentPlayerId;
    const prev = prevTurnRef.current;
    prevTurnRef.current = cur;
    if (prev && prev !== cur && cur === myPlayerId && state.status === 'playing') {
      setTurnFlash(true);
      const id = setTimeout(() => setTurnFlash(false), 1400);
      return () => clearTimeout(id);
    }
  }, [state?.currentPlayerId, state?.status, myPlayerId, state]);

  function toggleCard(id: string) {
    sfx.play('tap');
    if (typeof navigator !== 'undefined' && 'vibrate' in navigator) navigator.vibrate?.(8);
    setSelectedIds(prev => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id); else next.add(id);
      return next;
    });
  }

  async function playSelected() {
    if (selectedIds.size === 0) return;
    const ids = [...selectedIds];
    const cards = ids.map(id => hand.find(c => c.id === id)).filter(Boolean) as CardData[];
    if (cards.length === 0) return;

    // Favor needs a target chosen *before* sending.
    if (cards.length === 1 && cards[0].type === TYPES.FAVOR) {
      setFavorPick(ids);
      return;
    }
    await send(ids, {});
  }

  async function send(cardIds: string[], payload: Record<string, unknown>) {
    const res = await emitAck<{ ok: boolean; error?: string }>(socket, 'game:play', { cardIds, payload });
    if (!res?.ok) {
      setToast(res?.error || 'Cannot play.');
      setTimeout(() => setToast(null), 2500);
    } else {
      setSelectedIds(new Set());
    }
  }

  async function onLeave() {
    if (!confirm('Leave the game?')) return;
    await emitAck(socket, 'lobby:leave', {});
    sessionStorage.removeItem('ek-session');
    router.push('/');
  }

  function onNope() { socket.emit('game:nope', {}); }
  function onDraw() { socket.emit('game:draw', {}); }
  function onPrompt(response: Record<string, unknown>) {
    socket.emit('game:prompt', { response });
  }

  const turnText = useMemo(() => {
    if (!state) return '…';
    if (state.status === 'ended') return 'Game over';
    const cur = state.players.find(p => p.id === state.currentPlayerId);
    const dir = state.direction === 1 ? '→' : '←';
    return `Turn: ${cur?.name ?? '?'}${isMyTurn ? ' (you)' : ''} · ${state.remainingTurns} turn(s) ${dir}`;
  }, [state, isMyTurn]);

  return (
    <main className={styles.page}>
      <header className={styles.topbar}>
        <div>Room <span>{myRoomCode}</span></div>
        <div className={styles.turnInfo}>{turnText}</div>
        <div className={styles.topbarRight}>
          <SoundToggle />
          <button className={styles.leaveBtn} onClick={onLeave}>Leave</button>
        </div>
      </header>

      {state && <Opponents state={state} myPlayerId={myPlayerId} />}

      <section className={styles.table}>
        <div className={styles.pile}>
          <div className={styles.cardBack}>
            <div className={styles.pileLabel}>Draw</div>
            <div className={styles.pileCount}>{state?.deckCount ?? 0}</div>
          </div>
        </div>
        <div className={styles.pile}>
          {state?.topDiscard ? (
            <div key={state.topDiscard.id} className={styles.discardWrap}>
              <Card card={state.topDiscard} />
            </div>
          ) : (
            <div className={`${styles.cardSlot} ${styles.empty}`}>Discard</div>
          )}
        </div>
      </section>

      {state && <NopeBanner state={state} myHand={hand} myPlayerId={myPlayerId} onNope={onNope} />}

      <section className={styles.log}>
        {(state?.log || []).slice(-30).map((e, i, arr) => (
          <div key={e.ts + ':' + i}
            className={`${styles.logEntry} ${i === arr.length - 1 ? styles.logEntryFresh : ''}`}>
            {e.text}
          </div>
        ))}
      </section>

      <section className={`${styles.handWrap} ${isMyTurn && state?.status === 'playing' ? styles.myTurn : ''}`}>
        <Hand hand={hand} selectedIds={selectedIds} onToggle={toggleCard} />
        <div className={styles.actions}>
          <button onClick={playSelected} disabled={!canAct || selectedIds.size === 0}>Play selected</button>
          <button className={styles.drawBtn} onClick={onDraw} disabled={!canAct}>Draw (end turn)</button>
        </div>
      </section>

      {state && <PromptModal state={state} myPlayerId={myPlayerId} onRespond={onPrompt} />}
      {state && <GameOver state={state} />}

      {favorPick && state && (
        <PickTarget
          title="Pick a target for Favor"
          state={state}
          myPlayerId={myPlayerId}
          onPick={(target) => { send(favorPick, { target }); setFavorPick(null); }}
          onCancel={() => setFavorPick(null)}
        />
      )}

      {toast && <div className={styles.toast}>{toast}</div>}
      {turnFlash && <div className={styles.turnFlash}>Your turn!</div>}

      <JuiceLayer />
    </main>
  );
}
