class SkillProgress {
  final int? id;
  final int articleId;
  final String skillType;
  final int lastLinePosition;

  SkillProgress({
    this.id,
    required this.articleId,
    required this.skillType,
    this.lastLinePosition = 0,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'article_id': articleId,
      'skill_type': skillType,
      'last_line_position': lastLinePosition,
    };
  }

  // Create from Map from database
  factory SkillProgress.fromMap(Map<String, dynamic> map) {
    return SkillProgress(
      id: map['id'] as int?,
      articleId: map['article_id'] as int,
      skillType: map['skill_type'] as String,
      lastLinePosition: map['last_line_position'] as int? ?? 0,
    );
  }

  // Create a copy with updated fields
  SkillProgress copyWith({
    int? id,
    int? articleId,
    String? skillType,
    int? lastLinePosition,
  }) {
    return SkillProgress(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      skillType: skillType ?? this.skillType,
      lastLinePosition: lastLinePosition ?? this.lastLinePosition,
    );
  }

  // Calculate progress percentage based on total lines
  double calculateProgress(int totalLines) {
    if (totalLines <= 0) return 0.0;
    return (lastLinePosition / totalLines).clamp(0.0, 1.0);
  }

  @override
  String toString() {
    return 'SkillProgress(id: $id, articleId: $articleId, skillType: $skillType, lastLinePosition: $lastLinePosition)';
  }
}