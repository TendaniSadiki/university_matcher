import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student_scores.dart';
import '../services/matching_service.dart';
import '../services/auth_service.dart';
import 'results_screen.dart';
import '../constants/app_styles.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final Map<String, int?> _subjectScores = {};
  final List<String> _lgcseSubjects = [
    'Mathematics',
    'English',
    'Physics',
    'Chemistry',
    'Biology',
    'History',
    'Geography',
    'Economics',
    'Accounting',
    'Information Technology',
    'Art',
    'Sesotho',
    'Food and Nutrition',
    'Physical Science'
  ];
  final MatchingService _matchingService = MatchingService();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _matchPrograms() async {
    // Validate that at least one subject has a score
    final hasScores = _subjectScores.values.any((score) => score != null && score! > 0);
    
    if (!hasScores) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one valid subject score')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current user
      final user = _authService.getCurrentUser();
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to continue')),
        );
        return;
      }

      // Create student scores object
      final validScores = Map<String, int>.fromEntries(
        _subjectScores.entries
            .where((entry) => entry.value != null && entry.value! > 0)
            .map((entry) => MapEntry(entry.key, entry.value!))
      );
      
      final studentScores = StudentScores(subjectScores: validScores);

      // Find matching programs
      final matchingPrograms = await _matchingService.findMatchingPrograms(studentScores, user.id);
      
      // Navigate to results screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(matchingPrograms: matchingPrograms),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error matching programs: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.signOut();
      // Navigate to root which should be the login screen
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesotho University Matcher'),
        backgroundColor: AppStyles.lesothoBlue,
        foregroundColor: AppStyles.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppStyles.lesothoGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your LGCSE Grades',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppStyles.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select the grade you achieved for each subject. Leave blank if you did not take the subject.',
                style: TextStyle(color: AppStyles.white70),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: AppStyles.whiteCardDecoration,
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemCount: _lgcseSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = _lgcseSubjects[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                subject,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: AppStyles.textInputDecoration('Score'),
                                onChanged: (value) {
                                  setState(() {
                                    if (value.isEmpty) {
                                      _subjectScores[subject] = null;
                                    } else {
                                      _subjectScores[subject] = int.tryParse(value);
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _matchPrograms,
                        style: AppStyles.secondaryButtonStyle(context),
                        child: const Text(
                          'Find Matching Programs',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}