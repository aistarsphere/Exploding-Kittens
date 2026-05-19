import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/card_model.dart';
import 'game_card.dart';

double _cardWidth(double sw) {
  if (sw <= 380) return 66;
  if (sw <= 600) return 78;
  if (sw <= 820) return 92;
  return 104;
}

double _cardHeight(double sw) {
  if (sw <= 380) return 92;
  if (sw <= 600) return 108;
  if (sw <= 820) return 128;
  return 144;
}

double _padding(double sw) {
  if (sw <= 380) return 24;
  if (sw <= 600) return 28;
  if (sw <= 820) return 40;
  return 64;
}

/// Returns the per-card horizontal spacing (= cardWidth when no overlap,
/// or less when cards must overlap to fit).
double _spacingFor(int count, double sw) {
  final cardW = _cardWidth(sw);
  if (count <= 1) return cardW;
  final gap = sw <= 600 ? 4.0 : 8.0;
  final available = max(160.0, sw - _padding(sw));
  final natural = count * cardW + (count - 1) * gap;
  if (natural <= available) return cardW + gap;
  // need to overlap — minimum spacing is 28% of card width (max 72% overlap)
  final minSpacing = cardW * 0.28;
  final reduced = (available - cardW) / (count - 1);
  return max(minSpacing, reduced);
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
    final sw = MediaQuery.of(context).size.width;
    final cardW = _cardWidth(sw);
    final cardH = _cardHeight(sw);
    final n = hand.length;

    if (n == 0) {
      return SizedBox(height: cardH + 20);
    }

    final spacing = _spacingFor(n, sw);
    final totalWidth = cardW + (n - 1) * spacing;
    final center = (n - 1) / 2;

    return SizedBox(
      height: cardH + 24,
      width: double.infinity,
      child: ClipRect(
        child: OverflowBox(
          minWidth: 0,
          maxWidth: totalWidth,
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: totalWidth,
            height: cardH + 24,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: List.generate(n, (i) {
                final card = hand[i];
                final offsetFromCenter = i - center;
                final rot = offsetFromCenter * 0.042; // ~2.4°
                final lift = offsetFromCenter.abs() * 1.6;
                final isSelected = selectedIds.contains(card.id);
                final left = i * spacing;
                final bottom = (isSelected ? 16.0 : 0.0) - lift;

                return Positioned(
                  left: left,
                  bottom: bottom,
                  child: Transform.rotate(
                    angle: rot,
                    alignment: Alignment.bottomCenter,
                    child: GameCard(
                      card: card,
                      selected: isSelected,
                      width: cardW,
                      height: cardH,
                      onTap: () => onToggle(card.id),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
