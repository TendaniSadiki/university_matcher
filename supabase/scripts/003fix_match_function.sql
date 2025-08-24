-- Fix for match_programs function: replace json_array_elements with jsonb_array_elements
CREATE OR REPLACE FUNCTION match_programs(learner_id UUID)
RETURNS TABLE (
    id TEXT,
    name TEXT,
    faculty_id TEXT,
    faculty_name TEXT,
    university_id TEXT,
    university_name TEXT,
    code TEXT,
    duration TEXT,
    description TEXT,
    total_aps_required INTEGER,
    requirements JSONB,
    status TEXT,
    score INTEGER,
    explanation TEXT
) AS $$
DECLARE
    learner_curriculum TEXT;
    total_points INTEGER := 0;
    subject_count INTEGER := 0;
    subject_record RECORD;
    requirement_record RECORD;
    course_record RECORD;
    meets_requirements BOOLEAN;
    subject_grade_label TEXT;
    subject_points INTEGER;
    requirement_subject TEXT;
    requirement_grade TEXT;
    req_json JSONB;
    subject_id_val INTEGER;
    min_score_val INTEGER;
BEGIN
    -- Get learner's curriculum
    SELECT grade INTO learner_curriculum FROM learners WHERE learners.id = learner_id;
    IF learner_curriculum IS NULL THEN
        RAISE EXCEPTION 'Learner curriculum not found';
    END IF;

    -- Calculate total points for all subjects
    FOR subject_record IN
        SELECT ls.subject_id, ls.grade_label, s.name as subject_name
        FROM learner_subjects ls
        JOIN subjects s ON ls.subject_id = s.id
        WHERE ls.learner_id = match_programs.learner_id
    LOOP
        -- Get points for this grade in the learner's curriculum
        SELECT points INTO subject_points
        FROM grade_scale
        WHERE curriculum = learner_curriculum AND grade_label = subject_record.grade_label;
        
        IF subject_points IS NOT NULL THEN
            total_points := total_points + subject_points;
            subject_count := subject_count + 1;
        END IF;
    END LOOP;

    -- For each course, check requirements and get full details
    FOR course_record IN
        SELECT
            c.id as course_id,
            c.name as course_name,
            c.code,
            c.duration_years,
            c.notes,
            f.id as faculty_id,
            f.name as faculty_name,
            u.id as university_id,
            u.name as university_name,
            cr.rule_json,
            (cr.rule_json->>'min_aggregate_points')::INTEGER as min_aggregate_points
        FROM courses c
        JOIN faculties f ON c.faculty_id = f.id
        JOIN universities u ON f.university_id = u.id
        JOIN course_requirements cr ON c.id = cr.course_id
    LOOP
        meets_requirements := true;
        explanation := '';
        req_json := '[]'::jsonb;

        -- Check minimum aggregate points
        IF course_record.min_aggregate_points > total_points THEN
            meets_requirements := false;
            explanation := explanation || 'Insufficient aggregate points. ';
        END IF;

        -- Check required subjects and build requirements JSON
        IF course_record.rule_json ? 'required_subjects' THEN
            FOR requirement_record IN
                SELECT * FROM jsonb_array_elements(course_record.rule_json->'required_subjects')
            LOOP
                requirement_subject := (requirement_record.value)->>'subject';
                requirement_grade := (requirement_record.value)->>'min_grade';
                
                -- Get subject ID
                SELECT subjects.id INTO subject_id_val FROM subjects WHERE subjects.name = requirement_subject;
                IF subject_id_val IS NULL THEN
                    SELECT subject_aliases.subject_id INTO subject_id_val FROM subject_aliases WHERE subject_aliases.alias = requirement_subject;
                END IF;
                
                -- Get min score points for the required grade
                SELECT points INTO min_score_val
                FROM grade_scale
                WHERE curriculum = learner_curriculum AND grade_label = requirement_grade;
                
                -- Add to requirements JSON as an array element
                req_json := req_json || jsonb_build_array(jsonb_build_object(
                    'subject_id', subject_id_val::text,
                    'subject_name', requirement_subject,
                    'min_score', min_score_val,
                    'explanation', 'Minimum grade ' || requirement_grade
                ));
                
                -- Check if learner has this subject with required grade
                SELECT ls.grade_label INTO subject_grade_label
                FROM learner_subjects ls
                JOIN subjects s ON ls.subject_id = s.id
                LEFT JOIN subject_aliases sa ON s.id = sa.subject_id
                WHERE ls.learner_id = match_programs.learner_id
                AND (s.name = requirement_subject OR sa.alias = requirement_subject);

                IF subject_grade_label IS NULL THEN
                    meets_requirements := false;
                    explanation := explanation || 'Missing required subject: ' || requirement_subject || '. ';
                ELSE
                    -- Check if grade meets requirement
                    IF (SELECT points FROM grade_scale WHERE curriculum = learner_curriculum AND grade_label = subject_grade_label) <
                       min_score_val THEN
                        meets_requirements := false;
                        explanation := explanation || 'Insufficient grade in ' || requirement_subject || '. ';
                    END IF;
                END IF;
            END LOOP;
        END IF;

        -- Determine status
        IF meets_requirements THEN
            status := 'Eligible';
        ELSIF total_points >= course_record.min_aggregate_points - 5 THEN
            status := 'Borderline';
            explanation := 'Close to meeting requirements. ' || explanation;
        ELSE
            status := 'Not eligible';
        END IF;

        -- Return the result with all required fields
        id := course_record.course_id::text;
        name := course_record.course_name;
        faculty_id := course_record.faculty_id::text;
        faculty_name := course_record.faculty_name;
        university_id := course_record.university_id::text;
        university_name := course_record.university_name;
        code := course_record.code;
        duration := course_record.duration_years::text || ' years';
        description := course_record.notes;
        total_aps_required := course_record.min_aggregate_points;
        requirements := req_json;
        score := total_points;
        
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;