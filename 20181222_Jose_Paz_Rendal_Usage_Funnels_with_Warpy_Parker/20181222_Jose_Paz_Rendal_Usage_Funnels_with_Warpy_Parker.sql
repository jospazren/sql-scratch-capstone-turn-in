-- 1. What columns does the ‘survey’ table have?
SELECT *
FROM survey
LIMIT 10;

-- 2. What is the number of responses for each question?
SELECT question, count(*) as responses
FROM survey
GROUP BY question;

-- 4. What are the column names of the ‘quiz’, ‘home_try_on’ and ‘purchase’ tables?
SELECT *
FROM quiz
LIMIT 5;
SELECT *
FROM home_try_on
LIMIT 5;
SELECT *
FROM purchase	
LIMIT 5;


-- 5. Create a table with the following layout
SELECT quiz.user_id, 
  CASE
    WHEN home_try_on.number_of_pairs IS NULL THEN 'False'
    ELSE 'True'
  END AS is_home_try_on,
  CASE
    WHEN home_try_on.number_of_pairs = '3 pairs' THEN '3'
    WHEN home_try_on.number_of_pairs = '5 pairs' THEN '5'
    ELSE 'NULL'
  END AS number_of_pairs,
  CASE
    WHEN purchase.user_id IS NULL THEN 'False'
    ELSE 'True'
  END AS is_purchase
FROM quiz
LEFT JOIN home_try_on on quiz.user_id = home_try_on.user_id
LEFT JOIN purchase on quiz.user_id = purchase.user_id
LIMIT 10;
-- 6. Actionable insights A: send five pairs
WITH aggregated AS (SELECT quiz.user_id, 
  CASE
    WHEN home_try_on.number_of_pairs IS NULL THEN 'False'
    ELSE 'True'
  END AS is_home_try_on,
  CASE
    WHEN home_try_on.number_of_pairs = '3 pairs' THEN '3'
    WHEN home_try_on.number_of_pairs = '5 pairs' THEN '5'
    ELSE 'NULL'
  END AS number_of_pairs,
  CASE
    WHEN purchase.user_id IS NULL THEN 'False'
    ELSE 'True'
  END AS is_purchase
FROM quiz
LEFT JOIN home_try_on on quiz.user_id = home_try_on.user_id
LEFT JOIN purchase on quiz.user_id = purchase.user_id)

SELECT number_of_pairs, count(*) AS tried_on, sum(
  CASE
    WHEN is_purchase = 'True' THEN 1
    ELSE 0
  END) AS purchased
FROM aggregated
WHERE number_of_pairs IS NOT 'NULL'
GROUP BY 1;

-- 6. Actionable insights B: don’t send glasses unless style is known
WITH aggregated AS (SELECT quiz.user_id, 
  CASE
    WHEN home_try_on.number_of_pairs IS NULL THEN 'False'
    ELSE 'True'
  END AS is_home_try_on,
  CASE
    WHEN home_try_on.number_of_pairs = '3 pairs' THEN '3'
    WHEN home_try_on.number_of_pairs = '5 pairs' THEN '5'
    ELSE 'NULL'
  END AS number_of_pairs,
  CASE
    WHEN purchase.user_id IS NULL THEN 'False'
    ELSE 'True'
  END AS is_purchase
FROM quiz
LEFT JOIN home_try_on on quiz.user_id = home_try_on.user_id
LEFT JOIN purchase on quiz.user_id = purchase.user_id)

SELECT style, count(*) as answered, sum(
  CASE
    WHEN is_home_try_on = 'True' THEN 1
    ELSE 0
  END) as tried_on, sum(
  CASE
    WHEN is_purchase = 'True' THEN 1
    ELSE 0
  END) as purchased
FROM quiz
LEFT JOIN aggregated on aggregated.user_id = quiz.user_id
GROUP BY 1;

-- 6. Actionable insights C: test whether asking for shape is needed
WITH aggregated AS (SELECT quiz.user_id, 
  CASE
    WHEN home_try_on.number_of_pairs IS NULL THEN 'False'
    ELSE 'True'
  END AS is_home_try_on,
  CASE
    WHEN home_try_on.number_of_pairs = '3 pairs' THEN '3'
    WHEN home_try_on.number_of_pairs = '5 pairs' THEN '5'
    ELSE 'NULL'
  END AS number_of_pairs,
  CASE
    WHEN purchase.user_id IS NULL THEN 'False'
    ELSE 'True'
  END AS is_purchase
FROM quiz
LEFT JOIN home_try_on on quiz.user_id = home_try_on.user_id
LEFT JOIN purchase on quiz.user_id = purchase.user_id)

SELECT shape, count(*) as answered, sum(
  CASE
    WHEN is_home_try_on = 'True' THEN 1
    ELSE 0
  END) as tried_on, sum(
  CASE
    WHEN is_purchase = 'True' THEN 1
    ELSE 0
  END) as purchased
FROM quiz
LEFT JOIN aggregated on aggregated.user_id = quiz.user_id
GROUP BY 1;

-- 6. Actionable insights D: focus on the higher-end of the market
SELECT price, count(*) AS purchases
FROM purchase
GROUP BY 1;