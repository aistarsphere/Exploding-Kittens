import { TYPES, isCat, type Card, type CardType } from './cardTypes';
import { buildGame, shuffle } from './deck';

const NOPE_WINDOW_MS = 2500;

export interface PlayerSeat { id: string; name: string; }
export interface PlayerState { id: string; name: string; alive: boolean; }

export type PromptType =
  | 'see-future' | 'alter-future' | 'favor-give'
  | 'cat-pair-target' | 'cat-trio-target' | 'cat-trio-name'
  | 'defuse-reinsert';

export interface Prompt {
  type: PromptType;
  forPlayerId: string;
  options: Record<string, unknown>;
}

interface InternalPrompt extends Prompt {
  _kitten?: Card;
}

export interface Pending {
  actorId: string;
  kind: string;
  payload: { cards: Card[]; payload?: Record<string, unknown> };
  expiresAt: number;
  nopeChain: string[];
}

export interface PublicState {
  status: 'playing' | 'ended';
  players: PlayerState[];
  turnOrder: string[];
  turnIdx: number;
  direction: 1 | -1;
  remainingTurns: number;
  handCounts: Record<string, number>;
  deckCount: number;
  topDiscard: Card | null;
  pending: Pending | null;
  prompt: Prompt | null;
  log: Array<{ ts: number; text: string }>;
  winnerId: string | null;
  currentPlayerId: string;
}

type EmitFn =
  | ((event: 'state', payload: PublicState) => void)
  | ((event: 'error', payload: { playerId: string; message: string }) => void);

interface InternalState {
  status: 'playing' | 'ended';
  players: PlayerState[];
  hands: Record<string, Card[]>;
  turnOrder: string[];
  turnIdx: number;
  direction: 1 | -1;
  remainingTurns: number;
  deck: Card[];
  discard: Card[];
  pending: Pending | null;
  prompt: InternalPrompt | null;
  log: Array<{ ts: number; text: string }>;
  winnerId: string | null;
}

export class GameEngine {
  private state: InternalState;
  private emit: (event: string, payload: unknown) => void;
  private nopeTimer: NodeJS.Timeout | null = null;

  constructor(opts: { players: PlayerSeat[]; onEmit: (e: string, p: unknown) => void }) {
    this.emit = opts.onEmit;
    const { deck, hands } = buildGame(opts.players);
    this.state = {
      status: 'playing',
      players: opts.players.map(p => ({ id: p.id, name: p.name, alive: true })),
      hands,
      turnOrder: opts.players.map(p => p.id),
      turnIdx: 0,
      direction: 1,
      remainingTurns: 1,
      deck,
      discard: [],
      pending: null,
      prompt: null,
      log: [],
      winnerId: null,
    };
    this.log(`Game started with ${opts.players.length} players.`);
  }

  begin() { this.broadcast(); }

  // ---- helpers ----

  private log(text: string) {
    this.state.log.push({ ts: Date.now(), text });
    if (this.state.log.length > 50) this.state.log.shift();
  }

  private player(pid: string) { return this.state.players.find(p => p.id === pid); }
  private hand(pid: string) { return this.state.hands[pid] || []; }
  private currentPlayerId() { return this.state.turnOrder[this.state.turnIdx]; }

  private broadcast() {
    this.emit('state', this.serialize());
  }

  serialize(): PublicState {
    const handCounts: Record<string, number> = {};
    for (const pid of Object.keys(this.state.hands)) {
      handCounts[pid] = this.state.hands[pid].length;
    }
    return {
      status: this.state.status,
      players: this.state.players,
      turnOrder: this.state.turnOrder,
      turnIdx: this.state.turnIdx,
      direction: this.state.direction,
      remainingTurns: this.state.remainingTurns,
      handCounts,
      deckCount: this.state.deck.length,
      topDiscard: this.state.discard[this.state.discard.length - 1] || null,
      pending: this.state.pending,
      prompt: this.state.prompt ? {
        type: this.state.prompt.type,
        forPlayerId: this.state.prompt.forPlayerId,
        options: this.state.prompt.options,
      } : null,
      log: this.state.log,
      winnerId: this.state.winnerId,
      currentPlayerId: this.currentPlayerId(),
    };
  }

  handFor(pid: string): Card[] { return this.hand(pid).slice(); }

  // ---- entry points ----

  play(playerId: string, cardIds: string[], payload: Record<string, unknown> = {}) {
    if (this.state.status !== 'playing') return this.err(playerId, 'Game over.');
    if (this.state.pending) return this.err(playerId, 'Wait for the current action to resolve.');
    if (this.state.prompt) return this.err(playerId, 'A prompt is open. Resolve it first.');
    const player = this.player(playerId);
    if (!player || !player.alive) return this.err(playerId, 'You are not in the game.');
    if (playerId !== this.currentPlayerId()) return this.err(playerId, 'Not your turn.');

    const hand = this.hand(playerId);
    const cards = cardIds.map(id => hand.find(c => c.id === id)).filter(Boolean) as Card[];
    if (cards.length !== cardIds.length) return this.err(playerId, 'Card not in hand.');
    if (cards.length === 0) return this.err(playerId, 'Pick at least one card.');

    const kind = this.validatePlay(cards);
    if (!kind) return this.err(playerId, 'Invalid card combination.');

    if (cards[0].type === TYPES.DEFUSE || cards[0].type === TYPES.NOPE) {
      return this.err(playerId, 'That card cannot be played that way.');
    }

    for (const c of cards) {
      const idx = hand.indexOf(c);
      hand.splice(idx, 1);
      this.state.discard.push(c);
    }
    this.log(`${player.name} played ${this.describePlay(cards, kind)}.`);
    this.startPending(playerId, kind, { cards, payload });
  }

  nope(playerId: string) {
    if (!this.state.pending) return this.err(playerId, 'Nothing to Nope.');
    const hand = this.hand(playerId);
    const noped = hand.find(c => c.type === TYPES.NOPE);
    if (!noped) return this.err(playerId, 'No Nope card.');
    const player = this.player(playerId);
    if (!player || !player.alive) return this.err(playerId, 'You are out.');
    hand.splice(hand.indexOf(noped), 1);
    this.state.discard.push(noped);
    this.state.pending.nopeChain.push(playerId);
    this.state.pending.expiresAt = Date.now() + NOPE_WINDOW_MS;
    this.log(`${player.name} played Nope.`);
    this.scheduleResolve();
    this.broadcast();
  }

  resolvePrompt(playerId: string, response: Record<string, unknown>) {
    const prompt = this.state.prompt;
    if (!prompt) return this.err(playerId, 'No prompt active.');
    if (prompt.forPlayerId !== playerId) return this.err(playerId, 'Not your prompt.');
    this.state.prompt = null;
    this.handlePromptResponse(prompt, response);
    this.broadcast();
  }

  draw(playerId: string) {
    if (this.state.status !== 'playing') return this.err(playerId, 'Game over.');
    if (this.state.pending || this.state.prompt) return this.err(playerId, 'Wait.');
    if (playerId !== this.currentPlayerId()) return this.err(playerId, 'Not your turn.');
    this.drawTurn(playerId, false);
    this.broadcast();
  }

  removePlayer(playerId: string) {
    const p = this.player(playerId);
    if (!p || this.state.status !== 'playing' || !p.alive) return;
    p.alive = false;
    this.removeFromTurnOrder(playerId);
    this.log(`${p.name} left the game.`);
    this.checkWin();
  }

  // ---- validation ----

  private validatePlay(cards: Card[]): string | null {
    if (cards.length === 1) {
      const t = cards[0].type;
      const singles: CardType[] = [
        TYPES.ATTACK, TYPES.SKIP, TYPES.FAVOR, TYPES.SHUFFLE,
        TYPES.SEE_THE_FUTURE, TYPES.ALTER_THE_FUTURE,
        TYPES.DRAW_FROM_BOTTOM, TYPES.REVERSE,
        TYPES.DOUBLE_SLAP, TYPES.TRIPLE_SLAP,
      ];
      if (singles.includes(t)) return 'single';
      return null;
    }
    if (cards.length === 2 || cards.length === 3) {
      const nonFeral = cards.filter(c => c.type !== TYPES.CAT_FERAL);
      if (!nonFeral.every(c => isCat(c.type))) return null;
      const distinct = new Set(nonFeral.map(c => c.type));
      if (distinct.size > 1) return null;
      return cards.length === 2 ? 'cat-pair' : 'cat-trio';
    }
    return null;
  }

  private describePlay(cards: Card[], kind: string): string {
    if (kind === 'cat-pair' || kind === 'cat-trio') {
      const which = cards.find(c => c.type !== TYPES.CAT_FERAL) || cards[0];
      return `${kind === 'cat-pair' ? 'pair' : 'trio'} of ${which.type.replace('CAT_', '')}`;
    }
    return cards[0].type.replace(/_/g, ' ').toLowerCase();
  }

  // ---- pending / Nope window ----

  private startPending(actorId: string, kind: string, payload: { cards: Card[]; payload?: Record<string, unknown> }) {
    this.state.pending = {
      actorId, kind, payload,
      expiresAt: Date.now() + NOPE_WINDOW_MS,
      nopeChain: [],
    };
    this.scheduleResolve();
    this.broadcast();
  }

  private scheduleResolve() {
    if (this.nopeTimer) clearTimeout(this.nopeTimer);
    const delay = Math.max(0, (this.state.pending?.expiresAt ?? 0) - Date.now());
    this.nopeTimer = setTimeout(() => this.resolvePending(), delay);
  }

  private resolvePending() {
    const p = this.state.pending;
    if (!p) return;
    this.state.pending = null;
    if (p.nopeChain.length % 2 === 1) {
      this.log('Action was Noped.');
      this.broadcast();
      this.checkWin();
      return;
    }
    this.applyAction(p.actorId, p.kind, p.payload);
  }

  // ---- action effects ----

  private applyAction(actorId: string, kind: string, payload: { cards: Card[]; payload?: Record<string, unknown> }) {
    const cards = payload.cards;
    if (kind === 'cat-pair') return this.catPair(actorId);
    if (kind === 'cat-trio') return this.catTrio(actorId);

    const t = cards[0].type;
    switch (t) {
      case TYPES.SKIP:             return this.endTurnNoDraw();
      case TYPES.ATTACK:           return this.stackTurns(2);
      case TYPES.DOUBLE_SLAP:      return this.stackTurns(2);
      case TYPES.TRIPLE_SLAP:      return this.stackTurns(3);
      case TYPES.SHUFFLE:          return this.doShuffle();
      case TYPES.SEE_THE_FUTURE:   return this.seeFuture(actorId);
      case TYPES.ALTER_THE_FUTURE: return this.alterFuture(actorId);
      case TYPES.FAVOR:            return this.favor(actorId, payload.payload?.target as string | undefined);
      case TYPES.REVERSE:          return this.reverse();
      case TYPES.DRAW_FROM_BOTTOM: { this.drawTurn(actorId, true); this.broadcast(); return; }
      default:
        this.log('Unhandled card type: ' + t);
        this.broadcast();
    }
  }

  private doShuffle() {
    shuffle(this.state.deck);
    this.log('Deck shuffled.');
    this.broadcast();
  }

  private seeFuture(actorId: string) {
    const top = this.state.deck.slice(-3).reverse();
    this.state.prompt = {
      type: 'see-future',
      forPlayerId: actorId,
      options: { cards: top.map(c => ({ id: c.id, type: c.type })) },
    };
    this.broadcast();
  }

  private alterFuture(actorId: string) {
    const top = this.state.deck.slice(-3).reverse();
    this.state.prompt = {
      type: 'alter-future',
      forPlayerId: actorId,
      options: { cards: top.map(c => ({ id: c.id, type: c.type })) },
    };
    this.broadcast();
  }

  private favor(actorId: string, targetId: string | undefined) {
    if (!targetId || targetId === actorId) {
      this.log('Favor cancelled (no valid target).');
      return this.broadcast();
    }
    const target = this.player(targetId);
    if (!target || !target.alive) {
      this.log('Favor cancelled (target not in game).');
      return this.broadcast();
    }
    if (this.hand(targetId).length === 0) {
      this.log(`${target.name} has no cards to give.`);
      return this.broadcast();
    }
    this.state.prompt = {
      type: 'favor-give',
      forPlayerId: targetId,
      options: {
        toPlayerId: actorId,
        cards: this.hand(targetId).map(c => ({ id: c.id, type: c.type })),
      },
    };
    this.broadcast();
  }

  private catPair(actorId: string) {
    this.state.prompt = {
      type: 'cat-pair-target',
      forPlayerId: actorId,
      options: { candidates: this.otherAliveIds(actorId) },
    };
    this.broadcast();
  }

  private catTrio(actorId: string) {
    this.state.prompt = {
      type: 'cat-trio-target',
      forPlayerId: actorId,
      options: { candidates: this.otherAliveIds(actorId) },
    };
    this.broadcast();
  }

  private otherAliveIds(actorId: string) {
    return this.state.players.filter(p => p.alive && p.id !== actorId).map(p => p.id);
  }

  private reverse() {
    this.state.direction = this.state.direction === 1 ? -1 : 1;
    this.log('Turn order reversed.');
    this.endTurnNoDraw();
  }

  private stackTurns(n: number) {
    this.advanceTurn();
    this.state.remainingTurns = n;
    this.log(`Next player takes ${n} turns.`);
    this.broadcast();
  }

  private endTurnNoDraw() {
    this.state.remainingTurns -= 1;
    if (this.state.remainingTurns <= 0) {
      this.advanceTurn();
      this.state.remainingTurns = 1;
    }
    this.broadcast();
  }

  private advanceTurn() {
    const n = this.state.turnOrder.length;
    if (n === 0) return;
    this.state.turnIdx = ((this.state.turnIdx + this.state.direction) % n + n) % n;
  }

  // ---- drawing ----

  private drawTurn(playerId: string, fromBottom: boolean) {
    if (this.state.deck.length === 0) {
      this.log('Deck empty (unexpected).');
      return this.endTurnNoDraw();
    }
    const card = fromBottom ? this.state.deck.shift()! : this.state.deck.pop()!;
    if (card.type === TYPES.EXPLODING_KITTEN) {
      const hand = this.hand(playerId);
      const defuse = hand.find(c => c.type === TYPES.DEFUSE);
      const player = this.player(playerId)!;
      if (defuse) {
        hand.splice(hand.indexOf(defuse), 1);
        this.state.discard.push(defuse);
        this.log(`${player.name} drew an Exploding Kitten and defused it!`);
        this.state.prompt = {
          type: 'defuse-reinsert',
          forPlayerId: playerId,
          options: { kittenId: card.id, deckSize: this.state.deck.length },
          _kitten: card,
        };
        this.broadcast();
        return;
      }
      this.log(`${player.name} drew an Exploding Kitten with no Defuse — BOOM!`);
      this.state.discard.push(card);
      player.alive = false;
      this.removeFromTurnOrder(playerId);
      this.state.remainingTurns = 1;
      this.checkWin();
      return;
    }
    this.hand(playerId).push(card);
    this.log(`${this.player(playerId)!.name} drew a card.`);
    this.endTurnNoDraw();
  }

  private removeFromTurnOrder(playerId: string) {
    const idx = this.state.turnOrder.indexOf(playerId);
    if (idx === -1) return;
    this.state.turnOrder.splice(idx, 1);
    if (idx < this.state.turnIdx) this.state.turnIdx -= 1;
    if (this.state.turnIdx >= this.state.turnOrder.length) this.state.turnIdx = 0;
  }

  private checkWin() {
    const alive = this.state.players.filter(p => p.alive);
    if (alive.length <= 1) {
      this.state.status = 'ended';
      this.state.winnerId = alive[0] ? alive[0].id : null;
      this.log(alive[0] ? `${alive[0].name} wins!` : 'No survivors.');
    }
    this.broadcast();
  }

  // ---- prompt responses ----

  private handlePromptResponse(prompt: InternalPrompt, response: Record<string, unknown>) {
    switch (prompt.type) {
      case 'see-future':
        this.log('Player peeked at the future.');
        break;

      case 'alter-future': {
        const order = (response.order as string[]) || [];
        const top3 = this.state.deck.slice(-3);
        const newTop = order
          .map(id => top3.find(c => c.id === id))
          .filter(Boolean) as Card[];
        if (newTop.length === 3) {
          this.state.deck.splice(this.state.deck.length - 3, 3, ...newTop.reverse());
          this.log('Player altered the future.');
        } else {
          this.log('Alter-future order invalid — left as-is.');
        }
        break;
      }

      case 'favor-give': {
        const giverId = prompt.forPlayerId;
        const recipientId = prompt.options.toPlayerId as string;
        const hand = this.hand(giverId);
        const card = hand.find(c => c.id === response.cardId);
        if (!card) { this.log('Favor: invalid card.'); break; }
        hand.splice(hand.indexOf(card), 1);
        this.hand(recipientId).push(card);
        this.log(`${this.player(giverId)!.name} gave a card to ${this.player(recipientId)!.name}.`);
        break;
      }

      case 'cat-pair-target': {
        const actorId = prompt.forPlayerId;
        const targetId = response.targetId as string;
        const tgtHand = this.hand(targetId);
        if (!tgtHand || tgtHand.length === 0) { this.log('Target has no cards.'); break; }
        const stolen = tgtHand.splice(Math.floor(Math.random() * tgtHand.length), 1)[0];
        this.hand(actorId).push(stolen);
        this.log(`${this.player(actorId)!.name} stole a card from ${this.player(targetId)!.name}.`);
        break;
      }

      case 'cat-trio-target': {
        const actorId = prompt.forPlayerId;
        const targetId = response.targetId as string;
        this.state.prompt = {
          type: 'cat-trio-name',
          forPlayerId: actorId,
          options: { targetId },
        };
        break;
      }

      case 'cat-trio-name': {
        const actorId = prompt.forPlayerId;
        const targetId = prompt.options.targetId as string;
        const namedType = response.namedType as CardType;
        const tgtHand = this.hand(targetId);
        const card = tgtHand.find(c => c.type === namedType);
        if (!card) {
          this.log(`${this.player(actorId)!.name} named ${namedType} — target had none.`);
          break;
        }
        tgtHand.splice(tgtHand.indexOf(card), 1);
        this.hand(actorId).push(card);
        this.log(`${this.player(actorId)!.name} took a ${namedType} from ${this.player(targetId)!.name}.`);
        break;
      }

      case 'defuse-reinsert': {
        const kitten = prompt._kitten!;
        let pos = parseInt(String(response.position ?? 0), 10);
        if (isNaN(pos) || pos < 0) pos = 0;
        if (pos > this.state.deck.length) pos = this.state.deck.length;
        const insertIdx = this.state.deck.length - pos;
        this.state.deck.splice(insertIdx, 0, kitten);
        this.log(`${this.player(prompt.forPlayerId)!.name} reinserted the Exploding Kitten.`);
        this.endTurnNoDraw();
        return; // broadcast happens inside endTurnNoDraw
      }
    }
  }

  private err(playerId: string, message: string) {
    this.emit('error', { playerId, message });
  }
}
