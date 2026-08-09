class Article {
  final int? id;
  final String title;
  final String content;
  final String? translatedContent;
  final String? url;
  final DateTime createdAt;
  final DateTime updatedAt;

  Article({
    this.id,
    required this.title,
    required this.content,
    this.translatedContent,
    this.url,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'translated_content': translatedContent,
      'url': url,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  // Create from Map from database
  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'] as int?,
      title: map['title'] as String,
      content: map['content'] as String,
      translatedContent: map['translated_content'] as String?,
      url: map['url'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  // Create a copy with updated fields
  Article copyWith({
    int? id,
    String? title,
    String? content,
    String? translatedContent,
    String? url,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      translatedContent: translatedContent ?? this.translatedContent,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get total lines in content
  int get totalLines {
    if (content.isEmpty) return 0;
    return content.split('\n').length;
  }

  @override
  String toString() {
    return 'Article(id: $id, title: $title, totalLines: $totalLines)';
  }
}