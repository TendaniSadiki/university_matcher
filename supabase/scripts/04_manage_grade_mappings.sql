-- Admin Script: Manage Grade Mappings
-- Usage: Run this script in Supabase SQL Editor to manage the LGCSE grade-to-points mapping system

-- Add new grade mappings
INSERT INTO grade_mappings (grade, points, description) VALUES
    ('A**', 10, 'Exceptional performance'),
    ('U', 1, 'Ungraded');

-- Update an existing grade mapping
UPDATE grade_mappings SET points = 8, description = 'Very Good (Revised)' WHERE grade = 'A';

-- Deactivate a grade mapping (instead of deleting)
UPDATE grade_mappings SET is_active = FALSE WHERE grade = 'G';

-- Reactivate a grade mapping
UPDATE grade_mappings SET is_active = TRUE WHERE grade = 'G';

-- Delete a grade mapping (use with caution)
-- DELETE FROM grade_mappings WHERE grade = 'U';

-- List all active grade mappings
SELECT grade, points, description FROM grade_mappings WHERE is_active = TRUE ORDER BY points DESC;

-- List all grade mappings including inactive ones
SELECT grade, points, description, is_active FROM grade_mappings ORDER BY points DESC;

-- Check if grade mappings are used in any learner scores (indirectly through points)
-- Note: This is a diagnostic query since scores store points, not grades directly
SELECT gm.grade, gm.points, COUNT(ls.id) as usage_count
FROM grade_mappings gm
LEFT JOIN learner_scores ls ON ls.score = gm.points
GROUP BY gm.grade, gm.points
ORDER BY gm.points DESC;