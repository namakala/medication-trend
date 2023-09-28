CREATE TEMPORARY TABLE starters_1(PRIMARY KEY(anopat))
SELECT
  p.*,
  min(afldat) startdat
FROM patient p INNER JOIN recept r ON p.anopat = r.anopat
WHERE (LEFT(ATC,3) IN ("N01", "N02", "N03", "N04", "N05", "N06", "N07"))
GROUP BY p.anopat 

CREATE  TEMPORARY TABLE  starters_2 (PRIMARY KEY(anopat))
SELECT
  p.*
FROM  starters_1 p
WHERE TIMESTAMPDIFF(DAY, edat, startdat) >= 30
AND TIMESTAMPDIFF(DAY, edat, startdat) >= 30
AND TIMESTAMPDIFF(DAY, startdat, ldat) >= 0
AND TIMESTAMPDIFF(YEAR, gebdat, startdat) >= 18
AND startdat BETWEEN '1994-01-01' AND '2022-12-31'

CREATE TEMPORARY TABLE  starters_3 (PRIMARY KEY(anopat))
SELECT * FROM starters_2

CREATE TABLE starters (PRIMARY KEY(anopat))
SELECT 
  p.*,
  COUNT
  (
    DISTINCT IF
    (
      ((LEFT(ATC,3) IN ("N01", "N02", "N03", "N04", "N05", "N06", "N07"))) AND (afldat = p.startdat), ATC, NULL
    )
  ) AS nr_start_atcs,
  GROUP_CONCAT
  (
    DISTINCT IF(
    (
      (LEFT(ATC,3) IN ("N01", "N02", "N03", "N04", "N05", "N06", "N07"))) AND (afldat = p.startdat), ATC, NULL
    )
  ) AS start_atcs 
FROM starters_2 p INNER JOIN starters_3 s ON p.anopat = s.anopat
INNER JOIN recept r ON p.anopat = r.anopat
GROUP BY anopat
;
