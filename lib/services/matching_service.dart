import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_scores.dart';
import '../models/university_program.dart';

class MatchingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Method to find matching programs based on student scores using database function
  Future<List<UniversityProgram>> findMatchingPrograms(
    StudentScores studentScores,
    String learnerId,
  ) async {
    try {
      // First, save the student scores to the database
      await _saveStudentScores(studentScores, learnerId);

      // Call the PostgreSQL function match_programs
      final List<dynamic> data = await _supabase.rpc(
        'match_programs',
        params: {'learner_id': learnerId},
      );

      // Convert the response to List<UniversityProgram>
      return data.map((program) => UniversityProgram.fromMap(program)).toList();
    } catch (e) {
      print('Error in findMatchingPrograms: $e');
      rethrow;
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

      // Insert new scores
      for (var entry in studentScores.subjectScores.entries) {
        await _supabase.from('learner_subjects').insert({
          'learner_id': learnerId,
          'subject_id': _getSubjectId(entry.key), // Need to map subject name to ID
          'score': entry.value,
        });
      }
    } catch (e) {
      print('Error saving student scores: $e');
      rethrow;
    }
  }

  // Helper method to get subject ID from subject name (simplified for now)
  String _getSubjectId(String subjectName) {
    // This is a temporary mapping - should be replaced with actual subject ID lookup
    final Map<String, String> subjectMap = {
      'Mathematics': 'math',
      'English': 'eng',
      'Science': 'sci',
      'Sesotho': 'ses',
      'History': 'hist',
      'Geography': 'geo',
      'Accounting': 'acc',
      'Business Studies': 'bus',
      'Economics': 'econ',
      'Physics': 'phy',
      'Chemistry': 'chem',
      'Biology': 'bio',
    };
    return subjectMap[subjectName] ?? subjectName.toLowerCase();
  }

  // Method to get all programs (for testing) - now from database
  Future<List<UniversityProgram>> getAllPrograms() async {
    try {
      final List<dynamic> data = await _supabase
          .from('courses')
          .select('''
            id,
            faculty_id,
            faculties(name),
            university_id,
            universities(name),
            name,
            code,
            duration,
            description,
            total_aps_required,
            requirements
          ''');
      return data.map((program) => UniversityProgram.fromMap({
            'id': program['id'],
            'faculty_id': program['faculty_id'],
            'faculty_name': program['faculties']['name'],
            'university_id': program['university_id'],
            'university_name': program['universities']['name'],
            'name': program['name'],
            'code': program['code'],
            'duration': program['duration'],
            'description': program['description'],
            'total_aps_required': program['total_aps_required'],
            'requirements': program['requirements'],
          })).toList();
    } catch (e) {
      print('Error getting all programs: $e');
      rethrow;
    }
  }
}
