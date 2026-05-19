'use client';

import { useEffect, useRef, useState } from 'react';
import { io, type Socket } from 'socket.io-client';

// Shared singleton socket so the lobby and game pages share one connection
// across client-side navigation.
let sharedSocket: Socket | null = null;

// Where the Socket.IO server lives.
// - Local dev: undefined → connects to same origin (the combined server.ts).
// - Vercel + separate WS host: set NEXT_PUBLIC_SOCKET_URL to the WS host URL
//   (e.g. https://exploding-kittens-ws.onrender.com).
const SOCKET_URL = process.env.NEXT_PUBLIC_SOCKET_URL;

export function getSharedSocket(): Socket {
  if (!sharedSocket) {
    sharedSocket = SOCKET_URL
      ? io(SOCKET_URL, { autoConnect: true, transports: ['websocket', 'polling'], path: '/kittens/socket.io/' })
      : io({ autoConnect: true, path: '/kittens/socket.io/' });
  }
  return sharedSocket;
}

export function useSocket(): { socket: Socket; connected: boolean } {
  const socketRef = useRef<Socket | null>(null);
  if (!socketRef.current) socketRef.current = getSharedSocket();
  const [connected, setConnected] = useState(socketRef.current.connected);

  useEffect(() => {
    const s = socketRef.current!;
    const onConn = () => setConnected(true);
    const onDis = () => setConnected(false);
    s.on('connect', onConn);
    s.on('disconnect', onDis);
    setConnected(s.connected);
    return () => {
      s.off('connect', onConn);
      s.off('disconnect', onDis);
    };
  }, []);

  return { socket: socketRef.current, connected };
}

export function emitAck<T = unknown>(socket: Socket, event: string, msg: unknown): Promise<T> {
  return new Promise((resolve) => socket.emit(event, msg, resolve as (r: T) => void));
}
