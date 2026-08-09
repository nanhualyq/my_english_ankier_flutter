// Widget tests for the homepage.
// Note: Database-dependent tests require sqflite_common_ffi setup.
// This file contains basic structure tests only.

import 'package:flutter_test/flutter_test.dart';

import 'package:my_english_ankier_flutter/widgets/skill_progress_widget.dart';

void main() {
  test('SkillProgressWidget creates correctly', () {
    // Simple instantiation test
    const widget = SkillProgressWidget(
      listeningProgress: 0.33,
      speakingProgress: 0.50,
      readingProgress: 1.0,
      writingProgress: 0.0,
    );
    
    expect(widget.listeningProgress, 0.33);
    expect(widget.speakingProgress, 0.50);
    expect(widget.readingProgress, 1.0);
    expect(widget.writingProgress, 0.0);
  });

  test('SkillProgressWidget handles zero progress', () {
    const widget = SkillProgressWidget(
      listeningProgress: 0.0,
      speakingProgress: 0.0,
      readingProgress: 0.0,
      writingProgress: 0.0,
    );
    
    expect(widget.listeningProgress, 0.0);
    expect(widget.speakingProgress, 0.0);
    expect(widget.readingProgress, 0.0);
    expect(widget.writingProgress, 0.0);
  });
}
