'use client';

import styles from '@/app/game/game.module.css';
import type { PublicState } from '@/lib/gameEngine';

export default function Opponents({ state, myPlayerId }: { state: PublicState; myPlayerId: string }) {
  return (
    <section className={styles.opponents}>
      {state.players
        .filter(p => p.id !== myPlayerId)
        .map(p => {
          const isActive = state.currentPlayerId === p.id;
          const classes = [styles.opponent];
          if (isActive) classes.push(styles.opponentActive);
          if (!p.alive) classes.push(styles.opponentDead);
          const cnt = state.handCounts[p.id] ?? 0;
          return (
            <div key={p.id} className={classes.join(' ')}>
              <div style={{ fontWeight: 600 }}>{p.name}</div>
              <div style={{ fontSize: '0.85rem', opacity: 0.8 }}>
                {cnt} cards{p.alive ? '' : ' (out)'}
              </div>
            </div>
          );
        })}
    </section>
  );
}
