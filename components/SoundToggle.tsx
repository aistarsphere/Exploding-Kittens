'use client';

import { useEffect, useState } from 'react';
import { sfx } from '@/lib/sfx';
import styles from './SoundToggle.module.css';

export default function SoundToggle() {
  const [muted, setMuted] = useState(false);

  useEffect(() => {
    setMuted(sfx.isMuted());
    return sfx.subscribe(() => setMuted(sfx.isMuted()));
  }, []);

  const toggle = () => {
    const next = !sfx.isMuted();
    sfx.setMuted(next);
    if (!next) sfx.play('tap'); // confirm unmute
  };

  return (
    <button
      className={styles.toggle}
      onClick={toggle}
      aria-label={muted ? 'Unmute sound' : 'Mute sound'}
      title={muted ? 'Unmute' : 'Mute'}
    >
      {muted ? (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
          <path d="M16.5 12a4.5 4.5 0 0 0-1.42-3.27l-1.18 1.18A2.5 2.5 0 0 1 14.5 12c0 .53-.16 1.04-.43 1.46l1.18 1.18A4.5 4.5 0 0 0 16.5 12zM3 9v6h4l5 5V4l-5 5H3zm17.5 3c0 1.79-.7 3.4-1.85 4.6l1.42 1.42A8.46 8.46 0 0 0 22.5 12c0-2.45-1.04-4.66-2.69-6.22l-1.42 1.42A6.49 6.49 0 0 1 20.5 12z" opacity="0.4"/>
          <path d="M4.27 3 3 4.27 7.73 9H3v6h4l5 5v-6.73l4.25 4.25c-.67.52-1.42.93-2.25 1.17v2.06a8.94 8.94 0 0 0 3.69-1.81L19.73 21 21 19.73l-9-9L4.27 3zM12 4 9.91 6.09 12 8.18V4z"/>
        </svg>
      ) : (
        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
          <path d="M3 9v6h4l5 5V4L7 9H3zm13.5 3A4.5 4.5 0 0 0 14 7.97v8.05c1.48-.73 2.5-2.25 2.5-4.02zM14 3.23v2.06A8.5 8.5 0 0 1 14 18.71v2.06c4-1 7-4.62 7-8.77s-3-7.77-7-8.77z"/>
        </svg>
      )}
    </button>
  );
}
