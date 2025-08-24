import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/local_storage_service.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  unauthenticated,
  authenticated,
  loading,
  error,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final LocalStorageService _localStorage;
  StreamSubscription<User?>? _userSubscription;

  AuthNotifier(this._authService, this._localStorage) : super(AuthState()) {
    // Start listening to auth state changes immediately when the notifier is created
    _userSubscription = _authService.userStream.listen((user) {
      print('AuthNotifier: userStream event received: $user');
      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
        print('AuthNotifier: userStream - authenticated with user: ${user.email}');
        // Update local storage
        _localStorage.setUserId(user.id);
        _localStorage.setUserEmail(user.email ?? '');
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
        );
        print('AuthNotifier: userStream - unauthenticated');
        _localStorage.clearAuthData();
      }
    });

    // Check initial user state
    _checkInitialUser();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  Future<void> _checkInitialUser() async {
    state = state.copyWith(status: AuthStatus.loading);
    print('AuthNotifier: checking initial user state');
    
    try {
      final currentUser = _authService.getCurrentUser();
      print('AuthNotifier: current user from authService: $currentUser');
      if (currentUser != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: currentUser,
        );
        print('AuthNotifier: user authenticated, setting state to authenticated');
        // Update local storage
        await _localStorage.setUserId(currentUser.id);
        await _localStorage.setUserEmail(currentUser.email ?? '');
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        print('AuthNotifier: no user, setting state to unauthenticated');
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to check initial user: $e',
      );
      print('AuthNotifier: error during initial user check: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final response = await _authService.signInWithEmailAndPassword(email, password);
      if (response != null && response.user != null) {
        // Store user data in local storage
        await _localStorage.setUserId(response.user!.id);
        await _localStorage.setUserEmail(response.user!.email ?? '');
        
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      final response = await _authService.registerWithEmailAndPassword(email, password);
      if (response != null && response.user != null) {
        // Store user data in local storage
        await _localStorage.setUserId(response.user!.id);
        await _localStorage.setUserEmail(response.user!.email ?? '');
        
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(status: AuthStatus.loading);
    
    try {
      await _authService.signOut();
      await _localStorage.clearAuthData();
      
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to sign out: $e',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

// Providers
final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final localStorage = ref.watch(localStorageProvider);
  return AuthNotifier(authService, localStorage);
});