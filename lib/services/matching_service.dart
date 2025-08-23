import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_scores.dart';
import '../models/university_program.dart';

class MatchingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Method to find matching programs based on student scores using database function
  Future<List<UniversityProgram>> findMatchingPrograms(
    StudentScores studentScores,
    String userId,
  ) async {
    try {
      // First, get the learner ID from the learners table using the auth user ID
      final learnerId = await _getLearnerId(userId);
      
      // Then, save the student scores to the database
      await _saveStudentScores(studentScores, learnerId);

      try {
        // Call the PostgreSQL function match_programs
        final List<dynamic> data = await _supabase.rpc(
          'match_programs',
          params: {'learner_id': learnerId},
        );

        if (data.isEmpty) {
          throw Exception('No matching programs found for your scores.');
        }

        // Convert the response to List<UniversityProgram>
        return data.map((program) => UniversityProgram.fromMap(program)).toList();
      } catch (error) {
        print('RPC Error: $error');
        if (error.toString().contains('PGRST204')) {
          throw Exception(
            'Matching function not available. Please ensure the match_programs PostgreSQL function is deployed to your Supabase database.'
          );
        }
        rethrow;
      }
    } catch (e) {
      print('Error in findMatchingPrograms: $e');
      rethrow;
    }
  }

  // Helper method to get the learner ID from the learners table using auth user ID
  // If not found, create a new learner record
  Future<String> _getLearnerId(String userId) async {
    try {
      final response = await _supabase
          .from('learners')
          .select('id')
          .eq('user_id', userId)
          .single();
      
      return response['id'] as String;
    } catch (e) {
      print('Learner record not found for user $userId, creating one...');
      // Insert a new learner record
      final insertResponse = await _supabase
          .from('learners')
          .insert({
            'user_id': userId,
            'full_name': 'User', // Default name, can be updated later
            'grade': 'LGCSE', // Default curriculum
          })
          .select('id')
          .single();
      
      return insertResponse['id'] as String;
    }
  }

  // Helper method to save student scores to learner_subjects table
  Future<void> _saveStudentScores(StudentScores studentScores, String learnerId) async {
    try {
      // Delete existing scores for this learner
      await _supabase
          .from('learner_subjects')
          .delete()
          .eq('learner_id', learnerId);

      // Insert new scores with grade_label (assuming LGCSE curriculum)
      for (var entry in studentScores.subjectScores.entries) {
        await _supabase.from('learner_subjects').insert({
          'learner_id': learnerId,
          'subject_id': _getSubjectId(entry.key),
          'grade_label': _getGradeLabel(entry.value), // Convert numerical score to grade label
        });
      }
    } catch (e) {
      print('Error saving student scores: $e');
      rethrow;
    }
  }

  // Helper method to get subject ID from subject name based on your database schema
  int _getSubjectId(String subjectName) {
    // Mapping based on your database subjects table (IDs from sample data)
    final Map<String, int> subjectMap = {
      'Mathematics': 1,
      'English': 2,
      'Physics': 3,
      'Chemistry': 4,
      'Biology': 5,
      'History': 6,
      'Geography': 7,
      'Economics': 8,
      'Accounting': 9,
      'Information Technology': 10,
      'Art': 11,
      'Sesotho': 12,
      'Food and Nutrition': 13,
      'Physical Science': 14,
    };
    
    final subjectId = subjectMap[subjectName];
    if (subjectId == null) {
      throw Exception('Subject not found: $subjectName. Please use exact subject names from the database.');
    }
    return subjectId;
  }

  // Helper method to convert numerical score to LGCSE grade label
  String _getGradeLabel(int score) {
    // Map numerical score to LGCSE grade labels based on your database grade_scale
    final Map<int, String> gradeMap = {
      8: 'A*',
      7: 'A',
      6: 'B',
      5: 'C',
      4: 'D',
      3: 'E',
      2: 'F',
      1: 'G',
      0: 'U'
    };
    
    final gradeLabel = gradeMap[score];
    if (gradeLabel == null) {
      throw Exception('Invalid score: $score. Score must be between 0-8 for LGCSE grading.');
    }
    return gradeLabel;
  }

  // Method to get all programs (for testing) - now from database
  Future<List<UniversityProgram>> getAllPrograms() async {
    try {
      final List<dynamic> data = await _supabase
          .from('courses')
          .select('''
            courses.id,
            faculty_id,
            faculties(name),
            university_id,
            universities(name),
            courses.name,
            code,
            duration_years,
            notes,
            course_requirements(rule_json)
          ''');
      return data.map((program) {
        // Extract min_aggregate_points from rule_json if available
        final ruleJson = program['course_requirements']?[0]?['rule_json'] ?? {};
        final minAggregatePoints = ruleJson['min_aggregate_points'] ?? 0;
        
        return UniversityProgram.fromMap({
          'id': program['id'],
          'faculty_id': program['faculty_id'],
          'faculty_name': program['faculties']['name'],
          'university_id': program['university_id'],
          'university_name': program['universities']['name'],
          'name': program['name'],
          'code': program['code'],
          'duration': '${program['duration_years']} years',
          'description': program['notes'],
          'total_aps_required': minAggregatePoints,
          'requirements': ruleJson,
        });
      }).toList();
    } catch (e) {
      print('Error getting all programs: $e');
      rethrow;
    }
  }
}
