class StudentScores {
  final Map<String, int> subjectScores; // Map of subject to numerical score

  StudentScores({required this.subjectScores});

  // Method to check if student meets minimum score requirement for a subject
  bool meetsRequirement(String subject, int minScore) {
    final studentScore = subjectScores[subject];
    if (studentScore == null) return false;
    return studentScore >= minScore;
  }

  // Calculate total APS score (sum of all subject scores)
  int calculateTotalAPS() {
    return subjectScores.values.fold(0, (sum, score) => sum + score);
  }

  // Convert to map for easy serialization
  Map<String, dynamic> toMap() {
    return {'subjectScores': subjectScores};
  }

  // Create from map for deserialization
  factory StudentScores.fromMap(Map<String, dynamic> map) {
    return StudentScores(
      subjectScores: Map<String, int>.from(map['subjectScores']),
    );
  }
}