'use client';

import { useEffect, useState } from 'react';
import Card from './Card';
import styles from '@/app/game/game.module.css';
import slotStyles from './Hand.module.css';
import type { Card as CardData } from '@/lib/cardTypes';

interface Props {
  hand: CardData[];
  selectedIds: Set<string>;
  onToggle: (id: string) => void;
}

// Compute card overlap so that all cards fit horizontally without scrolling.
// Uses negative margin-left between siblings when needed.
function useHandOverlap(count: number): number {
  const [vw, setVw] = useState<number>(
    typeof window !== 'undefined' ? window.innerWidth : 1280
  );
  useEffect(() => {
    const onResize = () => setVw(window.innerWidth);
    window.addEventListener('resize', onResize);
    return () => window.removeEventListener('resize', onResize);
  }, []);

  if (count <= 1) return 0;
  // Must match Card.module.css breakpoints.
  let cardW = 104, gap = 8, padding = 64;
  if (vw <= 380) { cardW = 66; gap = 4; padding = 24; }
  else if (vw <= 600) { cardW = 78; gap = 4; padding = 28; }
  else if (vw <= 820) { cardW = 92; gap = 8; padding = 40; }
  const available = Math.max(160, vw - padding);
  const fullWidth = count * cardW + (count - 1) * gap;
  if (fullWidth <= available) return 0;
  const needed = (fullWidth - available) / (count - 1);
  const maxOverlap = cardW * 0.72;
  return -Math.min(maxOverlap, needed + gap);
}

export default function Hand({ hand, selectedIds, onToggle }: Props) {
  const n = hand.length;
  const center = (n - 1) / 2;
  const overlap = useHandOverlap(n);

  return (
    <div className={styles.hand}>
      {hand.map((c, i) => {
        // Fan: small rotation increasing toward the edges, gentle dip toward center.
        const offsetFromCenter = i - center;
        const rot = offsetFromCenter * 2.4;
        const lift = Math.abs(offsetFromCenter) * 1.8;
        const style = {
          '--rot': `${rot}deg`,
          '--lift': `${lift}px`,
          '--delay': `${i * 35}ms`,
          '--overlap': `${overlap}px`,
        } as React.CSSProperties;
        return (
          <div key={c.id} className={slotStyles.slot} style={style}>
            <Card
              card={c}
              selected={selectedIds.has(c.id)}
              onClick={() => onToggle(c.id)}
            />
          </div>
        );
      })}
    </div>
  );
}
