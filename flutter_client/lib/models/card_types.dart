import 'package:flutter/material.dart';
import 'card_model.dart';

const Map<CardType, CardMeta> meta = {
  CardType.EXPLODING_KITTEN: CardMeta(label: 'Exploding Kitten', emoji: '💥', color: Color(0xFFC0392B), desc: 'Show immediately. You die unless you have a Defuse.'),
  CardType.DEFUSE:           CardMeta(label: 'Defuse',           emoji: '🛡️', color: Color(0xFF16A085), desc: 'Cancel an Exploding Kitten and reinsert it anywhere.'),
  CardType.NOPE:             CardMeta(label: 'Nope',             emoji: '🚫', color: Color(0xFF7F8C8D), desc: 'Cancel any non-EK, non-Defuse action. Can be played off-turn.'),
  CardType.ATTACK:           CardMeta(label: 'Attack',           emoji: '⚡', color: Color(0xFFE67E22), desc: 'End your turn. Next player takes 2 turns.'),
  CardType.SKIP:             CardMeta(label: 'Skip',             emoji: '⏭️', color: Color(0xFF2980B9), desc: 'End your turn without drawing.'),
  CardType.FAVOR:            CardMeta(label: 'Favor',            emoji: '🙏', color: Color(0xFF8E44AD), desc: 'Pick a player. They give you one card.'),
  CardType.SHUFFLE:          CardMeta(label: 'Shuffle',          emoji: '🔀', color: Color(0xFF27AE60), desc: 'Shuffle the draw pile.'),
  CardType.SEE_THE_FUTURE:   CardMeta(label: 'See the Future',   emoji: '🔮', color: Color(0xFF9B59B6), desc: 'Peek at the top 3 cards of the draw pile.'),
  CardType.ALTER_THE_FUTURE: CardMeta(label: 'Alter the Future', emoji: '🔭', color: Color(0xFF6A1B9A), desc: 'Peek at the top 3 cards and rearrange them.'),
  CardType.DRAW_FROM_BOTTOM: CardMeta(label: 'Draw from Bottom', emoji: '⬇️', color: Color(0xFF3498DB), desc: 'End your turn by drawing the bottom card.'),
  CardType.REVERSE:          CardMeta(label: 'Reverse',          emoji: '🔄', color: Color(0xFF1ABC9C), desc: 'Reverse turn order. Also ends your turn without drawing.'),
  CardType.DOUBLE_SLAP:      CardMeta(label: 'Double Slap',      emoji: '✋', color: Color(0xFFD35400), desc: 'End your turn. Next player takes 2 turns.'),
  CardType.TRIPLE_SLAP:      CardMeta(label: 'Triple Slap',      emoji: '🖐️', color: Color(0xFFA04000), desc: 'End your turn. Next player takes 3 turns.'),
  CardType.CAT_TACO:         CardMeta(label: 'Taco Cat',         emoji: '🌮', color: Color(0xFFF39C12), desc: 'Pair to steal a random card; trio to name a card.'),
  CardType.CAT_BEARD:        CardMeta(label: 'Beard Cat',        emoji: '🧔', color: Color(0xFF7D6608), desc: 'Pair to steal a random card; trio to name a card.'),
  CardType.CAT_RAINBOW:      CardMeta(label: 'Rainbow Cat',      emoji: '🌈', color: Color(0xFFEC407A), desc: 'Pair to steal a random card; trio to name a card.'),
  CardType.CAT_POTATO:       CardMeta(label: 'Potato Cat',       emoji: '🥔', color: Color(0xFFA1887F), desc: 'Pair to steal a random card; trio to name a card.'),
  CardType.CAT_MELON:        CardMeta(label: 'Cattermelon',      emoji: '🍉', color: Color(0xFFE74C3C), desc: 'Pair to steal a random card; trio to name a card.'),
  CardType.CAT_FERAL:        CardMeta(label: 'Feral Cat',        emoji: '😼', color: Color(0xFF34495E), desc: 'Wild cat — counts as any cat for pairs/trios.'),
};

const Map<CardType, String> imageFile = {
  CardType.EXPLODING_KITTEN: 'bomba.jpg',
  CardType.DEFUSE:           'defuse.jpg',
  CardType.NOPE:             'nope.jpg',
  CardType.ATTACK:           'attack.jpg',
  CardType.SKIP:             'skip.jpg',
  CardType.FAVOR:            'favorit.jpg',
  CardType.SHUFFLE:          'shuffle.jpg',
  CardType.SEE_THE_FUTURE:   'see_future.jpg',
  CardType.ALTER_THE_FUTURE: 'alter.jpg',
  CardType.DRAW_FROM_BOTTOM: 'draw_from_bottom.jpg',
  CardType.REVERSE:          'swap_top_bottom.jpg',
  CardType.DOUBLE_SLAP:      'attack_target.jpg',
  CardType.TRIPLE_SLAP:      'attack_target.jpg',
  CardType.CAT_TACO:         'tacocat.jpg',
  CardType.CAT_BEARD:        'beard_cat.jpg',
  CardType.CAT_RAINBOW:      'rainbow_ralphing_cat.jpg',
  CardType.CAT_POTATO:       'hyairy_potato_cat.jpg',
  CardType.CAT_MELON:        'cattermelon.jpg',
  CardType.CAT_FERAL:        'feral_cat.jpg',
};

const List<CardType> catTypes = [
  CardType.CAT_TACO, CardType.CAT_BEARD, CardType.CAT_RAINBOW,
  CardType.CAT_POTATO, CardType.CAT_MELON, CardType.CAT_FERAL,
];

bool isCat(CardType t) => catTypes.contains(t);
