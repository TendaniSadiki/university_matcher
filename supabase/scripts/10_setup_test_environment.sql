-- Test Environment Setup: Create Demo Users and Test Data
-- Usage: Run this script in Supabase SQL Editor to set up the complete test environment
-- This script creates test users, sets up their profiles, and generates sample scores

-- WARNING: This script will create real user accounts in your Supabase Auth system
-- Ensure you're running this in a development/test environment, not production

-- Step 1: Create test user accounts using Supabase Auth functions
-- Note: These will create users with default password 'password123' (should be changed after creation)

-- Create test user 1: High Achiever
SELECT auth.create_user('{
  "email": "thabo.mokoena@example.com",
  "password": "password123",
  "email_confirm": true,
  "user_metadata": {
    "first_name": "Thabo",
    "last_name": "Mokoena",
    "role": "learner"
  }
}');

-- Create test user 2: Average Achiever
SELECT auth.create_user('{
  "email": "lerato.moloi@example.com",
  "password": "password123",
  "email_confirm": true,
  "user_metadata": {
    "first_name": "Lerato",
    "last_name": "Moloi",
    "role": "learner"
  }
}');

-- Create test user 3: STEM Focused
SELECT auth.create_user('{
  "email": "david.nkosi@example.com",
  "password": "password123",
  "email_confirm": true,
  "user_metadata": {
    "first_name": "David",
    "last_name": "Nkosi",
    "role": "learner"
  }
}');

-- Create test user 4: Arts/Humanities Focused
SELECT auth.create_user('{
  "email": "mpho.dlamini@example.com",
  "password": "password123",
  "email_confirm": true,
  "user_metadata": {
    "first_name": "Mpho",
    "last_name": "Dlamini",
    "role": "learner"
  }
}');

-- Create test user 5: Borderline Candidate
SELECT auth.create_user('{
  "email": "tumelo.khumalo@example.com",
  "password": "password123",
  "email_confirm": true,
  "user_metadata": {
    "first_name": "Tumelo",
    "last_name": "Khumalo",
    "role": "learner"
  }
}');

-- Wait a moment for user creation to complete
SELECT pg_sleep(2);

-- Step 2: Update learner profiles with additional information
UPDATE learners SET 
    first_name = 'Thabo',
    last_name = 'Mokoena',
    date_of_birth = '2005-03-15'
WHERE id = (SELECT id FROM auth.users WHERE email = 'thabo.mokoena@example.com');

UPDATE learners SET 
    first_name = 'Lerato',
    last_name = 'Moloi',
    date_of_birth = '2005-07-22'
WHERE id = (SELECT id FROM auth.users WHERE email = 'lerato.moloi@example.com');

UPDATE learners SET 
    first_name = 'David',
    last_name = 'Nkosi',
    date_of_birth = '2005-11-08'
WHERE id = (SELECT id FROM auth.users WHERE email = 'david.nkosi@example.com');

UPDATE learners SET 
    first_name = 'Mpho',
    last_name = 'Dlamini',
    date_of_birth = '2005-01-30'
WHERE id = (SELECT id FROM auth.users WHERE email = 'mpho.dlamini@example.com');

UPDATE learners SET 
    first_name = 'Tumelo',
    last_name = 'Khumalo',
    date_of_birth = '2005-09-14'
WHERE id = (SELECT id FROM auth.users WHERE email = 'tumelo.khumalo@example.com');

-- Step 3: Insert sample scores for each test learner

-- High Achiever: Thabo Mokoena
INSERT INTO learner_scores (learner_id, subject_id, score)
SELECT 
    l.id as learner_id,
    s.id as subject_id,
    CASE s.code
        WHEN 'math' THEN 9
        WHEN 'english' THEN 9
        WHEN 'science' THEN 9
        WHEN 'sesotho' THEN 8
        WHEN 'physics' THEN 9
        WHEN 'chemistry' THEN 9
        WHEN 'biology' THEN 8
        WHEN 'accounting' THEN 8
        WHEN 'computer_studies' THEN 9
        ELSE 7
    END as score
FROM learners l
CROSS JOIN subjects s
WHERE l.id = (SELECT id FROM auth.users WHERE email = 'thabo.mokoena@example.com')
AND s.code IN ('math', 'english', 'science', 'sesotho', 'physics', 'chemistry', 'biology', 'accounting', 'computer_studies')
ON CONFLICT (learner_id, subject_id) 
DO UPDATE SET score = EXCLUDED.score;

-- Average Achiever: Lerato Moloi
INSERT INTO learner_scores (learner_id, subject_id, score)
SELECT 
    l.id as learner_id,
    s.id as subject_id,
    CASE s.code
        WHEN 'math' THEN 7
        WHEN 'english' THEN 8
        WHEN 'science' THEN 6
        WHEN 'sesotho' THEN 9
        WHEN 'history' THEN 7
        WHEN 'geography' THEN 7
        WHEN 'economics' THEN 6
        WHEN 'business_studies' THEN 7
        ELSE 5
    END as score
FROM learners l
CROSS JOIN subjects s
WHERE l.id = (SELECT id FROM auth.users WHERE email = 'lerato.moloi@example.com')
AND s.code IN ('math', 'english', 'science', 'sesotho', 'history', 'geography', 'economics', 'business_studies')
ON CONFLICT (learner_id, subject_id) 
DO UPDATE SET score = EXCLUDED.score;

-- STEM Focused: David Nkosi
INSERT INTO learner_scores (learner_id, subject_id, score)
SELECT 
    l.id as learner_id,
    s.id as subject_id,
    CASE s.code
        WHEN 'math' THEN 9
        WHEN 'physics' THEN 9
        WHEN 'chemistry' THEN 8
        WHEN 'biology' THEN 8
        WHEN 'computer_studies' THEN 9
        WHEN 'english' THEN 5
        WHEN 'sesotho' THEN 4
        WHEN 'history' THEN 6
        ELSE 5
    END as score
FROM learners l
CROSS JOIN subjects s
WHERE l.id = (SELECT id FROM auth.users WHERE email = 'david.nkosi@example.com')
AND s.code IN ('math', 'english', 'sesotho', 'physics', 'chemistry', 'biology', 'computer_studies', 'history')
ON CONFLICT (learner_id, subject_id) 
DO UPDATE SET score = EXCLUDED.score;

-- Arts/Humanities Focused: Mpho Dlamini
INSERT INTO learner_scores (learner_id, subject_id, score)
SELECT 
    l.id as learner_id,
    s.id as subject_id,
    CASE s.code
        WHEN 'english' THEN 8
        WHEN 'sesotho' THEN 9
        WHEN 'history' THEN 8
        WHEN 'geography' THEN 7
        WHEN 'religious_studies' THEN 8
        WHEN 'art_design' THEN 7
        WHEN 'math' THEN 4
        WHEN 'science' THEN 5
        ELSE 6
    END as score
FROM learners l
CROSS JOIN subjects s
WHERE l.id = (SELECT id FROM auth.users WHERE email = 'mpho.dlamini@example.com')
AND s.code IN ('math', 'english', 'science', 'sesotho', 'history', 'geography', 'religious_studies', 'art_design')
ON CONFLICT (learner_id, subject_id) 
DO UPDATE SET score = EXCLUDED.score;

-- Borderline Candidate: Tumelo Khumalo
INSERT INTO learner_scores (learner_id, subject_id, score)
SELECT 
    l.id as learner_id,
    s.id as subject_id,
    CASE s.code
        WHEN 'math' THEN 6
        WHEN 'english' THEN 6
        WHEN 'science' THEN 5
        WHEN 'sesotho' THEN 7
        WHEN 'business_studies' THEN 6
        WHEN 'accounting' THEN 5
        ELSE 4
    END as score
FROM learners l
CROSS JOIN subjects s
WHERE l.id = (SELECT id FROM auth.users WHERE email = 'tumelo.khumalo@example.com')
AND s.code IN ('math', 'english', 'science', 'sesotho', 'business_studies', 'accounting')
ON CONFLICT (learner_id, subject_id) 
DO UPDATE SET score = EXCLUDED.score;

-- Step 4: Verify the test environment setup
SELECT 'Test environment setup completed successfully!' as status;

-- Display all test users and their APS scores
SELECT 
    u.email,
    l.first_name,
    l.last_name,
    COUNT(ls.id) as subject_count,
    calculate_learner_aps(l.id) as total_aps,
    CASE 
        WHEN calculate_learner_aps(l.id) >= 30 THEN 'Excellent'
        WHEN calculate_learner_aps(l.id) >= 25 THEN 'Very Good'
        WHEN calculate_learner_aps(l.id) >= 20 THEN 'Good'
        WHEN calculate_learner_aps(l.id) >= 15 THEN 'Average'
        ELSE 'Below Average'
    END as performance_level
FROM learners l
JOIN auth.users u ON l.id = u.id
LEFT JOIN learner_scores ls ON l.id = ls.learner_id
WHERE u.email IN (
    'thabo.mokoena@example.com',
    'lerato.moloi@example.com',
    'david.nkosi@example.com',
    'mpho.dlamini@example.com',
    'tumelo.khumalo@example.com'
)
GROUP BY u.email, l.first_name, l.last_name, l.id
ORDER BY total_aps DESC;

-- Demo Credentials Summary
SELECT 
    'Demo Credentials:' as header,
    'All users have password: password123' as note,
    'Recommended: Change passwords after initial testing' as recommendation;