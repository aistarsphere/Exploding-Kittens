'use client';

import type { PublicState } from '@/lib/gameEngine';
import styles from '@/app/game/game.module.css';

interface Props {
  title: string;
  state: PublicState;
  myPlayerId: string;
  onPick: (playerId: string) => void;
  onCancel: () => void;
}

// Used when the local player needs to pick a target *before* the action is sent
// (e.g. choosing the Favor target).
export default function PickTarget({ title, state, myPlayerId, onPick, onCancel }: Props) {
  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modal}>
        <h3>Pick a player</h3>
        <p>{title}</p>
        <div className={styles.playerRow}>
          {state.players
            .filter(p => p.alive && p.id !== myPlayerId)
            .map(p => (
              <button key={p.id} onClick={() => onPick(p.id)}>{p.name}</button>
            ))}
        </div>
        <div className={styles.modalActions}>
          <button className={styles.secondary} onClick={onCancel}>Cancel</button>
        </div>
      </div>
    </div>
  );
}
