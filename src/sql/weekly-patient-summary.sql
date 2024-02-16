CREATE TABLE weekly_patient_summary

SELECT
  YEARWEEK(startdat) AS week,
  COUNT(DISTINCT u.anopat) AS total_patient,
  AVG(YEAR(startdat) - YEAR(gebdat)) AS mean_age,
  AVG(mv - 1) AS female_ratio
FROM same_time_use u LEFT JOIN patient p ON u.anopat = p.anopat
WHERE YEARWEEK(startdat) >= 201801 AND YEARWEEK(startdat) < 202301
GROUP BY YEARWEEK(startdat)
ORDER BY YEARWEEK(startdat) ASC
