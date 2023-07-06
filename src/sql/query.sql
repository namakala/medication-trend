SELECT
  patient.anopat AS ID,
  patient.mv AS gender,
  patient.gebdat AS birthdate,
  patient.edat AS start_date,
  patient.ldat AS end_date,
  recept.afldat AS prescrib_date,
  recept.atc AS atc_code,
  recept.nddd AS daily_dose,
  recept.ndgn AS days_taking_med
FROM
  recept
LEFT JOIN
  patient ON recept.Anopat = patient.anopat
LIMIT 5
;
