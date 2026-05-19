'use client';

import { useRouter } from 'next/navigation';
import styles from '@/app/game/game.module.css';
import type { PublicState } from '@/lib/gameEngine';

export default function GameOver({ state }: { state: PublicState }) {
  const router = useRouter();
  if (state.status !== 'ended') return null;
  const winner = state.players.find(p => p.id === state.winnerId);
  return (
    <div className={styles.gameOver}>
      <h2>{winner ? `🏆 ${winner.name} wins!` : 'Game Over'}</h2>
      <p>Want to play again? Return to the lobby.</p>
      <button onClick={() => {
        sessionStorage.removeItem('ek-session');
        router.push('/');
      }}>Back to Lobby</button>
    </div>
  );
}
