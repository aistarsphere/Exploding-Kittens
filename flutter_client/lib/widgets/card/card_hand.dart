import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import 'game_card.dart';

double computeOverlap(int count, double screenWidth) {
  if (count <= 1) return 0;
  double cardW = 104, gap = 8, padding = 64;
  if (screenWidth <= 380) {
    cardW = 66; gap = 4; padding = 24;
  } else if (screenWidth <= 600) {
    cardW = 78; gap = 4; padding = 28;
  } else if (screenWidth <= 820) {
    cardW = 92; gap = 8; padding = 40;
  }
  final available = max(160.0, screenWidth - padding);
  final fullWidth = count * cardW + (count - 1) * gap;
  if (fullWidth <= available) return 0;
  return -min(cardW * 0.72, (fullWidth - available) / (count - 1) + gap);
}

double _cardWidth(double screenWidth) {
  if (screenWidth <= 380) return 66;
  if (screenWidth <= 600) return 78;
  if (screenWidth <= 820) return 92;
  return 104;
}

double _cardHeight(double screenWidth) {
  if (screenWidth <= 380) return 92;
  if (screenWidth <= 600) return 108;
  if (screenWidth <= 820) return 128;
  return 144;
}

class CardHand extends StatelessWidget {
  final List<CardModel> hand;
  final Set<String> selectedIds;
  final void Function(String id) onToggle;

  const CardHand({
    super.key,
    required this.hand,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final overlap = computeOverlap(hand.length, screenWidth);
    final cardW = _cardWidth(screenWidth);
    final cardH = _cardHeight(screenWidth);
    final n = hand.length;
    final center = (n - 1) / 2;

    if (n == 0) return const SizedBox(height: 100);

    return SizedBox(
      height: cardH + 20,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: hand.asMap().entries.map((entry) {
            final i = entry.key;
            final card = entry.value;
            final offsetFromCenter = i - center;
            final rot = offsetFromCenter * 0.042; // radians ~2.4deg
            final lift = (offsetFromCenter.abs() * 1.8);
            final isSelected = selectedIds.contains(card.id);

            return Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.identity()
                ..rotateZ(rot)
                ..translate(0.0, isSelected ? -14.0 : lift),
              child: Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 0 : (overlap < 0 ? -overlap / 2 : 4),
                  right: i == n - 1 ? 0 : (overlap < 0 ? -overlap / 2 : 4),
                ),
                child: GameCard(
                  card: card,
                  selected: isSelected,
                  width: cardW,
                  height: cardH,
                  onTap: () => onToggle(card.id),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
