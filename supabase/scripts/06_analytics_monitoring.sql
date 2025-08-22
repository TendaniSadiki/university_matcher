-- Admin Script: Analytics and Monitoring
-- Usage: Run this script in Supabase SQL Editor to monitor app usage and performance

-- Overview of matching activity
SELECT 
    COUNT(*) as total_sessions,
    COUNT(DISTINCT learner_id) as unique_learners,
    AVG(EXTRACT(EPOCH FROM (ended_at - started_at))) as avg_session_duration_seconds,
    MIN(started_at) as first_session,
    MAX(started_at) as last_session
FROM sessions
WHERE ended_at IS NOT NULL;

-- Session activity by date
SELECT 
    DATE(started_at) as session_date,
    COUNT(*) as sessions_count,
    COUNT(DISTINCT learner_id) as unique_learners
FROM sessions
GROUP BY DATE(started_at)
ORDER BY session_date DESC;

-- Event types analysis
SELECT 
    event_type,
    COUNT(*) as event_count,
    COUNT(DISTINCT session_id) as sessions_with_event
FROM events
GROUP BY event_type
ORDER BY event_count DESC;

-- Program matching results summary
SELECT 
    (event_data->>'eligible_programs')::int as eligible_programs,
    COUNT(*) as match_events,
    AVG((event_data->>'total_aps')::int) as avg_aps
FROM events
WHERE event_type = 'program_matching'
GROUP BY (event_data->>'eligible_programs')::int
ORDER BY eligible_programs;

-- Top courses by eligibility
SELECT 
    c.name as course_name,
    u.name as university_name,
    COUNT(e.id) as times_matched,
    AVG((event_data->>'learner_total_aps')::int) as avg_learner_aps
FROM events e
CROSS JOIN LATERAL jsonb_array_elements(e.event_data->'programs') as program
JOIN courses c ON (program->>'course_id')::uuid = c.id
JOIN faculties f ON c.faculty_id = f.id
JOIN universities u ON f.university_id = u.id
WHERE e.event_type = 'program_matching'
GROUP BY c.name, u.name
ORDER BY times_matched DESC
LIMIT 10;

-- Learner score distribution
SELECT 
    score,
    COUNT(*) as frequency
FROM learner_scores
GROUP BY score
ORDER BY score DESC;

-- Course requirement strictness analysis
SELECT 
    c.name as course_name,
    u.name as university_name,
    COUNT(cr.id) as requirement_count,
    AVG(cr.min_score) as avg_min_score,
    MAX(cr.min_score) as max_min_score
FROM courses c
JOIN faculties f ON c.faculty_id = f.id
JOIN universities u ON f.university_id = u.id
JOIN course_requirements cr ON c.id = cr.course_id
GROUP BY c.name, u.name
ORDER BY avg_min_score DESC;

-- Active learners (those with scores)
SELECT 
    COUNT(DISTINCT learner_id) as learners_with_scores,
    COUNT(*) as total_score_entries,
    AVG(score) as avg_score
FROM learner_scores;

-- Recent matching activity (last 7 days)
SELECT 
    DATE(s.started_at) as session_date,
    COUNT(e.id) as matching_events,
    AVG((e.event_data->>'total_programs')::int) as avg_programs_evaluated,
    AVG((e.event_data->>'eligible_programs')::int) as avg_eligible_programs
FROM events e
JOIN sessions s ON e.session_id = s.id
WHERE e.event_type = 'program_matching'
AND s.started_at >= NOW() - INTERVAL '7 days'
GROUP BY DATE(s.started_at)
ORDER BY session_date DESC;

-- User agent analysis (browser/device usage)
SELECT 
    user_agent,
    COUNT(*) as session_count
FROM sessions
WHERE user_agent IS NOT NULL
GROUP BY user_agent
ORDER BY session_count DESC
LIMIT 10;