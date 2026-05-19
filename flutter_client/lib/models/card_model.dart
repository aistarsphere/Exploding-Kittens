import 'package:flutter/material.dart';

enum CardType {
  EXPLODING_KITTEN,
  DEFUSE,
  NOPE,
  ATTACK,
  SKIP,
  FAVOR,
  SHUFFLE,
  SEE_THE_FUTURE,
  ALTER_THE_FUTURE,
  DRAW_FROM_BOTTOM,
  REVERSE,
  DOUBLE_SLAP,
  TRIPLE_SLAP,
  CAT_TACO,
  CAT_BEARD,
  CAT_RAINBOW,
  CAT_POTATO,
  CAT_MELON,
  CAT_FERAL;

  static CardType fromString(String s) {
    return CardType.values.firstWhere(
      (e) => e.name == s,
      orElse: () => CardType.NOPE,
    );
  }
}

class CardMeta {
  final String label;
  final String emoji;
  final Color color;
  final String desc;

  const CardMeta({
    required this.label,
    required this.emoji,
    required this.color,
    required this.desc,
  });

  CardMeta copyWith({String? label, String? desc}) => CardMeta(
    label: label ?? this.label,
    emoji: emoji,
    color: color,
    desc: desc ?? this.desc,
  );
}

class CardModel {
  final String id;
  final CardType type;
  final bool pawPrint;

  const CardModel({required this.id, required this.type, this.pawPrint = false});

  factory CardModel.fromJson(Map<String, dynamic> json) => CardModel(
    id: json['id'] as String,
    type: CardType.fromString(json['type'] as String),
    pawPrint: (json['pawPrint'] as bool?) ?? false,
  );

  Map<String, dynamic> toJson() => {'id': id, 'type': type.name};
}
