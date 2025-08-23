import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/local_storage_service.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/input_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_screen.dart';
import 'constants/app_styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure logging
  Logger.root.level = Level.ALL; // Log everything
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      print('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('Stack trace: ${record.stackTrace}');
    }
  });
  
  await dotenv.load(fileName: "assets/.env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );
  
  // Initialize local storage
  final localStorage = LocalStorageService();
  await localStorage.init();
  
  runApp(ProviderScope(
    overrides: [
      localStorageProvider.overrideWithValue(localStorage),
    ],
    child: const UniversityMatcherApp(),
  ));
}

class UniversityMatcherApp extends ConsumerStatefulWidget {
  const UniversityMatcherApp({super.key});

  @override
  ConsumerState<UniversityMatcherApp> createState() => _UniversityMatcherAppState();
}

class _UniversityMatcherAppState extends ConsumerState<UniversityMatcherApp> {
  @override
  void initState() {
    super.initState();
    // Initialize auth state when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final localStorage = ref.watch(localStorageProvider);

    print('UniversityMatcherApp build: authState.status = ${authState.status}');
    print('UniversityMatcherApp build: authState.user = ${authState.user?.email}');
    print('UniversityMatcherApp build: localStorage.isFirstLaunch = ${localStorage.isFirstLaunch()}');

    // Determine initial screen based on auth state and first launch
    Widget homeScreen;
    
    if (authState.status == AuthStatus.loading) {
      print('Showing loading screen');
      // Show loading screen while checking auth state
      homeScreen = const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (authState.status == AuthStatus.authenticated) {
      print('Showing MainAppScreen for authenticated user');
      // User is authenticated, show main app with navigation
      homeScreen = const MainAppScreen();
    } else {
      print('User not authenticated, checking first launch');
      // User is not authenticated, check if it's first launch
      if (localStorage.isFirstLaunch()) {
        print('Showing OnboardingScreen (first launch)');
        homeScreen = const OnboardingScreen();
      } else {
        print('Showing LoginScreen');
        homeScreen = const LoginScreen();
      }
    }

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
      home: homeScreen,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainAppScreen extends ConsumerStatefulWidget {
  const MainAppScreen({super.key});

  @override
  ConsumerState<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends ConsumerState<MainAppScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const InputScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Programs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}
