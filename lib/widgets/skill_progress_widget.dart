import 'package:flutter/material.dart';

/// Compact single-line progress indicator for all four skills.
/// Shows: 🎧33%  🗣️50%  📖100%  ✍️0%
class SkillProgressWidget extends StatelessWidget {
  final double listeningProgress;
  final double speakingProgress;
  final double readingProgress;
  final double writingProgress;
  final VoidCallback? onListeningTap;
  final VoidCallback? onSpeakingTap;
  final VoidCallback? onReadingTap;
  final VoidCallback? onWritingTap;

  const SkillProgressWidget({
    super.key,
    required this.listeningProgress,
    required this.speakingProgress,
    required this.readingProgress,
    required this.writingProgress,
    this.onListeningTap,
    this.onSpeakingTap,
    this.onReadingTap,
    this.onWritingTap,
  });

  Color _progressColor(double progress) {
    if (progress <= 0.0) return Colors.grey;
    if (progress < 0.5) return Colors.orange;
    if (progress < 1.0) return Colors.green;
    return Colors.blue;
  }

  Widget _skillItem(String icon, double progress, {VoidCallback? onTap}) {
    final percent = (progress * 100).round();
    final color = _progressColor(progress);

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: color.withValues(alpha: 0.15),
          splashColor: color.withValues(alpha: 0.2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3)),
              color: color.withValues(alpha: 0.06),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '$percent%',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _skillItem('📖', readingProgress, onTap: onReadingTap),
        _skillItem('🗣️', speakingProgress, onTap: onSpeakingTap),
        _skillItem('🎧', listeningProgress, onTap: onListeningTap),
        _skillItem('✍️', writingProgress, onTap: onWritingTap),
      ],
    );
  }
}
