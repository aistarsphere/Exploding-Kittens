import 'package:flutter/material.dart';
import '../../models/game_state.dart';
import '../../theme/app_theme.dart';

class GameLog extends StatefulWidget {
  final List<LogEntry> log;

  const GameLog({super.key, required this.log});

  @override
  State<GameLog> createState() => _GameLogState();
}

class _GameLogState extends State<GameLog> {
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(GameLog old) {
    super.didUpdateWidget(old);
    if (widget.log.length != old.log.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.log.length > 30
        ? widget.log.sublist(widget.log.length - 30)
        : widget.log;

    return Container(
      constraints: const BoxConstraints(maxHeight: 130),
      color: AppColors.bgDeep.withOpacity(0.7),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        itemCount: entries.length,
        itemBuilder: (ctx, i) {
          final isLast = i == entries.length - 1;
          return Text(
            entries[i].text,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'Cairo',
              color: isLast ? AppColors.gold : AppColors.goldDim.withOpacity(0.7),
              fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }
}
