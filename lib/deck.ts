import { TYPES, type Card, type CardType } from './cardTypes';

let nextId = 1;
function card(type: CardType, pawPrint: boolean): Card {
  return { id: `c${nextId++}`, type, pawPrint };
}

function buildCardPool(): Card[] {
  nextId = 1;
  const pool: Card[] = [];
  const spec: Array<[number, CardType, boolean]> = [
    // Paw-print cards (2-3 player set)
    [5, TYPES.NOPE, true],
    [3, TYPES.ATTACK, true],
    [3, TYPES.SKIP, true],
    [3, TYPES.FAVOR, true],
    [2, TYPES.SHUFFLE, true],
    [3, TYPES.SEE_THE_FUTURE, true],
    [2, TYPES.ALTER_THE_FUTURE, true],
    [2, TYPES.DRAW_FROM_BOTTOM, true],
    [2, TYPES.REVERSE, true],
    [2, TYPES.DOUBLE_SLAP, true],
    [2, TYPES.TRIPLE_SLAP, true],
    [3, TYPES.CAT_TACO, true],
    [3, TYPES.CAT_BEARD, true],
    [3, TYPES.CAT_RAINBOW, true],
    [3, TYPES.CAT_POTATO, true],
    [3, TYPES.CAT_MELON, true],
    [2, TYPES.CAT_FERAL, true],
    // Non-paw cards (4-7 player set)
    [5, TYPES.NOPE, false],
    [4, TYPES.ATTACK, false],
    [4, TYPES.SKIP, false],
    [4, TYPES.FAVOR, false],
    [4, TYPES.SHUFFLE, false],
    [5, TYPES.SEE_THE_FUTURE, false],
    [4, TYPES.ALTER_THE_FUTURE, false],
    [4, TYPES.DRAW_FROM_BOTTOM, false],
    [4, TYPES.REVERSE, false],
    [4, TYPES.DOUBLE_SLAP, false],
    [4, TYPES.TRIPLE_SLAP, false],
    [4, TYPES.CAT_TACO, false],
    [4, TYPES.CAT_BEARD, false],
    [4, TYPES.CAT_RAINBOW, false],
    [4, TYPES.CAT_POTATO, false],
    [4, TYPES.CAT_MELON, false],
    [3, TYPES.CAT_FERAL, false],
  ];
  for (const [n, type, paw] of spec) {
    for (let i = 0; i < n; i++) pool.push(card(type, paw));
  }
  return pool;
}

function filterForPlayerCount(pool: Card[], n: number): Card[] {
  if (n <= 3) return pool.filter(c => c.pawPrint);
  if (n <= 7) return pool.filter(c => !c.pawPrint);
  return pool.slice();
}

export function shuffle<T>(arr: T[]): T[] {
  for (let i = arr.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [arr[i], arr[j]] = [arr[j], arr[i]];
  }
  return arr;
}

export interface BuildSeats { id: string; name: string; }
export interface BuildResult {
  deck: Card[];
  hands: Record<string, Card[]>;
}

export function buildGame(players: BuildSeats[]): BuildResult {
  if (players.length < 2 || players.length > 10) {
    throw new Error('Need 2-10 players');
  }
  const pool = filterForPlayerCount(buildCardPool(), players.length);
  shuffle(pool);

  const hands: Record<string, Card[]> = {};
  for (const p of players) hands[p.id] = pool.splice(0, 7);

  // Defuses: one per player + (N+2) into the deck.
  const N = players.length;
  const totalDefuses = N + (N + 2);
  const defusePool: Card[] = [];
  for (let i = 0; i < totalDefuses; i++) defusePool.push(card(TYPES.DEFUSE, false));
  for (const p of players) hands[p.id].push(defusePool.pop()!);

  const deck = pool.concat(defusePool);
  shuffle(deck);

  for (let i = 0; i < players.length - 1; i++) {
    deck.push(card(TYPES.EXPLODING_KITTEN, false));
  }
  shuffle(deck);

  return { deck, hands };
}
