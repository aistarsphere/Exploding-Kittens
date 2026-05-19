'use client';

import styles from './FloatingText.module.css';

interface Props {
  text: string;
  color: string;
  big?: boolean;
  x?: number;
  y?: number;
}

export default function FloatingText({ text, color, big, x, y }: Props) {
  const style: React.CSSProperties = {
    color,
    left: x != null ? `${x}px` : '50%',
    top:  y != null ? `${y}px` : '38%',
    transform: x != null || y != null ? undefined : 'translate(-50%, -50%)',
  };
  return (
    <div className={`${styles.text} ${big ? styles.big : ''}`} style={style}>
      {text}
    </div>
  );
}
