'use client';

import { useEffect, useRef, useState } from 'react';
import { on as onJuice } from '@/lib/juice';
import { startEngine, stopEngine } from '@/lib/particles';
import FloatingText from './FloatingText';
import styles from './JuiceLayer.module.css';

interface FT {
  id: number;
  text: string;
  color: string;
  big?: boolean;
  x?: number;
  y?: number;
}

export default function JuiceLayer() {
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const [texts, setTexts] = useState<FT[]>([]);
  const nextIdRef = useRef(1);

  useEffect(() => {
    if (canvasRef.current) startEngine(canvasRef.current);
    return () => stopEngine();
  }, []);

  useEffect(() => {
    const off = onJuice((e) => {
      if (e.type === 'floating-text') {
        const id = nextIdRef.current++;
        setTexts(prev => [...prev, { id, text: e.text, color: e.color, big: e.big, x: e.x, y: e.y }]);
        // Auto-remove after the animation completes.
        setTimeout(() => {
          setTexts(prev => prev.filter(t => t.id !== id));
        }, 1500);
      } else if (e.type === 'shake') {
        const cls =
          e.level === 'heavy' ? 'shake-heavy'
          : e.level === 'medium' ? 'shake-medium'
          : 'shake-light';
        document.body.classList.add(cls);
        const duration = e.level === 'heavy' ? 600 : e.level === 'medium' ? 450 : 280;
        setTimeout(() => document.body.classList.remove(cls), duration);
      }
    });
    return off;
  }, []);

  return (
    <>
      <canvas ref={canvasRef} className={styles.canvas} aria-hidden="true" />
      {texts.map(t => (
        <FloatingText key={t.id} text={t.text} color={t.color} big={t.big} x={t.x} y={t.y} />
      ))}
    </>
  );
}
