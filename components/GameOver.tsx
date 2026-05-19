'use client';

import { useRouter } from 'next/navigation';
import { useLang } from '@/lib/LanguageContext';
import styles from '@/app/game/game.module.css';
import type { PublicState } from '@/lib/gameEngine';

export default function GameOver({ state }: { state: PublicState }) {
  const router = useRouter();
  const { tr } = useLang();
  if (state.status !== 'ended') return null;
  const winner = state.players.find(p => p.id === state.winnerId);
  return (
    <div className={styles.gameOver}>
      <h2>{winner ? tr.wins(winner.name) : tr.gameOverTitle}</h2>
      <p>{tr.playAgain}</p>
      <button onClick={() => {
        sessionStorage.removeItem('ek-session');
        router.push('/');
      }}>{tr.backToLobby}</button>
    </div>
  );
}
