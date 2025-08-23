import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../models/learner_profile.dart';
import '../widgets/error_dialog.dart';
import '../constants/app_styles.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _intakeYearController = TextEditingController();
  String? _selectedGrade;
  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _gradeOptions = ['LGCSE', 'ASC'];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final authService = ref.read(authServiceProvider);
      final profile = await authService.getLearnerProfile();
      
      if (profile != null) {
        _fullNameController.text = profile.fullName;
        _schoolNameController.text = profile.schoolName ?? '';
        _intakeYearController.text = profile.intakeYear?.toString() ?? '';
        _selectedGrade = profile.grade;
      } else {
        // If no profile exists, set default values
        final user = ref.read(authServiceProvider).getCurrentUser();
        _fullNameController.text = user?.email?.split('@').first ?? 'User';
        _selectedGrade = 'LGCSE';
      }
    } catch (e) {
      ErrorDialog.show(
        context: context,
        title: 'Error',
        message: 'Failed to load profile: $e',
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      try {
        final authService = ref.read(authServiceProvider);
        final user = authService.getCurrentUser();
        
        if (user == null) {
          throw Exception('User not authenticated');
        }

        final profile = LearnerProfile(
          id: '', // Will be set by the database
          userId: user.id,
          fullName: _fullNameController.text.trim(),
          schoolName: _schoolNameController.text.trim().isEmpty 
              ? null 
              : _schoolNameController.text.trim(),
          grade: _selectedGrade!,
          intakeYear: _intakeYearController.text.trim().isEmpty
              ? null
              : int.tryParse(_intakeYearController.text.trim()),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await authService.updateLearnerProfile(profile);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      } catch (e) {
        ErrorDialog.show(
          context: context,
          title: 'Error',
          message: 'Failed to update profile: $e',
        );
      } finally {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(authNotifierProvider.notifier).signOut();
        // Navigation will be handled by the auth state changes in main.dart
      } catch (e) {
        ErrorDialog.show(
          context: context,
          title: 'Logout Failed',
          message: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Icon
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppStyles.lesothoBlue,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Full Name Field
              TextFormField(
                controller: _fullNameController,
                decoration: AppStyles.textInputDecoration('Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // School Name Field
              TextFormField(
                controller: _schoolNameController,
                decoration: AppStyles.textInputDecoration('School Name (optional)'),
              ),
              const SizedBox(height: 16),

              // Grade Dropdown
              DropdownButtonFormField<String>(
                value: _selectedGrade,
                decoration: AppStyles.textInputDecoration('Curriculum'),
                items: _gradeOptions.map((String grade) {
                  return DropdownMenuItem<String>(
                    value: grade,
                    child: Text(grade),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGrade = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your curriculum';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Intake Year Field
              TextFormField(
                controller: _intakeYearController,
                decoration: AppStyles.textInputDecoration('Intake Year (optional)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final year = int.tryParse(value);
                    if (year == null || year < 2000 || year > 2100) {
                      return 'Please enter a valid year';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Save Button
              _isSaving
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      style: AppStyles.primaryButtonStyle(context),
                      child: const Text('Save Profile'),
                    ),
              const SizedBox(height: 16),

              // Logout Button
              OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _schoolNameController.dispose();
    _intakeYearController.dispose();
    super.dispose();
  }
}