enum SkillType {
  listening,
  speaking,
  reading,
  writing,
}

extension SkillTypeExtension on SkillType {
  String get name {
    switch (this) {
      case SkillType.listening:
        return 'listening';
      case SkillType.speaking:
        return 'speaking';
      case SkillType.reading:
        return 'reading';
      case SkillType.writing:
        return 'writing';
    }
  }

  String get displayName {
    switch (this) {
      case SkillType.listening:
        return 'Listening';
      case SkillType.speaking:
        return 'Speaking';
      case SkillType.reading:
        return 'Reading';
      case SkillType.writing:
        return 'Writing';
    }
  }

  String get icon {
    switch (this) {
      case SkillType.listening:
        return '🎧';
      case SkillType.speaking:
        return '🗣️';
      case SkillType.reading:
        return '📖';
      case SkillType.writing:
        return '✍️';
    }
  }

  static SkillType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'listening':
        return SkillType.listening;
      case 'speaking':
        return SkillType.speaking;
      case 'reading':
        return SkillType.reading;
      case 'writing':
        return SkillType.writing;
      default:
        throw ArgumentError('Invalid skill type: $value');
    }
  }
}