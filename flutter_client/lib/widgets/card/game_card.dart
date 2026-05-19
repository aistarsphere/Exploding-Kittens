import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/card_model.dart';
import '../../models/card_types.dart';
import '../../config/app_config.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/lang_provider.dart';
import '../../theme/app_theme.dart';

const double kCardW = 104;
const double kCardH = 144;

class GameCard extends ConsumerStatefulWidget {
  final CardModel? card;
  final bool selected;
  final bool faceDown;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const GameCard({
    super.key,
    this.card,
    this.selected = false,
    this.faceDown = false,
    this.onTap,
    this.width = kCardW,
    this.height = kCardH,
  });

  @override
  ConsumerState<GameCard> createState() => _GameCardState();
}

class _GameCardState extends ConsumerState<GameCard> {
  bool _imgFailed = false;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);

    if (widget.faceDown) return _FaceDownCard(width: widget.width, height: widget.height, onTap: widget.onTap);

    final type = widget.card?.type;
    final cardMeta = type != null ? meta[type] : null;
    final imgFilename = type != null ? imageFile[type] : null;
    final display = type != null ? AppLocalizations.getCardDisplay(type, lang) : null;
    final bgColor = cardMeta?.color ?? const Color(0xFF222222);

    final useImage = imgFilename != null && !_imgFailed;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: widget.selected ? AppColors.gold : const Color(0xFF2A1810),
            width: widget.selected ? 2 : 1.5,
          ),
          boxShadow: widget.selected
              ? [BoxShadow(color: AppColors.gold.withOpacity(0.6), blurRadius: 16, spreadRadius: 1)]
              : [const BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(2, 3))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: useImage
              ? CachedNetworkImage(
                  imageUrl: AppConfig.cardImageUrl(imgFilename!),
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _imgFailed = true);
                    });
                    return _CssCard(display: display, bgColor: bgColor, width: widget.width, height: widget.height);
                  },
                )
              : _CssCard(display: display, bgColor: bgColor, width: widget.width, height: widget.height),
        ),
      ),
    );
  }
}

class _CssCard extends StatelessWidget {
  final ({String label, String emoji, String desc})? display;
  final Color bgColor;
  final double width;
  final double height;

  const _CssCard({this.display, required this.bgColor, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    if (display == null) return Container(color: bgColor);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgColor, Color.lerp(bgColor, Colors.black, 0.4)!],
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 0.5),
            ),
            child: Text(
              display!.label,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: AppColors.goldLight, fontFamily: 'Cairo'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          Text(display!.emoji, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28)),
          const Spacer(),
          Text(
            display!.desc,
            style: const TextStyle(fontSize: 7, color: AppColors.goldLight, fontFamily: 'Cairo'),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FaceDownCard extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback? onTap;

  const _FaceDownCard({required this.width, required this.height, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.crimson, width: 1.5),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A0E0A), Color(0xFF1A0805), Color(0xFF2A0E0A), Color(0xFF1A0805)],
            stops: [0, 0.5, 0.5, 1],
          ),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(2, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('🐱', style: TextStyle(fontSize: 26)),
            SizedBox(height: 4),
            Text('Exploding\nKittens', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9, color: AppColors.goldLight, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }
}
