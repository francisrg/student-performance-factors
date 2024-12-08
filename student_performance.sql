SELECT *
FROM 
    public.student_performance
;

-- Looking at Hours Studied vs. Score Improvement for each individual student.

SELECT 
    hours_studied,
    previous_scores, 
    exam_score, 
    ROUND(((exam_score::decimal - previous_scores::decimal) / previous_scores::decimal) * 100, 2) AS improvement
FROM 
    public.student_performance
ORDER BY 
    hours_studied DESC
;

-- Ranking of the students based on final exam along with their rank change based on previous exam scores.

SELECT
	hours_studied,
	previous_scores,
	exam_score,
	RANK() OVER (ORDER BY exam_score DESC) AS exam_rank,
	RANK() OVER (ORDER BY previous_scores DESC) AS previous_score_rank,
	(RANK() OVER (ORDER BY previous_scores DESC) - RANK() OVER (ORDER BY exam_score DESC)) AS rank_change
FROM public.student_performance
;

-- Shows the correlation between exam score and study hours,tutoring sessions, attendance, sleep hours, and physical activity.

SELECT 
    CORR(hours_studied, exam_score) AS correlation_study_score,
	CORR(tutoring_sessions, exam_score) AS correlation_tutoring_score,
    CORR(attendance, exam_score) AS correlation_attendance_score,
	CORR(sleep_hours, exam_score) AS correlation_sleep_score,
	CORR(physical_activity, exam_score) AS correlation_activity_score
FROM 
    public.student_performance
;

-- Compares different groups of hours studied and their respective average exam scores to previous group of hours studied.

WITH grouped_scores AS
	(SELECT
		CASE
			WHEN hours_studied BETWEEN 40 and 49 THEN '40-49 Hours'
			WHEN hours_studied BETWEEN 30 and 39 THEN '30-39 Hours'
			WHEN hours_studied BETWEEN 20 and 29 THEN '20-29 Hours'
			WHEN hours_studied BETWEEN 10 and 19 THEN '10-19 Hours'
			WHEN hours_studied BETWEEN 0 and 9 THEN '0-9 Hours'
		END AS hours_group,
		AVG(exam_score) AS average_exam_score
	FROM
		public.student_performance
	GROUP BY
		hours_group)
SELECT
	hours_group,
	average_exam_score,
	ROUND(((average_exam_score - LAG(average_exam_score) OVER (ORDER BY hours_group)) / LAG(average_exam_score) OVER (ORDER BY hours_group)) * 100, 2) AS percent_score_increase
FROM
	grouped_scores
ORDER BY hours_group
;

-- Shows the average Hours Studied and average Exam Score based on gender.

SELECT 
	gender,
	AVG(hours_studied) AS avg_hours_studied,
	AVG(exam_score) AS avg_exam_score
FROM
	public.student_performance
GROUP BY
	gender
ORDER BY
	avg_exam_score
;

-- Calculates the average exam score for students who receive 3 or more tutoring sessions vs those who receive none.

SELECT
	(SELECT 
		AVG(exam_score)
	FROM
		public.student_performance
	WHERE
		tutoring_sessions >= 3) AS avg_score_with_tutoring,
	(SELECT
		AVG(exam_score)
	FROM
		public.student_performance
	WHERE
		tutoring_sessions = 0) AS avg_score_without_tutoring
;