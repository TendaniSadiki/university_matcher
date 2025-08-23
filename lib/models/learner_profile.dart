class LearnerProfile {
  final String id;
  final String userId;
  final String fullName;
  final String? schoolName;
  final String grade;
  final int? intakeYear;
  final DateTime createdAt;
  final DateTime updatedAt;

  LearnerProfile({
    required this.id,
    required this.userId,
    required this.fullName,
    this.schoolName,
    required this.grade,
    this.intakeYear,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LearnerProfile.fromMap(Map<String, dynamic> map) {
    return LearnerProfile(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      fullName: map['full_name'] as String,
      schoolName: map['school_name'] as String?,
      grade: map['grade'] as String,
      intakeYear: map['intake_year'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'school_name': schoolName,
      'grade': grade,
      'intake_year': intakeYear,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  LearnerProfile copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? schoolName,
    String? grade,
    int? intakeYear,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LearnerProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      schoolName: schoolName ?? this.schoolName,
      grade: grade ?? this.grade,
      intakeYear: intakeYear ?? this.intakeYear,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}