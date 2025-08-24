import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth-related storage
  Future<void> setAuthToken(String token) async {
    await _prefs?.setString('auth_token', token);
  }

  String? getAuthToken() {
    return _prefs?.getString('auth_token');
  }

  Future<void> setUserId(String userId) async {
    await _prefs?.setString('user_id', userId);
  }

  String? getUserId() {
    return _prefs?.getString('user_id');
  }

  Future<void> setUserEmail(String email) async {
    await _prefs?.setString('user_email', email);
  }

  String? getUserEmail() {
    return _prefs?.getString('user_email');
  }

  Future<void> setFirstLaunch(bool isFirstLaunch) async {
    await _prefs?.setBool('first_launch', isFirstLaunch);
  }

  bool isFirstLaunch() {
    return _prefs?.getBool('first_launch') ?? true;
  }

  Future<void> clearAuthData() async {
    await _prefs?.remove('auth_token');
    await _prefs?.remove('user_id');
    await _prefs?.remove('user_email');
  }

  // General storage methods
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}