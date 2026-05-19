'use client';

import { useEffect, useState } from 'react';
import { TYPES, type Card as CardData } from '@/lib/cardTypes';
import { useLang } from '@/lib/LanguageContext';
import { getCardMeta } from '@/lib/i18n';
import type { PublicState } from '@/lib/gameEngine';
import styles from '@/app/game/game.module.css';

interface Props {
  state: PublicState;
  myHand: CardData[];
  myPlayerId: string;
  onNope: () => void;
}

const NOPE_WINDOW_MS = 2500;

export default function NopeBanner({ state, myHand, myPlayerId, onNope }: Props) {
  const [pct, setPct] = useState(100);
  const { lang, tr } = useLang();
  const p = state.pending;

  useEffect(() => {
    if (!p) return;
    const tick = () => {
      const remaining = Math.max(0, p.expiresAt - Date.now());
      setPct(Math.max(0, Math.min(100, (remaining / NOPE_WINDOW_MS) * 100)));
    };
    tick();
    const id = setInterval(tick, 80);
    return () => clearInterval(id);
  }, [p]);

  if (!p) return null;
  const actor = state.players.find(x => x.id === p.actorId);
  const cardType = p.payload?.cards?.[0]?.type;
  const cardLabel = cardType ? getCardMeta(cardType, lang)?.label ?? cardType : '?';
  const noped = p.nopeChain.length;
  const myHasNope = myHand.some(c => c.type === TYPES.NOPE);
  const canNope = myHasNope && p.actorId !== myPlayerId;

  return (
    <div className={styles.nopeBanner}>
      <div>
        {tr.played(actor?.name ?? '?', cardLabel)}
        {noped > 0 && ` · ${tr.nopeChain(noped)}`}
      </div>
      <div className={styles.nopeProgress}>
        <div className={styles.nopeBar} style={{ width: `${pct}%` }} />
      </div>
      {canNope && <button onClick={onNope}>{tr.nope}</button>}
    </div>
  );
}
