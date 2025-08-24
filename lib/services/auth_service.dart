import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/learner_profile.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse?> signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // Check if email is verified after successful sign-in
      if (response.user?.emailConfirmedAt == null) {
        await _supabase.auth.signOut(); // Sign out since email is not verified
        throw Exception('Please verify your email address before signing in. Check your inbox for the verification link.');
      }
      
      return response;
    } catch (e) {
      print('Error signing in: $e');
      // Handle specific errors
      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('Invalid email or password. Please try again.');
      } else if (e.toString().contains('verify your email')) {
        rethrow; // Re-throw the email verification error
      }
      throw Exception('Failed to sign in. Please try again.');
    }
  }

  // Check if user exists by email (direct Supabase auth check)
  Future<bool> checkUserExists(String email) async {
    try {
      // Use Supabase auth admin API to check if user exists
      final users = await _supabase.auth.admin.listUsers();
      return users.any((user) => user.email == email);
    } catch (e) {
      print('Error checking user existence: $e');
      // Fallback: try to sign in with dummy password to check if user exists
      try {
        await _supabase.auth.signInWithPassword(
          email: email,
          password: 'dummy_password_12345', // This will fail if user exists but wrong password
        );
        return true; // This line should never be reached if password is wrong
      } catch (signInError) {
        if (signInError.toString().contains('Invalid login credentials')) {
          return true; // User exists but wrong password
        }
        return false; // User doesn't exist or other error
      }
    }
  }

  // Register with email and password with better validation
  Future<AuthResponse?> registerWithEmailAndPassword(String email, String password) async {
    try {
      // First check if user already exists using a more reliable method
      final userExists = await checkUserExists(email);
      if (userExists) {
        throw Exception('Email is already in use. Please use a different email or sign in.');
      }

      AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      print('Error registering: $e');
      // Handle specific errors
      if (e.toString().contains('Email is already in use')) {
        rethrow; // Re-throw our custom exception
      } else if (e.toString().contains('User already registered')) {
        throw Exception('Email is already in use. Please use a different email or sign in.');
      }
      throw Exception('Failed to register. Please try again.');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  // Stream of user authentication state changes
  Stream<User?> get userStream {
    return _supabase.auth.onAuthStateChange.map((event) => event.session?.user);
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    final user = _supabase.auth.currentUser;
    if (user != null && user.emailConfirmedAt == null) {
      // Supabase automatically sends verification email on signup
      // You can trigger resend if needed, but typically handled during signup
    }
  }

  // Check if email is verified
  Future<bool> checkEmailVerification() async {
    await _supabase.auth.refreshSession();
    return _supabase.auth.currentUser?.emailConfirmedAt != null;
  }

  // Get learner profile from database
  Future<LearnerProfile?> getLearnerProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('learners')
          .select()
          .eq('user_id', user.id)
          .single();

      return LearnerProfile.fromMap(response);
    } catch (e) {
      print('Error fetching learner profile: $e');
      return null;
    }
  }

  // Update learner profile in database
  Future<void> updateLearnerProfile(LearnerProfile profile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Create update data without the id field since we're updating by user_id
      final updateData = {
        'full_name': profile.fullName,
        'school_name': profile.schoolName,
        'grade': profile.grade,
        'intake_year': profile.intakeYear,
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('Updating learner profile for user: ${user.id}');
      print('Update data: $updateData');

      final response = await _supabase
          .from('learners')
          .update(updateData)
          .eq('user_id', user.id);

      print('Profile update response: $response');
    } catch (e) {
      print('Error updating learner profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
}