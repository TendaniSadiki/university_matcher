# University Matcher MVP - Admissions Smart Calculator

A Flutter-based mobile application that matches Lesotho LGCSE scores with university programs at NUL and Limkokwing University. The app uses Supabase for backend services including Postgres database, authentication, and Edge Functions.

## Features

- **Smart Matching Algorithm**: Matches learner scores with university program requirements
- **Detailed Eligibility Explanations**: Shows why a program is eligible or not with subject-specific requirements
- **Real-time Filtering**: Filter results by university, faculty, and other criteria
- **Session Logging**: Tracks user interactions and matching sessions for analytics
- **Admin Dashboard**: Comprehensive SQL scripts for data management and analytics
- **Configurable Grading**: Custom LGCSE grade-to-points mapping based on Lesotho standards

## Technology Stack

- **Frontend**: Flutter (Dart) with Material Design
- **Backend**: Supabase (Postgres, Authentication, Edge Functions)
- **Database**: PostgreSQL with Row Level Security (RLS)
- **Authentication**: Supabase Auth (migrated from Firebase Auth)
- **Server Functions**: TypeScript Edge Functions for matching logic

## Setup Instructions

### Prerequisites

- Flutter SDK (version 3.0 or higher)
- Dart SDK (version 2.17 or higher)
- Supabase account and project
- Android Studio or VS Code with Flutter extension

### 1. Supabase Project Setup

1. Create a new Supabase project at [supabase.com](https://supabase.com)
2. Note your project URL and API keys from Settings > API
3. Configure environment variables in `.env` file:

```bash
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 2. Database Migration

Run the initial database schema migration:

1. Navigate to Supabase SQL Editor
2. Run the initial schema: `supabase/migrations/001_initial_schema.sql`
3. Verify the schema was created correctly

### 3. Seed Data Population

Use the admin scripts to populate initial data:

1. **Reset Database** (optional): `supabase/scripts/08_reset_database.sql`
2. **Manage Universities**: `supabase/scripts/01_manage_universities.sql`
3. **Manage Courses**: `supabase/scripts/02_manage_courses.sql`
4. **Manage Subjects**: `supabase/scripts/03_manage_subjects.sql`
5. **Grade Mappings**: `supabase/scripts/04_manage_grade_mappings.sql`

### 4. Test Environment Setup

Create test users and sample data:

1. Run the complete test setup: `supabase/scripts/10_setup_test_environment.sql`
2. This creates 5 test users with different academic profiles

### 5. Flutter App Setup

1. Install dependencies:
```bash
flutter pub get
```

2. Configure environment variables:
   - Copy `.env.example` to `.env`
   - Add your Supabase URL and anon key

3. Run the application:
```bash
flutter run
```

## Demo Credentials

The test environment includes 5 sample learner profiles:

### High Achiever (Excellent scores)
- **Email**: thabo.mokoena@example.com
- **Password**: password123
- **APS**: ~38 points
- **Strong in**: Math, Science, Computer Studies

### Average Achiever (Good scores)
- **Email**: lerato.moloi@example.com  
- **Password**: password123
- **APS**: ~28 points
- **Strong in**: Sesotho, English, Humanities

### STEM Focused (Strong STEM, weak languages)
- **Email**: david.nkosi@example.com
- **Password**: password123
- **APS**: ~32 points
- **Strong in**: Math, Physics, Computer Studies
- **Weak in**: English, Sesotho

### Arts/Humanities Focused (Strong languages, weak STEM)
- **Email**: mpho.dlamini@example.com
- **Password**: password123
- **APS**: ~24 points
- **Strong in**: English, Sesotho, History
- **Weak in**: Math, Science

### Borderline Candidate (Meets minimum requirements)
- **Email**: tumelo.khumalo@example.com
- **Password**: password123
- **APS**: ~18 points
- **Suitable for**: Education, Basic Business programs

## Admin Scripts Overview

The `supabase/scripts/` directory contains comprehensive admin tools:

### Data Management
- `01_manage_universities.sql` - Add/update universities and faculties
- `02_manage_courses.sql` - Manage courses and their requirements
- `03_manage_subjects.sql` - Manage LGCSE subjects
- `04_manage_grade_mappings.sql` - Configure grade-to-points conversion
- `05_manage_learners.sql` - Manage learner profiles and scores

### Analytics & Monitoring
- `06_analytics_monitoring.sql` - View session logs and matching statistics
- `07_database_maintenance.sql` - Database optimization and cleanup

### Utilities
- `08_reset_database.sql` - Reset to initial seed state
- `09_generate_test_data.sql` - Add scores to existing users
- `10_setup_test_environment.sql` - Complete test environment setup

## Matching Algorithm

The matching logic is implemented in `supabase/functions/match-programs/index.ts` and includes:

1. **Total APS Check**: Verifies if learner meets the minimum APS requirement
2. **Subject Requirements**: Checks each required subject meets minimum score
3. **Eligibility Explanations**: Provides detailed reasons for eligibility status
4. **Alternative Suggestions**: Suggests similar programs if ineligible

## Database Schema

Key tables include:
- `universities` and `faculties` - Institutional structure
- `courses` - Academic programs with APS requirements
- `course_requirements` - Subject-specific requirements per course
- `subjects` - LGCSE subjects
- `grade_mappings` - Grade-to-points conversion
- `learners` and `learner_scores` - User data and academic records
- `sessions` and `events` - Usage analytics

## API Endpoints

### Edge Functions
- `POST /match-programs` - Match learner scores with programs
- Requires authentication via Supabase Auth

### Sample Request
```json
{
  "scores": {
    "math": 8,
    "english": 7,
    "science": 6
  }
}
```

## Development Guidelines

### Adding New Universities
1. Add university to `universities` table
2. Add faculties to `faculties` table
3. Add courses with requirements to `courses` and `course_requirements`
4. Update seed data in reset script

### Modifying Grade Mappings
Edit `grade_mappings` table to adjust point values for different grades.

### Customizing Requirements
Update `course_requirements` table to modify subject requirements for specific courses.

## Troubleshooting

### Common Issues

1. **Authentication Errors**: Verify Supabase URL and anon key in `.env`
2. **Database Connection Issues**: Check Supabase project status and network connectivity
3. **Migration Errors**: Ensure RLS policies are properly configured
4. **Matching Algorithm Issues**: Check Edge Function logs in Supabase dashboard

### Support

For technical support, check:
- Supabase Dashboard for database and function logs
- Flutter DevTools for app debugging
- Browser console for network requests

## License

This project is developed for educational purposes as part of a university admissions system prototype.

## Contributing

To contribute to this project:
1. Follow the setup instructions above
2. Make changes in a feature branch
3. Test thoroughly with different learner profiles
4. Submit a pull request with detailed description

---
*Last Updated: August 2024*
