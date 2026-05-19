'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useSocket, emitAck } from '@/lib/useSocket';
import styles from './lobby.module.css';

type Step = 'start' | 'join' | 'lobby';
interface LobbyPlayer { id: string; name: string; connected: boolean }
interface Lobby { code: string; hostId: string | null; started: boolean; players: LobbyPlayer[] }

export default function LobbyPage() {
  const { socket, connected } = useSocket();
  const router = useRouter();
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
    if (!name.trim()) { setError('Please enter your name.'); return; }
    const res = await emitAck<{ ok: boolean; error?: string; code: string; playerId: string }>(
      socket, 'lobby:create', { name: name.trim() },
    );
    if (!res.ok) { setError(res.error || 'Failed.'); return; }
    setMyPlayerId(res.playerId);
    setMyRoomCode(res.code);
    persist(res.code, res.playerId);
    setStep('lobby');
  }

  async function onJoinGo() {
    setJoinError('');
    if (!name.trim()) { setJoinError('Please enter your name.'); return; }
    if (!code.trim()) { setJoinError('Enter a room code.'); return; }
    const res = await emitAck<{ ok: boolean; error?: string; code: string; playerId: string }>(
      socket, 'lobby:join', { code: code.trim().toUpperCase(), name: name.trim() },
    );
    if (!res.ok) { setJoinError(res.error || 'Failed.'); return; }
    setMyPlayerId(res.playerId);
    setMyRoomCode(res.code);
    persist(res.code, res.playerId);
    setStep('lobby');
  }

  async function onStart() {
    const res = await emitAck<{ ok: boolean; error?: string }>(socket, 'lobby:start', {});
    if (!res.ok) alert(res.error || 'Failed to start.');
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
        <h1 className={styles.title}>💥 Exploding Kittens</h1>
        <p className={styles.subtitle}>Online multiplayer · 2–10 players</p>
        {!connected && (
          <p className={styles.error} role="status">
            Connecting to server…
          </p>
        )}

        {step === 'start' && (
          <section className={styles.card}>
            <label className={styles.label} htmlFor="name">Your name</label>
            <input id="name" className={styles.input} type="text" maxLength={24}
              placeholder="e.g. Whiskers" autoComplete="off"
              value={name} onChange={e => setName(e.target.value)} />
            <div className={styles.row}>
              <button className={`${styles.button} ${styles.primary}`} onClick={onCreate}>Create Room</button>
              <button className={styles.button} onClick={() => setStep('join')}>Join Room</button>
            </div>
            <p className={styles.error}>{error}</p>
          </section>
        )}

        {step === 'join' && (
          <section className={styles.card}>
            <label className={styles.label} htmlFor="code">Room code</label>
            <input id="code" className={`${styles.input} ${styles.code}`} type="text" maxLength={4}
              placeholder="ABCD" autoComplete="off"
              value={code} onChange={e => setCode(e.target.value.toUpperCase())} />
            <div className={styles.row}>
              <button className={`${styles.button} ${styles.primary}`} onClick={onJoinGo}>Join</button>
              <button className={styles.button} onClick={() => setStep('start')}>Back</button>
            </div>
            <p className={styles.error}>{joinError}</p>
          </section>
        )}

        {step === 'lobby' && (
          <section className={styles.card}>
            <h2>Room <span>{myRoomCode}</span></h2>
            <p className={styles.subtitle}>
              {isHost ? 'You are the master.' : 'Waiting for the master to start…'}
            </p>
            <ul className={styles.list}>
              {(lobby?.players || []).map(p => (
                <li key={p.id}>
                  <span>{p.name}{p.id === myPlayerId ? ' (you)' : ''}</span>
                  <span>
                    {p.id === lobby?.hostId && <span className={styles.badge}>master</span>}
                    {!p.connected && <span className={`${styles.badge} ${styles.off}`}>offline</span>}
                  </span>
                </li>
              ))}
            </ul>
            <div className={styles.row}>
              {isHost && (lobby?.players.length ?? 0) >= 2 && (
                <button className={`${styles.button} ${styles.primary}`} onClick={onStart}>Start Game</button>
              )}
              <button className={styles.button} onClick={onLeave}>Leave</button>
            </div>
            <p className={styles.hint}>Share the room code with friends so they can join.</p>
          </section>
        )}
      </div>
    </main>
  );
}
