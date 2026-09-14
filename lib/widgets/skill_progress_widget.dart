import 'package:flutter/material.dart';

/// Compact single-line progress indicator for all four skills.
/// Shows: 🎧33%  🗣️50%  📖100%  ✍️0%
class SkillProgressWidget extends StatelessWidget {
  final double listeningProgress;
  final double speakingProgress;
  final double readingProgress;
  final double writingProgress;
  final VoidCallback? onReadingTap;
  final VoidCallback? onWritingTap;

  const SkillProgressWidget({
    super.key,
    required this.listeningProgress,
    required this.speakingProgress,
    required this.readingProgress,
    required this.writingProgress,
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

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 2),
            Text(
              '$percent%',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _skillItem('🎧', listeningProgress),
        _skillItem('🗣️', speakingProgress),
        _skillItem('📖', readingProgress, onTap: onReadingTap),
        _skillItem('✍️', writingProgress, onTap: onWritingTap),
      ],
    );
  }
}
