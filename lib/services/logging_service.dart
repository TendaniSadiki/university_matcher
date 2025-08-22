import 'package:supabase_flutter/supabase_flutter.dart';

class LoggingService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Start a new session
  Future<String?> startSession({String? ipAddress, String? userAgent}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('sessions')
          .insert({
            'learner_id': user.id,
            'ip_address': ipAddress,
            'user_agent': userAgent,
          })
          .select('id')
          .single();

      return response['id'] as String?;
    } catch (e) {
      print('Error starting session: $e');
      return null;
    }
  }

  // End a session
  Future<void> endSession(String sessionId) async {
    try {
      await _supabase
          .from('sessions')
          .update({'ended_at': DateTime.now().toIso8601String()})
          .eq('id', sessionId);
    } catch (e) {
      print('Error ending session: $e');
    }
  }

  // Log an event
  Future<void> logEvent({
    required String sessionId,
    required String eventType,
    Map<String, dynamic>? eventData,
  }) async {
    try {
      await _supabase
          .from('events')
          .insert({
            'session_id': sessionId,
            'event_type': eventType,
            'event_data': eventData,
          });
    } catch (e) {
      print('Error logging event: $e');
    }
  }

  // Log authentication events
  Future<void> logAuthEvent(String eventType, {Map<String, dynamic>? data}) async {
    try {
      final sessionId = await startSession();
      if (sessionId != null) {
        await logEvent(
          sessionId: sessionId,
          eventType: eventType,
          eventData: data,
        );
        await endSession(sessionId);
      }
    } catch (e) {
      print('Error logging auth event: $e');
    }
  }

  // Log screen view events
  Future<void> logScreenView(String screenName, {Map<String, dynamic>? data}) async {
    try {
      final sessionId = await startSession();
      if (sessionId != null) {
        await logEvent(
          sessionId: sessionId,
          eventType: 'screen_view',
          eventData: {
            'screen_name': screenName,
            ...?data,
          },
        );
        await endSession(sessionId);
      }
    } catch (e) {
      print('Error logging screen view: $e');
    }
  }

  // Log matching results event
  Future<void> logMatchingResults({
    required int totalPrograms,
    required int eligiblePrograms,
    required int totalAps,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final sessionId = await startSession();
      if (sessionId != null) {
        await logEvent(
          sessionId: sessionId,
          eventType: 'matching_results',
          eventData: {
            'total_programs': totalPrograms,
            'eligible_programs': eligiblePrograms,
            'total_aps': totalAps,
            ...?additionalData,
          },
        );
        await endSession(sessionId);
      }
    } catch (e) {
      print('Error logging matching results: $e');
    }
  }
}