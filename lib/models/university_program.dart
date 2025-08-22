class UniversityProgram {
  final String id;
  final String facultyId;
  final String facultyName;
  final String universityId;
  final String universityName;
  final String name;
  final String code;
  final String? duration;
  final String? description;
  final int totalApsRequired;
  final List<CourseRequirement> requirements;

  UniversityProgram({
    required this.id,
    required this.facultyId,
    required this.facultyName,
    required this.universityId,
    required this.universityName,
    required this.name,
    required this.code,
    this.duration,
    this.description,
    required this.totalApsRequired,
    required this.requirements,
  });

  // Convert to map for easy serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'faculty_id': facultyId,
      'faculty_name': facultyName,
      'university_id': universityId,
      'university_name': universityName,
      'name': name,
      'code': code,
      'duration': duration,
      'description': description,
      'total_aps_required': totalApsRequired,
      'requirements': requirements.map((req) => req.toMap()).toList(),
    };
  }

  // Create from map for deserialization
  factory UniversityProgram.fromMap(Map<String, dynamic> map) {
    return UniversityProgram(
      id: map['id'] ?? '',
      facultyId: map['faculty_id'] ?? '',
      facultyName: map['faculty_name'] ?? '',
      universityId: map['university_id'] ?? '',
      universityName: map['university_name'] ?? '',
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      duration: map['duration'],
      description: map['description'],
      totalApsRequired: map['total_aps_required'] ?? 0,
      requirements: (map['requirements'] as List<dynamic>?)
          ?.map((req) => CourseRequirement.fromMap(req))
          .toList() ??
          [],
    );
  }
}

class CourseRequirement {
  final String subjectId;
  final String subjectName;
  final int minScore;
  final String explanation;

  CourseRequirement({
    required this.subjectId,
    required this.subjectName,
    required this.minScore,
    required this.explanation,
  });

  Map<String, dynamic> toMap() {
    return {
      'subject_id': subjectId,
      'subject_name': subjectName,
      'min_score': minScore,
      'explanation': explanation,
    };
  }

  factory CourseRequirement.fromMap(Map<String, dynamic> map) {
    return CourseRequirement(
      subjectId: map['subject_id'] ?? '',
      subjectName: map['subject_name'] ?? '',
      minScore: map['min_score'] ?? 0,
      explanation: map['explanation'] ?? '',
    );
  }
}