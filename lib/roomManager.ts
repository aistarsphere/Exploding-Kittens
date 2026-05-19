import { GameEngine } from './gameEngine';

const CODE_CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
const CODE_LEN = 4;
export const MAX_PLAYERS = 10;
export const MIN_PLAYERS = 2;
const RECONNECT_GRACE_MS = 5 * 60 * 1000;

function randomCode(): string {
  let s = '';
  for (let i = 0; i < CODE_LEN; i++) {
    s += CODE_CHARS[Math.floor(Math.random() * CODE_CHARS.length)];
  }
  return s;
}

function randomId(): string {
  return 'p_' + Math.random().toString(36).slice(2, 10);
}

export interface RoomPlayer {
  id: string;
  name: string;
  socketId: string | null;
  connected: boolean;
  disconnectAt: number | null;
}

export class Room {
  code: string;
  manager: RoomManager;
  players: RoomPlayer[] = [];
  hostId: string | null = null;
  engine: GameEngine | null = null;
  private cleanupTimer: NodeJS.Timeout | null = null;

  constructor(code: string, manager: RoomManager) {
    this.code = code;
    this.manager = manager;
  }

  addPlayer(name: string, makeHost: boolean): string {
    name = (name || '').trim().slice(0, 24) || 'Player';
    const id = randomId();
    this.players.push({ id, name, socketId: null, connected: false, disconnectAt: null });
    if (makeHost) this.hostId = id;
    return id;
  }

  attachSocket(playerId: string, socketId: string): boolean {
    const p = this.players.find(x => x.id === playerId);
    if (!p) return false;
    p.socketId = socketId;
    p.connected = true;
    p.disconnectAt = null;
    return true;
  }

  detachSocket(socketId: string): RoomPlayer | null {
    const p = this.players.find(x => x.socketId === socketId);
    if (!p) return null;
    p.connected = false;
    p.disconnectAt = Date.now();
    p.socketId = null;
    if (this.hostId === p.id) {
      const next = this.players.find(x => x.id !== p.id && x.connected);
      if (next) this.hostId = next.id;
    }
    return p;
  }

  removePlayer(playerId: string) {
    this.players = this.players.filter(p => p.id !== playerId);
    if (this.hostId === playerId) {
      const next = this.players.find(p => p.connected) || this.players[0];
      this.hostId = next ? next.id : null;
    }
    if (this.engine) this.engine.removePlayer(playerId);
  }

  startGame(emit: (e: string, p: unknown) => void) {
    if (this.players.length < MIN_PLAYERS) throw new Error('Need at least 2 players.');
    if (this.players.length > MAX_PLAYERS) throw new Error('Too many players.');
    if (this.engine) throw new Error('Already started.');
    const seats = this.players.map(p => ({ id: p.id, name: p.name }));
    this.engine = new GameEngine({ players: seats, onEmit: emit });
    this.engine.begin();
  }

  lobbyState() {
    return {
      code: this.code,
      hostId: this.hostId,
      started: !!this.engine,
      players: this.players.map(p => ({
        id: p.id, name: p.name, connected: p.connected,
      })),
    };
  }

  scheduleCleanup() {
    if (this.cleanupTimer) clearTimeout(this.cleanupTimer);
    this.cleanupTimer = setTimeout(() => {
      const anyConnected = this.players.some(p => p.connected);
      if (!anyConnected) this.manager.deleteRoom(this.code);
    }, RECONNECT_GRACE_MS);
  }
}

export class RoomManager {
  rooms: Map<string, Room> = new Map();

  createRoom(hostName: string) {
    let code: string;
    do { code = randomCode(); } while (this.rooms.has(code));
    const room = new Room(code, this);
    this.rooms.set(code, room);
    const playerId = room.addPlayer(hostName, true);
    return { code, playerId };
  }

  joinRoom(code: string, name: string) {
    code = (code || '').toUpperCase();
    const room = this.rooms.get(code);
    if (!room) throw new Error('Room not found.');
    if (room.engine) throw new Error('Game already started.');
    if (room.players.length >= MAX_PLAYERS) throw new Error('Room full.');
    const playerId = room.addPlayer(name, false);
    return { code, playerId };
  }

  getRoom(code: string): Room | undefined {
    return this.rooms.get((code || '').toUpperCase());
  }

  deleteRoom(code: string) {
    this.rooms.delete(code);
  }
}
