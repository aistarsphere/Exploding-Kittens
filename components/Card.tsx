'use client';

import { useState } from 'react';
import { IMAGE_FILE, type Card as CardData } from '@/lib/cardTypes';
import { getCardMeta } from '@/lib/i18n';
import { useLang } from '@/lib/LanguageContext';
import styles from './Card.module.css';

interface Props {
  card?: CardData | { id?: string; type?: string };
  selected?: boolean;
  faceDown?: boolean;
  onClick?: () => void;
}

export default function Card({ card, selected, faceDown, onClick }: Props) {
  const { lang } = useLang();
  const type = card?.type as Parameters<typeof getCardMeta>[0] | undefined;
  const meta = type ? getCardMeta(type, lang) : undefined;
  const imgFile = type ? IMAGE_FILE[type] : undefined;
  const [imgFailed, setImgFailed] = useState(false);

  const classes = [styles.card];
  if (selected) classes.push(styles.selected);
  if (faceDown) classes.push(styles.faceDown);
  const useImage = !faceDown && imgFile && !imgFailed;
  if (!useImage) classes.push(styles.cssBg);

  const style = { '--bg': meta?.color || '#222' } as React.CSSProperties;

  if (faceDown) {
    return (
      <div className={classes.join(' ')} style={style} onClick={onClick}>
        <div className={styles.inner}>
          <div className={styles.emoji}>🐱</div>
          <div className={styles.labelTop}>Exploding<br/>Kittens</div>
        </div>
      </div>
    );
  }

  if (!meta) return <div className={classes.join(' ')} style={style} onClick={onClick} />;

  if (useImage) {
    return (
      <div className={classes.join(' ')} style={style} onClick={onClick}>
        <img
          className={styles.art}
          alt={meta.label}
          src={`/images/${imgFile}`}
          onError={() => setImgFailed(true)}
        />
      </div>
    );
  }

  return (
    <div className={classes.join(' ')} style={style} onClick={onClick}>
      <div className={styles.inner}>
        <div className={styles.labelTop}>{meta.label}</div>
        <div className={styles.emoji}>{meta.emoji}</div>
        <div className={styles.desc}>{meta.desc}</div>
      </div>
    </div>
  );
}
