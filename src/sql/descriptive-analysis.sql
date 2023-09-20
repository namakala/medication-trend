-- N05B and N06A claims throughout the years
SELECT
  jaar,
  atc,
  COUNT(*) AS n
FROM recept AS r
WHERE atc REGEXP "N0(5B|6A).{3}"
GROUP BY jaar, atc
ORDER BY jaar, atc
;

-- N05B and N06A claims by unique patients throughout the years
SELECT
  jaar,
  atc,
  COUNT(DISTINCT anopat) AS n
FROM recept AS r
WHERE atc REGEXP "N0(5B|6A).{3}"
GROUP BY jaar, atc
ORDER BY atc, jaar
;

-- Check antidepressant and anxiolytics compared to other drugs
SELECT
  jaar,
  CASE
    WHEN atc LIKE "N05B%" THEN "Anxiolytics"
    WHEN atc LIKE "N06A%" THEN "Antidepressants"
    ELSE "Others"
  END AS atc_group,
  COUNT(DISTINCT anopat) AS n_patient
FROM recept AS r
GROUP BY
  jaar,
  CASE
    WHEN atc LIKE "N05B%" THEN "Anxiolytics"
    WHEN atc LIKE "N06A%" THEN "Antidepressants"
    ELSE "Others"
  END
ORDER BY jaar
;

-- Describe psychopharmaca uses per year
SELECT
  jaar,
  CASE
    WHEN atc REGEXP "N0(5B|6A).{3}" THEN LEFT(atc, 5)
    ELSE "Other"
  END AS atc_group,
  COUNT(DISTINCT anopat) AS n_patient
FROM recept AS r
GROUP BY
  CASE
    WHEN atc REGEXP "N0(5B|6A).{3}" THEN LEFT(atc, 5)
    ELSE "Other"
  END,
  jaar
ORDER BY
  CASE
    WHEN atc REGEXP "N0(5B|6A).{3}" THEN LEFT(atc, 5)
    ELSE "Other"
  END,
  jaar
;

WITH atc_tbl AS
(
  SELECT
    jaar,
    anopat,
    CASE
      WHEN atc REGEXP "N0(5B|6A).{3}" THEN LEFT(atc, 5)
      WHEN atc REGEXP "N.*" THEN "Neurologic medication"
      ELSE "Other"
    END AS atc_group
  FROM recept AS r
)
SELECT
  jaar,
  atc_group,
  COUNT(DISTINCT anopat) AS n_patient
FROM atc_tbl
GROUP BY atc_group, jaar
ORDER BY atc_group, jaar
;
