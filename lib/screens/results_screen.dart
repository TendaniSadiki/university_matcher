import 'package:flutter/material.dart';
import '../models/university_program.dart';
import '../services/matching_service.dart';
import '../constants/app_styles.dart';

class ResultsScreen extends StatefulWidget {
  final List<UniversityProgram> matchingPrograms;

  const ResultsScreen({super.key, required this.matchingPrograms});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String? selectedUniversity;
  String? selectedFaculty;
  final List<String> universities = [];
  final List<String> faculties = [];
  List<UniversityProgram> filteredPrograms = [];

  @override
  void initState() {
    super.initState();
    _extractFilterOptions();
    filteredPrograms = widget.matchingPrograms;
  }

  void _extractFilterOptions() {
    final Set<String> uniSet = {};
    final Set<String> facSet = {};

    for (var program in widget.matchingPrograms) {
      uniSet.add(program.universityName);
      facSet.add(program.facultyName);
    }

    universities.addAll(uniSet.toList()..sort());
    faculties.addAll(facSet.toList()..sort());
  }

  void _applyFilters() {
    setState(() {
      filteredPrograms = widget.matchingPrograms.where((program) {
        final matchesUniversity = selectedUniversity == null ||
            program.universityName == selectedUniversity;
        final matchesFaculty = selectedFaculty == null ||
            program.facultyName == selectedFaculty;
        return matchesUniversity && matchesFaculty;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      selectedUniversity = null;
      selectedFaculty = null;
      filteredPrograms = widget.matchingPrograms;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matching Programs'),
        backgroundColor: AppStyles.lesothoBlue,
        foregroundColor: AppStyles.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (selectedUniversity != null || selectedFaculty != null)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearFilters,
              tooltip: 'Clear all filters',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppStyles.lesothoGradient,
        ),
        child: Column(
          children: [
            _buildFilterBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: filteredPrograms.isEmpty
                    ? Center(
                        child: Text(
                          'No matching programs found with current filters.\nTry adjusting your filters or check your grades.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: AppStyles.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredPrograms.length,
                        itemBuilder: (context, index) {
                          final program = filteredPrograms[index];
                          return ProgramCard(program: program);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppStyles.white,
        borderRadius: AppStyles.borderRadiusBottom20,
        boxShadow: AppStyles.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedUniversity,
              decoration: AppStyles.textInputDecoration('University'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Universities')),
                ...universities.map((uni) => DropdownMenuItem(value: uni, child: Text(uni))),
              ],
              onChanged: (value) {
                setState(() {
                  selectedUniversity = value;
                  _applyFilters();
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedFaculty,
              decoration: AppStyles.textInputDecoration('Faculty'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Faculties')),
                ...faculties.map((fac) => DropdownMenuItem(value: fac, child: Text(fac))),
              ],
              onChanged: (value) {
                setState(() {
                  selectedFaculty = value;
                  _applyFilters();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProgramCard extends StatelessWidget {
  final UniversityProgram program;

  const ProgramCard({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: AppStyles.borderRadius16,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              program.name,
              style: AppStyles.programNameTextStyle,
            ),
            const SizedBox(height: 8),
            Text(
              program.universityName,
              style: AppStyles.universityNameTextStyle,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: AppStyles.grey600),
                const SizedBox(width: 4),
                Text(
                  'Duration: ${program.duration}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppStyles.grey700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Subject Requirements:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppStyles.lesothoBlue,
              ),
            ),
            const SizedBox(height: 8),
            ...program.requirements.map(
              (requirement) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: AppStyles.lesothoGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${requirement.subjectName}: Minimum ${requirement.minScore}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}