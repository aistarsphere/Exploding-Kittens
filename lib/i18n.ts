import type { CardType } from './cardTypes';
import { META } from './cardTypes';

export const LANGUAGES = ['en', 'ar'] as const;
export type Lang = (typeof LANGUAGES)[number];

// Arabic overrides for card labels + descriptions
const AR_CARD: Partial<Record<CardType, { label: string; desc: string }>> = {
  EXPLODING_KITTEN: { label: 'قطة متفجرة',     desc: 'أظهرها فوراً. ستموت إن لم يكن لديك تفكيك.' },
  DEFUSE:           { label: 'تفكيك',           desc: 'ألغِ قطة متفجرة وأعد إدراجها في أي مكان.' },
  NOPE:             { label: 'لا',              desc: 'ألغِ أي حركة (عدا القطة والتفكيك). تُلعب خارج دورك.' },
  ATTACK:           { label: 'هجوم',            desc: 'أنهِ دورك. يأخذ اللاعب التالي دورين.' },
  SKIP:             { label: 'تخطي',            desc: 'أنهِ دورك دون سحب.' },
  FAVOR:            { label: 'طلب جميل',        desc: 'اختر لاعباً. سيعطيك بطاقة واحدة.' },
  SHUFFLE:          { label: 'خلط',             desc: 'اخلط مجموعة السحب.' },
  SEE_THE_FUTURE:   { label: 'رؤية المستقبل',   desc: 'اطلع على أعلى 3 بطاقات في مجموعة السحب.' },
  ALTER_THE_FUTURE: { label: 'تغيير المستقبل',  desc: 'اطلع على أعلى 3 بطاقات ورتّبها.' },
  DRAW_FROM_BOTTOM: { label: 'سحب من الأسفل',   desc: 'أنهِ دورك بسحب أسفل بطاقة.' },
  REVERSE:          { label: 'عكس',             desc: 'اعكس ترتيب الأدوار. ينهي دورك دون سحب.' },
  DOUBLE_SLAP:      { label: 'صفعة مزدوجة',     desc: 'أنهِ دورك. يأخذ اللاعب التالي دورين.' },
  TRIPLE_SLAP:      { label: 'صفعة ثلاثية',     desc: 'أنهِ دورك. يأخذ اللاعب التالي ثلاثة أدوار.' },
  CAT_TACO:         { label: 'قطة التاكو',      desc: 'زوج: سرقة عشوائية؛ ثلاثي: سمِّ بطاقة.' },
  CAT_BEARD:        { label: 'قطة الذقن',       desc: 'زوج: سرقة عشوائية؛ ثلاثي: سمِّ بطاقة.' },
  CAT_RAINBOW:      { label: 'قطة قوس قزح',    desc: 'زوج: سرقة عشوائية؛ ثلاثي: سمِّ بطاقة.' },
  CAT_POTATO:       { label: 'قطة البطاطا',     desc: 'زوج: سرقة عشوائية؛ ثلاثي: سمِّ بطاقة.' },
  CAT_MELON:        { label: 'قطة البطيخ',      desc: 'زوج: سرقة عشوائية؛ ثلاثي: سمِّ بطاقة.' },
  CAT_FERAL:        { label: 'القطة المتوحشة',  desc: 'قطة عشوائية — تحل محل أي قطة في الأزواج والثلاثيات.' },
};

export function getCardMeta(type: CardType, lang: Lang) {
  if (lang === 'ar') {
    const ar = AR_CARD[type];
    if (ar) return { ...META[type], label: ar.label, desc: ar.desc };
  }
  return META[type];
}

export interface Translations {
  // Lobby
  title: string;
  subtitle: string;
  connecting: string;
  yourName: string;
  namePlaceholder: string;
  createRoom: string;
  joinRoom: string;
  roomCode: string;
  codePlaceholder: string;
  join: string;
  back: string;
  room: string;
  youAreMaster: string;
  waitingForMaster: string;
  you: string;
  master: string;
  offline: string;
  startGame: string;
  leave: string;
  shareHint: string;
  errEnterName: string;
  errEnterCode: string;
  errFailed: string;
  errFailedStart: string;
  // Game
  loading: string;
  gameOver: string;
  draw: string;
  discard: string;
  playSelected: string;
  drawEndTurn: string;
  yourTurn: string;
  couldNotRejoin: string;
  leaveGame: string;
  cannotPlay: string;
  turnText(name: string, isMe: boolean, turns: number, dir: string): string;
  // GameOver
  wins(name: string): string;
  gameOverTitle: string;
  playAgain: string;
  backToLobby: string;
  // NopeBanner
  played(name: string, card: string): string;
  nopeChain(n: number): string;
  nope: string;
  // PickTarget / PromptModal
  pickAPlayer: string;
  cancel: string;
  // Opponents
  cards(n: number): string;
  out: string;
  // PromptModal
  waitingFor(name: string): string;
  respondingTo(type: string): string;
  seeFuture: string;
  top3Cards: string;
  ok: string;
  alterFuture: string;
  clickCardsOrder: string;
  newOrder: string;
  reset: string;
  confirm: string;
  favor: string;
  giveCardTo(name: string): string;
  pickTarget: string;
  stealRandom: string;
  nameCardSteal: string;
  nameACard: string;
  nameCardTake: string;
  defuse: string;
  reinsertKitten: string;
  positionFromTop(pos: number, size: number): string;
  positionHint(size: number): string;
  reinsert: string;
}

const en: Translations = {
  title: '💥 Exploding Kittens',
  subtitle: 'Online multiplayer · 2–10 players',
  connecting: 'Connecting to server…',
  yourName: 'Your name',
  namePlaceholder: 'e.g. Whiskers',
  createRoom: 'Create Room',
  joinRoom: 'Join Room',
  roomCode: 'Room code',
  codePlaceholder: 'ABCD',
  join: 'Join',
  back: 'Back',
  room: 'Room',
  youAreMaster: 'You are the master.',
  waitingForMaster: 'Waiting for the master to start…',
  you: ' (you)',
  master: 'master',
  offline: 'offline',
  startGame: 'Start Game',
  leave: 'Leave',
  shareHint: 'Share the room code with friends so they can join.',
  errEnterName: 'Please enter your name.',
  errEnterCode: 'Enter a room code.',
  errFailed: 'Failed.',
  errFailedStart: 'Failed to start.',
  loading: 'Loading…',
  gameOver: 'Game over',
  draw: 'Draw',
  discard: 'Discard',
  playSelected: 'Play selected',
  drawEndTurn: 'Draw (end turn)',
  yourTurn: 'Your turn!',
  couldNotRejoin: 'Could not rejoin room.',
  leaveGame: 'Leave the game?',
  cannotPlay: 'Cannot play.',
  turnText: (name, isMe, turns, dir) =>
    `Turn: ${name}${isMe ? ' (you)' : ''} · ${turns} turn(s) ${dir}`,
  wins: (name) => `🏆 ${name} wins!`,
  gameOverTitle: 'Game Over',
  playAgain: 'Want to play again? Return to the lobby.',
  backToLobby: 'Back to Lobby',
  played: (name, card) => `${name} played ${card}`,
  nopeChain: (n) => `Nope chain: ${n}`,
  nope: 'NOPE!',
  pickAPlayer: 'Pick a player',
  cancel: 'Cancel',
  cards: (n) => `${n} cards`,
  out: '(out)',
  waitingFor: (name) => `Waiting for ${name}`,
  respondingTo: (type) => `They are responding to ${type}…`,
  seeFuture: 'See the Future',
  top3Cards: 'Top 3 cards (top first):',
  ok: 'OK',
  alterFuture: 'Alter the Future',
  clickCardsOrder: 'Click cards in the order you want them at top:',
  newOrder: 'New order (top → bottom):',
  reset: 'Reset',
  confirm: 'Confirm',
  favor: 'Favor',
  giveCardTo: (name) => `Give one card to ${name}:`,
  pickTarget: 'Pick a target',
  stealRandom: 'Steal a random card — pick a target',
  nameCardSteal: 'Name a card to steal — pick a target',
  nameACard: 'Name a card',
  nameCardTake: 'Name a card to take from the target:',
  defuse: 'Defuse!',
  reinsertKitten: 'Reinsert the Exploding Kitten:',
  positionFromTop: (pos, size) => `Position from top: ${pos} / ${size}`,
  positionHint: (size) => `0 = next card drawn · ${size} = bottom of deck`,
  reinsert: 'Reinsert',
};

const ar: Translations = {
  title: '💥 قطط متفجرة',
  subtitle: 'لعبة جماعية أونلاين · 2–10 لاعبين',
  connecting: 'جارٍ الاتصال بالخادم…',
  yourName: 'اسمك',
  namePlaceholder: 'مثلاً: شوارع',
  createRoom: 'إنشاء غرفة',
  joinRoom: 'الانضمام لغرفة',
  roomCode: 'رمز الغرفة',
  codePlaceholder: 'ABCD',
  join: 'انضمام',
  back: 'رجوع',
  room: 'الغرفة',
  youAreMaster: 'أنت المضيف.',
  waitingForMaster: 'في انتظار بدء المضيف…',
  you: ' (أنت)',
  master: 'مضيف',
  offline: 'غير متصل',
  startGame: 'بدء اللعبة',
  leave: 'مغادرة',
  shareHint: 'شارك رمز الغرفة مع أصدقائك حتى يتمكنوا من الانضمام.',
  errEnterName: 'يرجى إدخال اسمك.',
  errEnterCode: 'أدخل رمز الغرفة.',
  errFailed: 'فشل.',
  errFailedStart: 'فشل بدء اللعبة.',
  loading: 'جارٍ التحميل…',
  gameOver: 'انتهت اللعبة',
  draw: 'سحب',
  discard: 'مهملة',
  playSelected: 'العب المحدد',
  drawEndTurn: 'سحب (إنهاء الدور)',
  yourTurn: 'دورك!',
  couldNotRejoin: 'تعذّر الانضمام إلى الغرفة.',
  leaveGame: 'هل تريد مغادرة اللعبة؟',
  cannotPlay: 'لا يمكن اللعب.',
  turnText: (name, isMe, turns, dir) =>
    `الدور: ${name}${isMe ? ' (أنت)' : ''} · ${turns} دور ${dir}`,
  wins: (name) => `🏆 ${name} فاز!`,
  gameOverTitle: 'انتهت اللعبة',
  playAgain: 'هل تريد اللعب مجدداً؟ عد إلى الردهة.',
  backToLobby: 'العودة إلى الردهة',
  played: (name, card) => `${name} لعب ${card}`,
  nopeChain: (n) => `سلسلة اللا: ${n}`,
  nope: 'لا!',
  pickAPlayer: 'اختر لاعباً',
  cancel: 'إلغاء',
  cards: (n) => `${n} بطاقات`,
  out: '(خارج)',
  waitingFor: (name) => `في انتظار ${name}`,
  respondingTo: (type) => `يستجيب لـ ${type}…`,
  seeFuture: 'رؤية المستقبل',
  top3Cards: 'أعلى 3 بطاقات (من الأعلى):',
  ok: 'موافق',
  alterFuture: 'تغيير المستقبل',
  clickCardsOrder: 'انقر على البطاقات بالترتيب الذي تريدها في الأعلى:',
  newOrder: 'الترتيب الجديد (أعلى ← أسفل):',
  reset: 'إعادة تعيين',
  confirm: 'تأكيد',
  favor: 'طلب الجميل',
  giveCardTo: (name) => `أعطِ بطاقة واحدة لـ ${name}:`,
  pickTarget: 'اختر هدفاً',
  stealRandom: 'اسرق بطاقة عشوائية — اختر هدفاً',
  nameCardSteal: 'سمِّ بطاقة لسرقتها — اختر هدفاً',
  nameACard: 'سمِّ بطاقة',
  nameCardTake: 'سمِّ بطاقة لأخذها من الهدف:',
  defuse: 'تفكيك!',
  reinsertKitten: 'أعد إدراج القطة المتفجرة:',
  positionFromTop: (pos, size) => `الموضع من الأعلى: ${pos} / ${size}`,
  positionHint: (size) => `0 = البطاقة التالية · ${size} = أسفل المجموعة`,
  reinsert: 'إعادة الإدراج',
};

export const translations: Record<Lang, Translations> = { en, ar };
