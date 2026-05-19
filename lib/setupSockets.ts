// Wires all Socket.IO event handlers to a RoomManager.
// Used by both the combined server (server.ts) and the WS-only server
// (ws-server.ts) so socket logic isn't duplicated.

import type { Server as IOServer } from 'socket.io';
import type { RoomManager, Room } from './roomManager';

export function setupSockets(io: IOServer, rooms: RoomManager) {
  io.on('connection', (socket) => {
    let boundCode: string | null = null;
    let boundPlayerId: string | null = null;

    const bind = (code: string, playerId: string) => {
      boundCode = code;
      boundPlayerId = playerId;
      socket.join(code);
    };

    const currentRoom = (): Room | undefined => (boundCode ? rooms.getRoom(boundCode) : undefined);

    const broadcastLobby = (room: Room) => {
      io.to(room.code).emit('lobby:update', room.lobbyState());
    };

    const makeEngineEmit = (room: Room) => {
      return (event: string, payload: unknown) => {
        if (event === 'state') {
          io.to(room.code).emit('game:state', payload);
          for (const p of room.players) {
            if (p.socketId && room.engine) {
              io.to(p.socketId).emit('game:hand', { hand: room.engine.handFor(p.id) });
            }
          }
        } else if (event === 'error') {
          const e = payload as { playerId: string; message: string };
          const p = room.players.find(x => x.id === e.playerId);
          if (p?.socketId) io.to(p.socketId).emit('error:msg', { message: e.message });
        }
      };
    };

    socket.on('lobby:create', ({ name }: { name: string }, ack?: (r: unknown) => void) => {
      try {
        const { code, playerId } = rooms.createRoom(name);
        const room = rooms.getRoom(code)!;
        room.attachSocket(playerId, socket.id);
        bind(code, playerId);
        ack?.({ ok: true, code, playerId });
        broadcastLobby(room);
      } catch (e) {
        ack?.({ ok: false, error: (e as Error).message });
      }
    });

    socket.on('lobby:join', ({ code, name }: { code: string; name: string }, ack?: (r: unknown) => void) => {
      try {
        const result = rooms.joinRoom(code, name);
        const room = rooms.getRoom(result.code)!;
        room.attachSocket(result.playerId, socket.id);
        bind(result.code, result.playerId);
        ack?.({ ok: true, code: result.code, playerId: result.playerId });
        broadcastLobby(room);
      } catch (e) {
        ack?.({ ok: false, error: (e as Error).message });
      }
    });

    socket.on('lobby:resume', ({ code, playerId }: { code: string; playerId: string }, ack?: (r: unknown) => void) => {
      const room = rooms.getRoom(code);
      if (!room) return ack?.({ ok: false, error: 'Room not found.' });
      const p = room.players.find(x => x.id === playerId);
      if (!p) return ack?.({ ok: false, error: 'Player not found.' });
      room.attachSocket(playerId, socket.id);
      bind(code, playerId);
      ack?.({ ok: true });
      broadcastLobby(room);
      if (room.engine) {
        socket.emit('game:state', room.engine.serialize());
        socket.emit('game:hand', { hand: room.engine.handFor(playerId) });
      }
    });

    socket.on('lobby:start', (_msg: unknown, ack?: (r: unknown) => void) => {
      const room = currentRoom();
      if (!room) return ack?.({ ok: false, error: 'No room.' });
      if (room.hostId !== boundPlayerId) return ack?.({ ok: false, error: 'Only the host can start.' });
      try {
        room.startGame(makeEngineEmit(room));
        io.to(room.code).emit('lobby:started');
        ack?.({ ok: true });
      } catch (e) {
        ack?.({ ok: false, error: (e as Error).message });
      }
    });

    socket.on('game:play', ({ cardIds, payload }: { cardIds: string[]; payload?: Record<string, unknown> }, ack?: (r: unknown) => void) => {
      const room = currentRoom();
      if (!room || !room.engine || !boundPlayerId) return ack?.({ ok: false, error: 'No game.' });
      room.engine.play(boundPlayerId, cardIds || [], payload || {});
      ack?.({ ok: true });
    });

    socket.on('game:nope', (_msg: unknown, ack?: (r: unknown) => void) => {
      const room = currentRoom();
      if (!room || !room.engine || !boundPlayerId) return ack?.({ ok: false, error: 'No game.' });
      room.engine.nope(boundPlayerId);
      ack?.({ ok: true });
    });

    socket.on('game:prompt', ({ response }: { response: Record<string, unknown> }, ack?: (r: unknown) => void) => {
      const room = currentRoom();
      if (!room || !room.engine || !boundPlayerId) return ack?.({ ok: false, error: 'No game.' });
      room.engine.resolvePrompt(boundPlayerId, response || {});
      ack?.({ ok: true });
    });

    socket.on('game:draw', (_msg: unknown, ack?: (r: unknown) => void) => {
      const room = currentRoom();
      if (!room || !room.engine || !boundPlayerId) return ack?.({ ok: false, error: 'No game.' });
      room.engine.draw(boundPlayerId);
      ack?.({ ok: true });
    });

    socket.on('lobby:leave', (_msg: unknown, ack?: (r: unknown) => void) => {
      const room = currentRoom();
      if (room && boundPlayerId) {
        room.removePlayer(boundPlayerId);
        broadcastLobby(room);
        if (room.players.length === 0) rooms.deleteRoom(room.code);
      }
      boundCode = null;
      boundPlayerId = null;
      ack?.({ ok: true });
    });

    socket.on('disconnect', () => {
      const room = currentRoom();
      if (!room) return;
      room.detachSocket(socket.id);
      broadcastLobby(room);
      room.scheduleCleanup();
    });
  });
}
