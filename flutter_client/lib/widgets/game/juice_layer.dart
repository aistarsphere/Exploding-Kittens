import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class FloatingTextItem {
  final String text;
  final Color color;
  final bool big;
  final Offset position;
  final DateTime createdAt;

  FloatingTextItem({
    required this.text,
    required this.color,
    required this.big,
    required this.position,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class JuiceLayer extends StatefulWidget {
  const JuiceLayer({super.key});

  @override
  State<JuiceLayer> createState() => JuiceLayerState();

  // Global key pattern for imperative calls
  static JuiceLayerState? of(BuildContext context) {
    return context.findAncestorStateOfType<JuiceLayerState>();
  }
}

class JuiceLayerState extends State<JuiceLayer> {
  final List<FloatingTextItem> _items = [];

  void showText(String text, {Color color = AppColors.gold, bool big = false, Offset? position}) {
    setState(() {
      _items.add(FloatingTextItem(
        text: text,
        color: color,
        big: big,
        position: position ?? const Offset(0.5, 0.4),
      ));
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _items.removeWhere((i) => i.text == text));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: Stack(
        children: _items.map((item) => _FloatingTextWidget(item: item)).toList(),
      ),
    );
  }
}

class _FloatingTextWidget extends StatefulWidget {
  final FloatingTextItem item;
  const _FloatingTextWidget({required this.item});

  @override
  State<_FloatingTextWidget> createState() => __FloatingTextWidgetState();
}

class __FloatingTextWidgetState extends State<_FloatingTextWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;
  late Animation<double> _translateY;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300));
    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 55),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_ctrl);
    _translateY = Tween(begin: 0.0, end: -90.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.2), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
    ]).animate(_ctrl);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dx = size.width * widget.item.position.dx;
    final dy = size.height * widget.item.position.dy;

    return Positioned(
      left: dx - 100,
      top: dy,
      width: 200,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _translateY.value),
            child: Transform.scale(
              scale: _scale.value,
              child: Text(
                widget.item.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: widget.item.color,
                  fontSize: widget.item.big ? 36 : 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Cairo',
                  shadows: [
                    Shadow(color: widget.item.color.withOpacity(0.5), blurRadius: 16),
                    const Shadow(color: Colors.black87, blurRadius: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
