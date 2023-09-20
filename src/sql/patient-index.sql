CREATE TABLE patient_index

SELECT
  anopat,
  MIN(afldat) AS start_index
FROM recept
GROUP BY anopat
ORDER BY anopat
