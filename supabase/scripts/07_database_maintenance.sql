-- Admin Script: Database Maintenance and Cleanup
-- Usage: Run this script in Supabase SQL Editor for routine database maintenance

-- Backup important tables (run before major changes)
-- Note: In Supabase, you might want to use the dashboard for full backups
-- This creates temporary backup tables for critical data

CREATE TABLE IF NOT EXISTS backup_courses AS SELECT * FROM courses;
CREATE TABLE IF NOT EXISTS backup_course_requirements AS SELECT * FROM course_requirements;
CREATE TABLE IF NOT EXISTS backup_grade_mappings AS SELECT * FROM grade_mappings;

-- Cleanup old sessions and events (older than 90 days)
DELETE FROM events 
WHERE session_id IN (
    SELECT id FROM sessions 
    WHERE started_at < NOW() - INTERVAL '90 days'
);

DELETE FROM sessions 
WHERE started_at < NOW() - INTERVAL '90 days';

-- Remove orphaned learner scores (scores without a learner)
DELETE FROM learner_scores 
WHERE learner_id NOT IN (SELECT id FROM learners);

-- Remove orphaned course requirements (requirements without a course)
DELETE FROM course_requirements 
WHERE course_id NOT IN (SELECT id FROM courses);

-- Remove orphaned faculty records (faculties without a university)
DELETE FROM faculties 
WHERE university_id NOT IN (SELECT id FROM universities);

-- Update statistics for query optimization
ANALYZE;

-- Check database health and integrity
SELECT 
    (SELECT COUNT(*) FROM universities) as university_count,
    (SELECT COUNT(*) FROM faculties) as faculty_count,
    (SELECT COUNT(*) FROM courses) as course_count,
    (SELECT COUNT(*) FROM course_requirements) as requirement_count,
    (SELECT COUNT(*) FROM subjects) as subject_count,
    (SELECT COUNT(*) FROM learners) as learner_count,
    (SELECT COUNT(*) FROM learner_scores) as score_count,
    (SELECT COUNT(*) FROM sessions) as session_count,
    (SELECT COUNT(*) FROM events) as event_count;

-- Find potential data integrity issues
SELECT 'Orphaned faculties' as issue_type, COUNT(*) as count
FROM faculties 
WHERE university_id NOT IN (SELECT id FROM universities)
UNION ALL
SELECT 'Orphaned courses', COUNT(*) 
FROM courses 
WHERE faculty_id NOT IN (SELECT id FROM faculties)
UNION ALL
SELECT 'Orphaned course requirements', COUNT(*) 
FROM course_requirements 
WHERE course_id NOT IN (SELECT id FROM courses)
UNION ALL
SELECT 'Orphaned course requirements (subject)', COUNT(*) 
FROM course_requirements 
WHERE subject_id NOT IN (SELECT id FROM subjects)
UNION ALL
SELECT 'Orphaned learner scores', COUNT(*) 
FROM learner_scores 
WHERE learner_id NOT IN (SELECT id FROM learners)
UNION ALL
SELECT 'Orphaned learner scores (subject)', COUNT(*) 
FROM learner_scores 
WHERE subject_id NOT IN (SELECT id FROM subjects);

-- Monitor table sizes and growth
SELECT 
    table_name,
    pg_size_pretty(pg_total_relation_size('"' || table_name || '"')) as total_size,
    pg_size_pretty(pg_relation_size('"' || table_name || '"')) as table_size,
    pg_size_pretty(pg_indexes_size('"' || table_name || '"')) as index_size
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY pg_total_relation_size('"' || table_name || '"') DESC;

-- Check index usage and performance
SELECT 
    schemaname,
    tablename,
    indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_all_indexes 
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;

-- Reset sequences if needed (after bulk deletions)
-- Note: Be cautious with sequence resets as they can affect new inserts
/*
SELECT setval(pg_get_serial_sequence('universities', 'id'), COALESCE(MAX(id), 0) + 1, false) FROM universities;
SELECT setval(pg_get_serial_sequence('faculties', 'id'), COALESCE(MAX(id), 0) + 1, false) FROM faculties;
SELECT setval(pg_get_serial_sequence('courses', 'id'), COALESCE(MAX(id), 0) + 1, false) FROM courses;
SELECT setval(pg_get_serial_sequence('course_requirements', 'id'), COALESCE(MAX(id), 0) + 1, false) FROM course_requirements;
SELECT setval(pg_get_serial_sequence('subjects', 'id'), COALESCE(MAX(id), 0) + 1, false) FROM subjects;
SELECT setval(pg_get_serial_sequence('grade_mappings', 'id'), COALESCE(MAX(id), 0) + 1, false) FROM grade_mappings;
*/