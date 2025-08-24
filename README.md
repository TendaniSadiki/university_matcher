# Lesotho University Matcher - Admissions Smart Calculator

A Flutter-based mobile application that matches Lesotho learners with university programs based on their LGCSE/ASC grades. The app provides personalized program recommendations with clear eligibility explanations for National University of Lesotho (NUL) and Limkokwing University.

## 🚀 Features

- **User Authentication**: Secure sign-up/sign-in with email verification via Supabase Auth
- **Profile Management**: Complete learner profile with personal information, school, and academic details
- **Smart Matching Engine**: PostgreSQL-based matching algorithm that evaluates program eligibility
- **Real-time Results**: Instant program recommendations with eligibility status (Eligible, Borderline, Not Eligible)
- **Detailed Explanations**: Clear reasons for eligibility decisions with subject-specific requirements
- **Responsive UI**: Mobile-first design with Lesotho-themed colors and intuitive navigation
- **Persistent Sessions**: Authentication state preserved across app restarts using SharedPreferences

## 🛠 Technology Stack

- **Frontend**: Flutter 3.0+ (Dart)
- **Backend**: Supabase (PostgreSQL, Authentication, Row Level Security)
- **Database**: PostgreSQL with comprehensive university data schema
- **State Management**: Riverpod for reactive state management
- **Local Storage**: SharedPreferences for session persistence
- **Styling**: Custom Lesotho theme with blue (#003366) and green (#009933) colors

## 📋 Prerequisites

- Flutter SDK 3.0+
- Dart SDK 2.17+
- Supabase account
- Android Studio or VS Code with Flutter extension

## ⚡ Quick Setup

### 1. Supabase Project Setup

1. Create a new project at [supabase.com](https://supabase.com)
2. Get your project URL and anon key from Settings > API

#### Install Supabase CLI (Optional for Local Development):
If you plan to use Supabase CLI for local development or database management, install it via npm:

```bash
npm install -g supabase
```

#### For Local Development:
Create a `.env` file in the `assets` directory:

```bash
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
```

**Important**: The `.env` file contains sensitive keys and should not be committed to GitHub. Ensure it is added to `.gitignore`.

#### For GitHub Actions (CI/CD):
Set up secrets in your GitHub repository:

1. Go to your repository Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add these secrets:
   - Name: `SUPABASE_URL`, Secret: `your_project_url`
   - Name: `SUPABASE_ANON_KEY`, Secret: `your_anon_key`

These secrets will be available to GitHub Actions workflows without exposing them in code.

### 2. Database Setup

Run the production database schema:

1. Navigate to Supabase SQL Editor
2. Execute the complete schema:  `supabase/scripts/001production_schema.sql`
                                 `supabase/scripts/002populate_data.sql`
                                 `supabase/scripts/003fix_match_function.sql`
3. Verify all tables and functions are created successfully

### 3. Flutter App Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Run the application:
```bash
flutter run
```

## 🗄 Database Schema

The database includes these key tables:

- `universities` - Institutional data (NUL, Limkokwing)
- `faculties` - Academic faculties per university  
- `courses` - Degree programs with requirements
- `subjects` - LGCSE/ASC subjects
- `subject_aliases` - Common subject name variations
- `grade_scale` - Grade-to-points mapping for LGCSE/ASC
- `course_requirements` - JSON rules for program eligibility
- `learners` - User profiles linked to Supabase auth
- `learner_subjects` - User's subjects and grades
- `matches` - Matching results and explanations

## 🎯 Matching Algorithm

The matching logic is implemented in PostgreSQL function `match_programs()` which:

1. Calculates total aggregate points based on LGCSE/ASC grade scale
2. Checks minimum APS requirements for each program
3. Validates subject-specific grade requirements
4. Evaluates subject combinations and alternatives
5. Returns eligibility status with detailed explanations

## 👤 Demo Accounts

Test with these sample profiles (create via sign-up):

1. **High Achiever**: Strong STEM scores (Math A, Physics B, Chemistry B)
2. **Arts Focus**: Strong humanities (English A, History B, Sesotho A)  
3. **Borderline**: Meets minimum requirements for some programs
4. **STEM Weak**: Strong languages but weak sciences

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point with theme config
├── models/                  # Data models (LearnerProfile, etc.)
├── providers/               # Riverpod state providers
├── screens/                 # UI screens
│   ├── login_screen.dart    # Authentication
│   ├── register_screen.dart # User registration
│   ├── onboarding_screen.dart # First launch experience
│   ├── input_screen.dart    # Subject and grade input
│   ├── results_screen.dart  # Matching results display
│   └── profile_screen.dart  # Profile management
├── services/                # Business logic
│   ├── auth_service.dart    # Authentication operations
│   ├── matching_service.dart # Program matching logic
│   └── local_storage_service.dart # Session persistence
└── constants/               # App constants and styles
```

## 🔧 Key Configurations

- **Theme**: Lesotho blue (#003366) and green (#009933) color scheme
- **Authentication**: Supabase email/password with verification
- **State Management**: Riverpod with auth state notifier
- **Local Storage**: SharedPreferences for auth persistence
- **Logging**: Comprehensive debug logging throughout the app

## 🐛 Troubleshooting

### Common Issues

1. **Authentication Problems**:
   - Verify Supabase URL and anon key in `.env`
   - Check email verification status in Supabase Auth

2. **Database Errors**:
   - Ensure `production_schema.sql` has been executed completely
   - Verify RLS policies allow user access to their own data

3. **Build Issues**:
   - Run `flutter clean` and `flutter pub get`
   - Ensure all environment variables are set

4. **Hot Reload Issues**:
   - The app maintains auth state across hot reloads with enhanced AuthNotifier

### Debug Mode

Enable debug logging by setting `Logger.root.level = Level.ALL` in `main.dart` to see authentication and matching events in real-time.

## 📞 Support

For technical issues:
1. Check Supabase logs in the dashboard
2. Examine debug output in console
3. Verify database schema matches `production_schema.sql`

## 🚀 Deployment

### Android Build
```bash
flutter build apk --release
```

### Web Build (if enabled)
```bash
flutter build web --release
```

## 📄 License

This project is developed for educational purposes as part of a university admissions system prototype for Lesotho.

## 🔄 Version History

- **v1.0** (August 2025): MVP launch with authentication, profile management, and matching engine
- **v0.9**: Enhanced auth state management and theme consistency
- **v0.8**: Fixed profile update functionality and registration validation

---

*Built for Lesotho Education - August 2025*
