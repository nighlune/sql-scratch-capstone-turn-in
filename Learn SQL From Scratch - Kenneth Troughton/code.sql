-- Warby Parker: A Lense into the Data
-- Kenneth Troughton
-- January 29th, 2019

-- 1 Quiz Funnel
SELECT question,
	COUNT(user_id) AS 'num_of_users'
FROM survey
GROUP BY question
ORDER BY question ASC;

-- 2 Home Try-On Funnel: A/B Test (query 1)
SELECT
  q.user_id,
  CASE
    WHEN h.user_id IS NULL THEN 'False’
    ELSE 'True'
  END AS 'is_home_try_on',
  h.number_of_pairs,
  CASE
    WHEN p.user_id IS NULL THEN 'False’
    ELSE 'True'
  END AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
  ON q.user_id = h.user_id
LEFT JOIN purchase p
  ON p.user_id = q.user_id
WHERE is_home_try_on = 'True';

-- 2 Home Try-On Funnel: A/B Test (query 2)
WITH funnel AS (
SELECT
	q.user_id,
  h.user_id IS NOT NULL AS 'is_home_try_on',
  h.number_of_pairs,
  p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
	ON q.user_id = h.user_id
LEFT JOIN purchase p
	ON p.user_id = q.user_id
)
SELECT
	number_of_pairs,
  COUNT(*) is_purchase
FROM funnel
GROUP BY number_of_pairs
ORDER BY 2 DESC;

-- 3 Home Try-On Funnel: Conversion Rates
WITH funnel AS (
SELECT
	q.user_id,
  h.user_id IS NOT NULL AS 'is_home_try_on',
  h.number_of_pairs,
  p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz q
LEFT JOIN home_try_on h
	ON q.user_id = h.user_id
LEFT JOIN purchase p
	ON p.user_id = q.user_id
)
SELECT
	COUNT(*) AS 'num_browse',
	SUM(is_home_try_on) AS 'total_home_try_on',
  SUM(is_purchase) AS 'total_purchase',
  1.0 * SUM(is_home_try_on) / COUNT(user_id) AS 'quiz_to_home_try_on',
	1.0 * SUM(is_purchase) / SUM(is_home_try_on) AS 'home_try_on_to_purchase'
FROM funnel;