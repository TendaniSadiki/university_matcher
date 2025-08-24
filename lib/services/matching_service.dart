import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_scores.dart';
import '../models/university_program.dart';

class MatchingService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final Logger _logger = Logger('MatchingService');

  // Method to find matching programs based on student scores using database function
  Future<List<UniversityProgram>> findMatchingPrograms(
    StudentScores studentScores,
    String userId,
  ) async {
    _logger.info('findMatchingPrograms called for userId: $userId');
    try {
      // First, get the learner ID from the learners table using the auth user ID
      final learnerId = await _getLearnerId(userId);
      _logger.info('Learner ID: $learnerId');

      // Then, save the student scores to the database
      await _saveStudentScores(studentScores, learnerId);
      _logger.info('Student scores saved for learnerId: $learnerId');

      try {
        // Call the PostgreSQL function match_programs
        _logger.info('Calling match_programs RPC for learnerId: $learnerId');
        final List<dynamic> data = await _supabase.rpc(
          'match_programs',
          params: {'learner_id': learnerId},
        );
        _logger.info('RPC Response: $data');

        if (data.isEmpty) {
          _logger.warning('No matching programs found for your scores.');
          throw Exception('No matching programs found for your scores.');
        }

        // Convert the response to List<UniversityProgram>
        return data
            .map((program) => UniversityProgram.fromMap(program))
            .toList();
      } catch (error) {
        _logger.severe('RPC Error: $error');
        if (error.toString().contains('PGRST204')) {
          _logger.severe(
            'Matching function not available. Please ensure the match_programs PostgreSQL function is deployed to your Supabase database.',
          );
          throw Exception(
            'Matching function not available. Please ensure the match_programs PostgreSQL function is deployed to your Supabase database.',
          );
        }
        rethrow;
      }
    } catch (e, stack) {
      _logger.severe('Error in findMatchingPrograms: $e', e, stack);
      rethrow;
    }
  }

  // Helper method to get the learner ID from the learners table using auth user ID
  // If not found, create a new learner record
  Future<String> _getLearnerId(String userId) async {
    _logger.info('_getLearnerId called for userId: $userId');
    try {
      final response = await _supabase
          .from('learners')
          .select('id')
          .eq('user_id', userId)
          .single();
      _logger.info('Learner found: $response');
      return response['id'] as String;
    } catch (e, stack) {
      _logger.warning(
        'Learner record not found for user $userId, creating one...',
      );
      _logger.warning('Error: $e', e, stack);
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
      _logger.info('New learner created: $insertResponse');
      return insertResponse['id'] as String;
    }
  }

  // Helper method to save student scores to learner_subjects table
  Future<void> _saveStudentScores(
    StudentScores studentScores,
    String learnerId,
  ) async {
    _logger.info('_saveStudentScores called for learnerId: $learnerId');
    _logger.info('Scores: ${studentScores.subjectScores}');
    try {
      // Delete existing scores for this learner
      final deleteResult = await _supabase
          .from('learner_subjects')
          .delete()
          .eq('learner_id', learnerId);
      _logger.info('Deleted existing scores: $deleteResult');

      // Insert new scores with grade_label (assuming LGCSE curriculum)
      for (var entry in studentScores.subjectScores.entries) {
        final subjectId = await _getSubjectId(entry.key);
        final gradeLabel = _getGradeLabel(entry.value);
        _logger.info(
          'Inserting score: learnerId=$learnerId, subject=${entry.key}, subjectId=$subjectId, gradeLabel=$gradeLabel',
        );
        final insertResult = await _supabase.from('learner_subjects').insert({
          'learner_id': learnerId,
          'subject_id': subjectId,
          'grade_label': gradeLabel, // Convert numerical score to grade label
        });
        _logger.info('Insert result: $insertResult');
      }
    } catch (e, stack) {
      _logger.severe('Error saving student scores: $e', e, stack);
      rethrow;
    }
  }

  // Helper method to get subject ID from subject name by querying the database with alias support
  Future<int> _getSubjectId(String subjectName) async {
    _logger.info('Fetching subject ID for: $subjectName');
    try {
      // First try exact name match in subjects table
      final response = await _supabase
          .from('subjects')
          .select('id')
          .eq('name', subjectName)
          .single();

      final subjectId = response['id'] as int;
      _logger.info('Subject ID for $subjectName: $subjectId');
      return subjectId;
    } catch (e) {
      // If exact match fails, try alias lookup
      _logger.warning('Exact subject not found, checking aliases for: $subjectName');
      try {
        final aliasResponse = await _supabase
            .from('subject_aliases')
            .select('subject_id')
            .eq('alias', subjectName)
            .single();

        final subjectId = aliasResponse['subject_id'] as int;
        _logger.info('Subject ID via alias for $subjectName: $subjectId');
        return subjectId;
      } catch (aliasError) {
        _logger.severe(
          'Subject not found: $subjectName. Please use exact subject names from the database.',
          aliasError,
        );
        throw Exception(
          'Subject not found: $subjectName. Please use exact subject names from the database.',
        );
      }
    }
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
      0: 'U',
    };

    final gradeLabel = gradeMap[score];
    if (gradeLabel == null) {
      _logger.warning(
        'Invalid score: $score. Score must be between 0-8 for LGCSE grading.',
      );
      throw Exception(
        'Invalid score: $score. Score must be between 0-8 for LGCSE grading.',
      );
    }
    return gradeLabel;
  }

  // Method to get all programs (for testing) - now from database
  Future<List<UniversityProgram>> getAllPrograms() async {
    _logger.info('getAllPrograms called');
    try {
      final List<dynamic> data = await _supabase.from('courses').select('''
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
      _logger.info('getAllPrograms response: $data');
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
    } catch (e, stack) {
      _logger.severe('Error getting all programs: $e', e, stack);
      rethrow;
    }
  }
}
