'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useSocket, emitAck } from '@/lib/useSocket';
import { useLang } from '@/lib/LanguageContext';
import LanguageToggle from '@/components/LanguageToggle';
import styles from './lobby.module.css';

type Step = 'start' | 'join' | 'lobby';
interface LobbyPlayer { id: string; name: string; connected: boolean }
interface Lobby { code: string; hostId: string | null; started: boolean; players: LobbyPlayer[] }

export default function LobbyPage() {
  const { socket, connected } = useSocket();
  const router = useRouter();
  const { tr } = useLang();
  const [step, setStep] = useState<Step>('start');
  const [name, setName] = useState('');
  const [code, setCode] = useState('');
  const [error, setError] = useState('');
  const [joinError, setJoinError] = useState('');
  const [myPlayerId, setMyPlayerId] = useState<string | null>(null);
  const [myRoomCode, setMyRoomCode] = useState<string | null>(null);
  const [lobby, setLobby] = useState<Lobby | null>(null);

  // Restore from sessionStorage on mount (e.g. accidental refresh).
  useEffect(() => {
    const saved = typeof window !== 'undefined' ? sessionStorage.getItem('ek-session') : null;
    if (!saved) return;
    try {
      const { code: c, playerId, name: n } = JSON.parse(saved);
      setName(n || '');
      emitAck<{ ok: boolean }>(socket, 'lobby:resume', { code: c, playerId }).then((res) => {
        if (res?.ok) {
          setMyPlayerId(playerId);
          setMyRoomCode(c);
          setStep('lobby');
        }
      });
    } catch {}
  }, [socket]);

  // Lobby updates
  useEffect(() => {
    const onLobby = (l: Lobby) => setLobby(l);
    const onStarted = () => {
      if (myRoomCode && myPlayerId) {
        router.push(`/game?room=${encodeURIComponent(myRoomCode)}&pid=${encodeURIComponent(myPlayerId)}`);
      }
    };
    socket.on('lobby:update', onLobby);
    socket.on('lobby:started', onStarted);
    return () => {
      socket.off('lobby:update', onLobby);
      socket.off('lobby:started', onStarted);
    };
  }, [socket, myRoomCode, myPlayerId, router]);

  function persist(c: string, pid: string) {
    sessionStorage.setItem('ek-session', JSON.stringify({ code: c, playerId: pid, name }));
  }

  async function onCreate() {
    setError('');
    if (!name.trim()) { setError(tr.errEnterName); return; }
    const res = await emitAck<{ ok: boolean; error?: string; code: string; playerId: string }>(
      socket, 'lobby:create', { name: name.trim() },
    );
    if (!res.ok) { setError(res.error || tr.errFailed); return; }
    setMyPlayerId(res.playerId);
    setMyRoomCode(res.code);
    persist(res.code, res.playerId);
    setStep('lobby');
  }

  async function onJoinGo() {
    setJoinError('');
    if (!name.trim()) { setJoinError(tr.errEnterName); return; }
    if (!code.trim()) { setJoinError(tr.errEnterCode); return; }
    const res = await emitAck<{ ok: boolean; error?: string; code: string; playerId: string }>(
      socket, 'lobby:join', { code: code.trim().toUpperCase(), name: name.trim() },
    );
    if (!res.ok) { setJoinError(res.error || tr.errFailed); return; }
    setMyPlayerId(res.playerId);
    setMyRoomCode(res.code);
    persist(res.code, res.playerId);
    setStep('lobby');
  }

  async function onStart() {
    const res = await emitAck<{ ok: boolean; error?: string }>(socket, 'lobby:start', {});
    if (!res.ok) alert(res.error || tr.errFailedStart);
  }

  async function onLeave() {
    await emitAck(socket, 'lobby:leave', {});
    sessionStorage.removeItem('ek-session');
    setMyPlayerId(null);
    setMyRoomCode(null);
    setLobby(null);
    setStep('start');
  }

  const isHost = lobby?.hostId === myPlayerId;

  return (
    <main className={styles.page}>
      <div className={styles.lobby}>
        <div className={styles.langRow}>
          <LanguageToggle />
        </div>
        <h1 className={styles.title}>{tr.title}</h1>
        <p className={styles.subtitle}>{tr.subtitle}</p>
        {!connected && (
          <p className={styles.error} role="status">
            {tr.connecting}
          </p>
        )}

        {step === 'start' && (
          <section className={styles.card}>
            <label className={styles.label} htmlFor="name">{tr.yourName}</label>
            <input id="name" className={styles.input} type="text" maxLength={24}
              placeholder={tr.namePlaceholder} autoComplete="off"
              value={name} onChange={e => setName(e.target.value)} />
            <div className={styles.row}>
              <button className={`${styles.button} ${styles.primary}`} onClick={onCreate}>{tr.createRoom}</button>
              <button className={styles.button} onClick={() => setStep('join')}>{tr.joinRoom}</button>
            </div>
            <p className={styles.error}>{error}</p>
          </section>
        )}

        {step === 'join' && (
          <section className={styles.card}>
            <label className={styles.label} htmlFor="code">{tr.roomCode}</label>
            <input id="code" className={`${styles.input} ${styles.code}`} type="text" maxLength={4}
              placeholder={tr.codePlaceholder} autoComplete="off"
              value={code} onChange={e => setCode(e.target.value.toUpperCase())} />
            <div className={styles.row}>
              <button className={`${styles.button} ${styles.primary}`} onClick={onJoinGo}>{tr.join}</button>
              <button className={styles.button} onClick={() => setStep('start')}>{tr.back}</button>
            </div>
            <p className={styles.error}>{joinError}</p>
          </section>
        )}

        {step === 'lobby' && (
          <section className={styles.card}>
            <h2>{tr.room} <span>{myRoomCode}</span></h2>
            <p className={styles.subtitle}>
              {isHost ? tr.youAreMaster : tr.waitingForMaster}
            </p>
            <ul className={styles.list}>
              {(lobby?.players || []).map(p => (
                <li key={p.id}>
                  <span>{p.name}{p.id === myPlayerId ? tr.you : ''}</span>
                  <span>
                    {p.id === lobby?.hostId && <span className={styles.badge}>{tr.master}</span>}
                    {!p.connected && <span className={`${styles.badge} ${styles.off}`}>{tr.offline}</span>}
                  </span>
                </li>
              ))}
            </ul>
            <div className={styles.row}>
              {isHost && (lobby?.players.length ?? 0) >= 2 && (
                <button className={`${styles.button} ${styles.primary}`} onClick={onStart}>{tr.startGame}</button>
              )}
              <button className={styles.button} onClick={onLeave}>{tr.leave}</button>
            </div>
            <p className={styles.hint}>{tr.shareHint}</p>
          </section>
        )}
      </div>
    </main>
  );
}
