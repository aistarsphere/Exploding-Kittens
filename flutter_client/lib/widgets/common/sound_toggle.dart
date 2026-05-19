import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sound_provider.dart';

class SoundToggle extends ConsumerWidget {
  const SoundToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = ref.watch(soundMutedProvider);
    return IconButton(
      onPressed: () => ref.read(soundMutedProvider.notifier).toggle(),
      icon: Icon(
        muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
        color: Colors.white70,
        size: 22,
      ),
      tooltip: muted ? 'Unmute' : 'Mute',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}
