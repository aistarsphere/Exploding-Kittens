'use client';

import { useState } from 'react';
import Card from './Card';
import { META, TYPES, type Card as CardData, type CardType } from '@/lib/cardTypes';
import type { PublicState, Prompt } from '@/lib/gameEngine';
import styles from '@/app/game/game.module.css';

interface Props {
  state: PublicState;
  myPlayerId: string;
  onRespond: (response: Record<string, unknown>) => void;
}

export default function PromptModal({ state, myPlayerId, onRespond }: Props) {
  const prompt = state.prompt;
  if (!prompt) return null;

  // If the prompt is for someone else, show a passive notice.
  if (prompt.forPlayerId !== myPlayerId) {
    const target = state.players.find(p => p.id === prompt.forPlayerId);
    return (
      <Overlay>
        <Modal title={`Waiting for ${target?.name ?? 'player'}`}>
          <p>They are responding to {prompt.type}…</p>
        </Modal>
      </Overlay>
    );
  }

  switch (prompt.type) {
    case 'see-future':       return <SeeFuture prompt={prompt} onRespond={onRespond} />;
    case 'alter-future':     return <AlterFuture prompt={prompt} onRespond={onRespond} />;
    case 'favor-give':       return <FavorGive prompt={prompt} state={state} onRespond={onRespond} />;
    case 'cat-pair-target':  return <PickPlayer prompt={prompt} state={state} title="Steal a random card — pick a target" onRespond={onRespond} />;
    case 'cat-trio-target':  return <PickPlayer prompt={prompt} state={state} title="Name a card to steal — pick a target" onRespond={onRespond} />;
    case 'cat-trio-name':    return <CatTrioName onRespond={onRespond} />;
    case 'defuse-reinsert':  return <DefuseReinsert prompt={prompt} onRespond={onRespond} />;
    default: return null;
  }
}

function Overlay({ children }: { children: React.ReactNode }) {
  return <div className={styles.modalOverlay}>{children}</div>;
}
function Modal({ title, children, actions }: { title: string; children: React.ReactNode; actions?: React.ReactNode }) {
  return (
    <div className={styles.modal}>
      <h3>{title}</h3>
      {children}
      {actions && <div className={styles.modalActions}>{actions}</div>}
    </div>
  );
}

function SeeFuture({ prompt, onRespond }: { prompt: Prompt; onRespond: (r: Record<string, unknown>) => void }) {
  const cards = (prompt.options.cards as CardData[]) || [];
  return (
    <Overlay>
      <Modal title="See the Future"
        actions={<button onClick={() => onRespond({})}>OK</button>}>
        <p>Top 3 cards (top first):</p>
        <div className={styles.cardRow}>
          {cards.map(c => <Card key={c.id} card={c} />)}
        </div>
      </Modal>
    </Overlay>
  );
}

function AlterFuture({ prompt, onRespond }: { prompt: Prompt; onRespond: (r: Record<string, unknown>) => void }) {
  const initial = (prompt.options.cards as CardData[]) || [];
  const [remaining, setRemaining] = useState<CardData[]>(initial);
  const [order, setOrder] = useState<CardData[]>([]);

  function pick(c: CardData) {
    setRemaining(r => r.filter(x => x.id !== c.id));
    setOrder(o => [...o, c]);
  }
  function reset() {
    setRemaining(initial);
    setOrder([]);
  }
  function confirm() {
    if (order.length !== initial.length) return;
    onRespond({ order: order.map(c => c.id) });
  }

  return (
    <Overlay>
      <Modal title="Alter the Future"
        actions={
          <>
            <button className={styles.secondary} onClick={reset}>Reset</button>
            <button onClick={confirm} disabled={order.length !== initial.length}>Confirm</button>
          </>
        }>
        <p>Click cards in the order you want them at top:</p>
        <div className={styles.cardRow}>
          {remaining.map(c => <Card key={c.id} card={c} onClick={() => pick(c)} />)}
        </div>
        <p><i style={{ opacity: 0.7 }}>New order (top → bottom):</i></p>
        <div className={styles.cardRow}>
          {order.map(c => <Card key={c.id} card={c} />)}
        </div>
      </Modal>
    </Overlay>
  );
}

function FavorGive({ prompt, state, onRespond }: { prompt: Prompt; state: PublicState; onRespond: (r: Record<string, unknown>) => void }) {
  const cards = (prompt.options.cards as CardData[]) || [];
  const target = state.players.find(p => p.id === (prompt.options.toPlayerId as string));
  return (
    <Overlay>
      <Modal title="Favor">
        <p>Give one card to <b>{target?.name ?? '?'}</b>:</p>
        <div className={styles.cardRow}>
          {cards.map(c => (
            <Card key={c.id} card={c} onClick={() => onRespond({ cardId: c.id })} />
          ))}
        </div>
      </Modal>
    </Overlay>
  );
}

function PickPlayer({ prompt, state, title, onRespond }: {
  prompt: Prompt; state: PublicState; title: string; onRespond: (r: Record<string, unknown>) => void;
}) {
  const candidates = (prompt.options.candidates as string[]) || [];
  return (
    <Overlay>
      <Modal title="Pick a target">
        <p>{title}</p>
        <div className={styles.playerRow}>
          {candidates.map(pid => {
            const p = state.players.find(x => x.id === pid);
            return (
              <button key={pid} onClick={() => onRespond({ targetId: pid })}>
                {p?.name ?? pid}
              </button>
            );
          })}
        </div>
      </Modal>
    </Overlay>
  );
}

function CatTrioName({ onRespond }: { onRespond: (r: Record<string, unknown>) => void }) {
  const types: CardType[] = [
    TYPES.ATTACK, TYPES.SKIP, TYPES.FAVOR, TYPES.SHUFFLE,
    TYPES.SEE_THE_FUTURE, TYPES.ALTER_THE_FUTURE,
    TYPES.DRAW_FROM_BOTTOM, TYPES.REVERSE,
    TYPES.DOUBLE_SLAP, TYPES.TRIPLE_SLAP,
    TYPES.NOPE, TYPES.DEFUSE,
    TYPES.CAT_TACO, TYPES.CAT_BEARD, TYPES.CAT_RAINBOW,
    TYPES.CAT_POTATO, TYPES.CAT_MELON, TYPES.CAT_FERAL,
  ];
  return (
    <Overlay>
      <Modal title="Name a card">
        <p>Name a card to take from the target:</p>
        <div className={styles.playerRow}>
          {types.map(t => (
            <button key={t} onClick={() => onRespond({ namedType: t })}>
              {META[t].label}
            </button>
          ))}
        </div>
      </Modal>
    </Overlay>
  );
}

function DefuseReinsert({ prompt, onRespond }: { prompt: Prompt; onRespond: (r: Record<string, unknown>) => void }) {
  const deckSize = (prompt.options.deckSize as number) ?? 0;
  const [pos, setPos] = useState(Math.floor(deckSize / 2));
  return (
    <Overlay>
      <Modal title="Defuse!"
        actions={<button onClick={() => onRespond({ position: pos })}>Reinsert</button>}>
        <p>Reinsert the Exploding Kitten:</p>
        <input type="range" min={0} max={deckSize} value={pos}
          onChange={e => setPos(parseInt(e.target.value, 10))} style={{ width: '100%' }} />
        <p>Position from top: <span>{pos}</span> / {deckSize}</p>
        <small>0 = next card drawn · {deckSize} = bottom of deck</small>
      </Modal>
    </Overlay>
  );
}
