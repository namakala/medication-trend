SELECT
  p.anopat AS ID,
  p.mv AS gender,
  p.gebdat AS birthdate,
  r.afldat AS prescrib_date,
  TIMESTAMPDIFF(YEAR, p.gebdat, r.afldat) AS age,
  r.atc AS atc_code,
  r.dagdos AS daily_dose,
  r.nddd AS max_ddd,
  r.dagdos / r.nddd AS weighted_dose,
  r.ndgn AS days_taking_med,
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
;
