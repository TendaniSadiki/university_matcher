import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/auth_service.dart';
import 'services/logging_service.dart';
import 'screens/login_screen.dart';
import 'screens/input_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );
  
  runApp(const UniversityMatcherApp());
}

class UniversityMatcherApp extends StatefulWidget {
  const UniversityMatcherApp({super.key});

  @override
  State<UniversityMatcherApp> createState() => _UniversityMatcherAppState();
}

class _UniversityMatcherAppState extends State<UniversityMatcherApp> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lesotho University Matcher',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003366), // Lesotho blue color
          primary: const Color(0xFF003366),
          secondary: const Color(0xFF009933), // Lesotho green color
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: _authService.userStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const InputScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
