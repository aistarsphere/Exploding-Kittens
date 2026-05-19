import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/card_model.dart';
import '../../models/card_types.dart';
import '../../models/game_state.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';

const int _nopeWindowMs = 2500;

class NopeBanner extends ConsumerStatefulWidget {
  final PublicState state;
  final List<CardModel> myHand;
  final String myPlayerId;
  final VoidCallback onNope;

  const NopeBanner({
    super.key,
    required this.state,
    required this.myHand,
    required this.myPlayerId,
    required this.onNope,
  });

  @override
  ConsumerState<NopeBanner> createState() => _NopeBannerState();
}

class _NopeBannerState extends ConsumerState<NopeBanner> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _lastPendingId;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: _nopeWindowMs));
  }

  @override
  void didUpdateWidget(NopeBanner old) {
    super.didUpdateWidget(old);
    final p = widget.state.pending;
    if (p != null && p.expiresAt.toString() != _lastPendingId) {
      _lastPendingId = p.expiresAt.toString();
      final remaining = p.expiresAt - DateTime.now().millisecondsSinceEpoch;
      final pct = remaining.clamp(0, _nopeWindowMs) / _nopeWindowMs;
      _controller.duration = Duration(milliseconds: remaining.clamp(0, _nopeWindowMs));
      _controller.reverse(from: pct.toDouble());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final tr = AppLocalizations.of(lang);
    final p = widget.state.pending;
    if (p == null) return const SizedBox.shrink();

    final actor = widget.state.players.where((x) => x.id == p.actorId).firstOrNull;
    final cardType = p.cards.isNotEmpty ? p.cards.first.type : null;
    final d = cardType != null ? AppLocalizations.getCardDisplay(cardType, lang) : null;
    final cardLabel = d?.label ?? '?';
    final noped = p.nopeChain.length;
    final myHasNope = widget.myHand.any((c) => c.type == CardType.NOPE);
    final canNope = myHasNope && p.actorId != widget.myPlayerId;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC0392B), Color(0xFF6A1D12)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withOpacity(0.4)),
        boxShadow: [BoxShadow(color: AppColors.crimson.withOpacity(0.4), blurRadius: 12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tr.played(actor?.name ?? '?', cardLabel) +
                      (noped > 0 ? ' · ${tr.nopeChain(noped)}' : ''),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Cairo'),
                ),
              ),
              if (canNope)
                GestureDetector(
                  onTap: widget.onNope,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tr.nope,
                      style: const TextStyle(
                        color: Color(0xFF1A0806),
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => LinearProgressIndicator(
              value: _controller.value,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
