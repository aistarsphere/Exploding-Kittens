// Card type constants + metadata. Imported by both client components and the
// authoritative server-side game engine.

export const TYPES = {
  EXPLODING_KITTEN: 'EXPLODING_KITTEN',
  DEFUSE: 'DEFUSE',
  NOPE: 'NOPE',
  ATTACK: 'ATTACK',
  SKIP: 'SKIP',
  FAVOR: 'FAVOR',
  SHUFFLE: 'SHUFFLE',
  SEE_THE_FUTURE: 'SEE_THE_FUTURE',
  ALTER_THE_FUTURE: 'ALTER_THE_FUTURE',
  DRAW_FROM_BOTTOM: 'DRAW_FROM_BOTTOM',
  REVERSE: 'REVERSE',
  DOUBLE_SLAP: 'DOUBLE_SLAP',
  TRIPLE_SLAP: 'TRIPLE_SLAP',
  CAT_TACO: 'CAT_TACO',
  CAT_BEARD: 'CAT_BEARD',
  CAT_RAINBOW: 'CAT_RAINBOW',
  CAT_POTATO: 'CAT_POTATO',
  CAT_MELON: 'CAT_MELON',
  CAT_FERAL: 'CAT_FERAL',
} as const;

export type CardType = (typeof TYPES)[keyof typeof TYPES];

export interface CardMeta {
  label: string;
  emoji: string;
  color: string;
  desc: string;
}

export const META: Record<CardType, CardMeta> = {
  [TYPES.EXPLODING_KITTEN]: { label: 'Exploding Kitten', emoji: '💥', color: '#c0392b', desc: 'Show immediately. You die unless you have a Defuse.' },
  [TYPES.DEFUSE]:           { label: 'Defuse',           emoji: '🛡️', color: '#16a085', desc: 'Cancel an Exploding Kitten and reinsert it anywhere.' },
  [TYPES.NOPE]:             { label: 'Nope',             emoji: '🚫', color: '#7f8c8d', desc: 'Cancel any non-EK, non-Defuse action. Can be played off-turn.' },
  [TYPES.ATTACK]:           { label: 'Attack',           emoji: '⚡', color: '#e67e22', desc: 'End your turn. Next player takes 2 turns.' },
  [TYPES.SKIP]:             { label: 'Skip',             emoji: '⏭️', color: '#2980b9', desc: 'End your turn without drawing.' },
  [TYPES.FAVOR]:            { label: 'Favor',            emoji: '🙏', color: '#8e44ad', desc: 'Pick a player. They give you one card.' },
  [TYPES.SHUFFLE]:          { label: 'Shuffle',          emoji: '🔀', color: '#27ae60', desc: 'Shuffle the draw pile.' },
  [TYPES.SEE_THE_FUTURE]:   { label: 'See the Future',   emoji: '🔮', color: '#9b59b6', desc: 'Peek at the top 3 cards of the draw pile.' },
  [TYPES.ALTER_THE_FUTURE]: { label: 'Alter the Future', emoji: '🔭', color: '#6a1b9a', desc: 'Peek at the top 3 cards and rearrange them.' },
  [TYPES.DRAW_FROM_BOTTOM]: { label: 'Draw from the Bottom', emoji: '⬇️', color: '#3498db', desc: 'End your turn by drawing the bottom card.' },
  [TYPES.REVERSE]:          { label: 'Reverse',          emoji: '🔄', color: '#1abc9c', desc: 'Reverse turn order. Also ends your turn without drawing.' },
  [TYPES.DOUBLE_SLAP]:      { label: 'Double Slap',      emoji: '✋✋', color: '#d35400', desc: 'End your turn. Next player takes 2 turns.' },
  [TYPES.TRIPLE_SLAP]:      { label: 'Triple Slap',      emoji: '🖐️🖐️🖐️', color: '#a04000', desc: 'End your turn. Next player takes 3 turns.' },
  [TYPES.CAT_TACO]:         { label: 'Taco Cat',         emoji: '🌮', color: '#f39c12', desc: 'Pair to steal a random card; trio to name a card.' },
  [TYPES.CAT_BEARD]:        { label: 'Beard Cat',        emoji: '🧔', color: '#7d6608', desc: 'Pair to steal a random card; trio to name a card.' },
  [TYPES.CAT_RAINBOW]:      { label: 'Rainbow Cat',      emoji: '🌈', color: '#ec407a', desc: 'Pair to steal a random card; trio to name a card.' },
  [TYPES.CAT_POTATO]:       { label: 'Potato Cat',       emoji: '🥔', color: '#a1887f', desc: 'Pair to steal a random card; trio to name a card.' },
  [TYPES.CAT_MELON]:        { label: 'Cattermelon',      emoji: '🍉', color: '#e74c3c', desc: 'Pair to steal a random card; trio to name a card.' },
  [TYPES.CAT_FERAL]:        { label: 'Feral Cat',        emoji: '😼', color: '#34495e', desc: 'Wild cat — counts as any cat for pairs/trios.' },
};

// Maps card types to image filenames under /public/images/.
// Files come from the user-supplied `images/` folder. Some Party Pack cards
// don't have a matching image — those fall back to the CSS-styled card.
export const IMAGE_FILE: Partial<Record<CardType, string>> = {
  [TYPES.EXPLODING_KITTEN]: 'bomba.jpg',
  [TYPES.DEFUSE]:           'defuse.jpg',
  [TYPES.NOPE]:             'nope.jpg',
  [TYPES.ATTACK]:           'attack.jpg',
  [TYPES.SKIP]:             'skip.jpg',
  [TYPES.FAVOR]:            'favorit.jpg',
  [TYPES.SHUFFLE]:          'shuffle.jpg',
  [TYPES.SEE_THE_FUTURE]:   'see_future.jpg',
  [TYPES.ALTER_THE_FUTURE]: 'alter.jpg',
  [TYPES.DRAW_FROM_BOTTOM]: 'draw_from_bottom.jpg',
  [TYPES.REVERSE]:          'swap_top_bottom.jpg',
  [TYPES.DOUBLE_SLAP]:      'attack_target.jpg',
  [TYPES.TRIPLE_SLAP]:      'attack_target.jpg',
  [TYPES.CAT_TACO]:         'tacocat.jpg',
  [TYPES.CAT_BEARD]:        'beard_cat.jpg',
  [TYPES.CAT_RAINBOW]:      'rainbow_ralphing_cat.jpg',
  [TYPES.CAT_POTATO]:       'hyairy_potato_cat.jpg',
  [TYPES.CAT_MELON]:        'cattermelon.jpg',
  [TYPES.CAT_FERAL]:        'feral_cat.jpg',
};

export const CAT_TYPES: CardType[] = [
  TYPES.CAT_TACO, TYPES.CAT_BEARD, TYPES.CAT_RAINBOW,
  TYPES.CAT_POTATO, TYPES.CAT_MELON, TYPES.CAT_FERAL,
];

export function isCat(t: CardType): boolean {
  return CAT_TYPES.includes(t);
}

export interface Card {
  id: string;
  type: CardType;
  pawPrint?: boolean;
}
