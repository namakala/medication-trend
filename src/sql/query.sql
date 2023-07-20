-- Create a CTE
WITH t AS
(
  SELECT
    p.anopat AS ID,
    p.mv AS gender,
    p.gebdat AS birthdate,
    TIMESTAMPDIFF(YEAR, p.gebdat, r.afldat) AS age,
    r.afldat AS prescrib_date,
    r.atc AS atc_code,
    r.ndgn AS days_taking_med,
    DATE_ADD(afldat, INTERVAL ndgn DAY) AS med_until,
    LAG(DATE_ADD(afldat, INTERVAL ndgn DAY), 1) OVER(PARTITION BY r.anopat ORDER BY r.afldat) AS med_lag1,
    LAG(DATE_ADD(afldat, INTERVAL ndgn DAY), 2) OVER(PARTITION BY r.anopat ORDER BY r.afldat) AS med_lag2,
    LAG(DATE_ADD(afldat, INTERVAL ndgn DAY), 3) OVER(PARTITION BY r.anopat ORDER BY r.afldat) AS med_lag3,
    r.dagdos AS daily_dose,
    r.nddd AS max_ddd,
    r.dagdos / r.nddd AS weighted_dose,
    p.edat AS start_date,
    p.ldat AS end_date
  FROM recept AS r LEFT JOIN patient AS p ON r.Anopat = p.anopat
  WHERE
    p.anopat IN
    ( -- Constrain to patients being prescribed antidepressant or anxiolytics with OTHER meds in the time span
      SELECT DISTINCT
        p.anopat
      FROM recept AS r LEFT JOIN patient AS p ON r.anopat = p.anopat
      WHERE
        (r.afldat BETWEEN "2018-01-01" AND "2022-12-31") -- Time span: 5 years
        AND
        (
          r.atc LIKE "N05B%"
          OR r.atc LIKE "N06A%"
        )
    )
    AND (r.afldat BETWEEN "2018-01-01" AND "2022-12-31")
    AND TIMESTAMPDIFF(YEAR, p.gebdat, r.afldat) BETWEEN 18 AND 65 -- Select adult 18-65 years old
    AND r.atc REGEXP "[a-zA-Z0-9]+" -- Omit null or empty spaces
    AND r.ndgn > 0
  ORDER BY p.anopat, p.gebdat, r.afldat, r.atc
)

-- Fetch concurrent drug uses
SELECT
  *,
  JSON_ARRAYAGG(atc) OVER
  (
    PARTITION BY
      ID,
      (prescrib_date <= med_lag1 OR prescrib_date <= med_lag2 OR prescrib_date <= med_lag3) -- Need to introduce lag here
  ) AS concurrent_atc
FROM t
;
