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
      return false;
    }
  }

  // Register with email and password
  Future<AuthResponse?> registerWithEmailAndPassword(String email, String password) async {
    try {
      AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      print('Error registering: $e');
      // Handle specific errors
      if (e.toString().contains('User already registered')) {
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

      await _supabase
          .from('learners')
          .update(profile.toMap())
          .eq('user_id', user.id);
    } catch (e) {
      print('Error updating learner profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
}