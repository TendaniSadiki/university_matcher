-- PostgreSQL Function for Program Matching
-- This function replaces the Deno Edge Function with database-level processing

CREATE OR REPLACE FUNCTION match_programs(learner_id UUID)
RETURNS TABLE (
    course_id INTEGER,
    course_name TEXT,
    course_code TEXT,
    faculty_name TEXT,
    university_name TEXT,
    status TEXT,
    score INTEGER,
    explanation TEXT,
    aggregate_points INTEGER,
    required_aggregate INTEGER,
    missing_requirements TEXT[],
    met_requirements TEXT[]
) AS $$
DECLARE
    learner_curriculum TEXT;
    total_aggregate_points INTEGER;
    grade_points_map JSONB;
BEGIN
    -- Get learner's curriculum
    SELECT grade INTO learner_curriculum
    FROM learners 
    WHERE id = learner_id;
    
    IF learner_curriculum IS NULL THEN
        RAISE EXCEPTION 'Learner not found or curriculum not specified';
    END IF;

    -- Calculate aggregate points and create grade points mapping
    WITH learner_grades AS (
        SELECT 
            ls.grade_label,
            s.code as subject_code,
            gs.points
        FROM learner_subjects ls
        JOIN subjects s ON ls.subject_id = s.id
        JOIN grade_scale gs ON ls.grade_label = gs.grade_label 
            AND gs.curriculum = learner_curriculum
        WHERE ls.learner_id = learner_id
    )
    SELECT 
        SUM(points),
        jsonb_object_agg(grade_label, points)
    INTO total_aggregate_points, grade_points_map
    FROM learner_grades;

    IF total_aggregate_points IS NULL THEN
        RAISE EXCEPTION 'No subjects found for this learner';
    END IF;

    -- Return matching results for all courses
    RETURN QUERY
    WITH course_evaluations AS (
        SELECT
            c.id as course_id,
            c.name as course_name,
            c.code as course_code,
            f.name as faculty_name,
            u.name as university_name,
            cr.rule_json as requirements,
            total_aggregate_points as aggregate_points,
            (cr.rule_json->>'min_aggregate_points')::INTEGER as required_aggregate,
            ARRAY[]::TEXT[] as missing_reqs,
            ARRAY[]::TEXT[] as met_reqs,
            0 as score
        FROM courses c
        JOIN faculties f ON c.faculty_id = f.id
        JOIN universities u ON f.university_id = u.id
        LEFT JOIN course_requirements cr ON c.id = cr.course_id
    ),
    evaluated_courses AS (
        SELECT
            ce.*,
            -- Evaluate aggregate points requirement
            CASE 
                WHEN ce.required_aggregate > 0 AND ce.aggregate_points >= ce.required_aggregate THEN
                    ce.met_reqs || format('Meets aggregate points requirement (%s >= %s)', 
                        ce.aggregate_points, ce.required_aggregate)
                WHEN ce.required_aggregate > 0 THEN
                    ce.missing_reqs || format('Does not meet aggregate points requirement (%s < %s)', 
                        ce.aggregate_points, ce.required_aggregate)
                ELSE ce.missing_reqs
            END as new_missing_reqs,
            CASE 
                WHEN ce.required_aggregate > 0 AND ce.aggregate_points >= ce.required_aggregate THEN
                    ce.met_reqs || format('Meets aggregate points requirement (%s >= %s)', 
                        ce.aggregate_points, ce.required_aggregate)
                ELSE ce.met_reqs
            END as new_met_reqs,
            CASE 
                WHEN ce.required_aggregate > 0 AND ce.aggregate_points >= ce.required_aggregate THEN
                    ce.score + 30
                ELSE ce.score
            END as new_score
        FROM course_evaluations ce
    )
    SELECT
        course_id,
        course_name,
        course_code,
        faculty_name,
        university_name,
        CASE 
            WHEN array_length(new_missing_reqs, 1) = 0 THEN 'Eligible'
            WHEN array_length(new_missing_reqs, 1) <= 2 AND new_score > 40 THEN 'Borderline'
            ELSE 'Not eligible'
        END as status,
        new_score as score,
        CASE 
            WHEN array_length(new_missing_reqs, 1) = 0 THEN 'Meets all requirements'
            ELSE array_to_string(new_missing_reqs, '; ')
        END as explanation,
        aggregate_points,
        COALESCE(required_aggregate, 0),
        new_missing_reqs,
        new_met_reqs
    FROM evaluated_courses
    ORDER BY 
        CASE 
            WHEN array_length(new_missing_reqs, 1) = 0 THEN 0
            WHEN array_length(new_missing_reqs, 1) <= 2 AND new_score > 40 THEN 1
            ELSE 2
        END,
        new_score DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION match_programs(UUID) TO authenticated;

-- Test the function
COMMENT ON FUNCTION match_programs(UUID) IS 'Matches learner subjects and grades against course requirements to determine eligibility';

-- Example usage:
-- SELECT * FROM match_programs('12345678-1234-1234-1234-123456789012');