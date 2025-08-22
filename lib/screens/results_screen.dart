import 'package:flutter/material.dart';
import '../models/university_program.dart';
import '../services/matching_service.dart';

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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
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
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: filteredPrograms.isEmpty
                  ? const Center(
                      child: Text(
                        'No matching programs found with current filters.\nTry adjusting your filters or check your grades.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.grey),
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
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: selectedUniversity,
              decoration: const InputDecoration(
                labelText: 'University',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
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
              decoration: const InputDecoration(
                labelText: 'Faculty',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              program.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003366),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              program.universityName,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: ${program.duration}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text(
              'Subject Requirements:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ...program.requirements.map(
              (requirement) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text(
                  '• ${requirement.subjectName}: Minimum ${requirement.minScore}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}