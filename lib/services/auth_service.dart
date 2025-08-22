import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse?> signInWithEmailAndPassword(String email, String password) async {
    try {
      AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      print('Error signing in: $e');
      return null;
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
      return null;
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
}