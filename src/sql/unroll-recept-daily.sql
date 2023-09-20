CREATE TABLE concurrent_meds_daily

WITH
  -- Recursive CTE to unroll the medication claim
  RECURSIVE unroll AS
  (
    SELECT
      anopat,
      afldat,
      ndgn,
      CONCAT("atc:", atc, "|ndgn:", ndgn, "|dagdos:", dagdos, "|nddd:", nddd, "|weight:", ndgn * dagdos / nddd) AS med
    FROM recept
    WHERE atc REGEXP ".{7}" AND nddd > 0

    UNION ALL

    SELECT
      anopat,
      DATE_ADD(afldat, INTERVAL 1 DAY),
      ndgn - 1,
      med
    FROM unroll
    WHERE ndgn > 0
  ),
  -- Rank each entry based on the date of claim
  ranked_entry AS
  (
    SELECT
      DENSE_RANK() OVER(PARTITION BY anopat ORDER BY afldat) AS rownumber,
      anopat,
      -- afldat,
      med
    FROM unroll
  ),
  -- Combine the medication claimed
  combined_meds AS
  (
    SELECT
      anopat,
      rownumber,
      -- afldat,
      GROUP_CONCAT(med ORDER BY med) AS meds
      -- LAG(GROUP_CONCAT(med)) OVER(PARTITION BY anopat ORDER BY rownumber) AS prev_meds
    FROM ranked_entry
    GROUP BY anopat, rownumber
  ),
  -- Check out on previous medications
  prev_meds AS
  (
    SELECT
      *,
      LAG(meds) OVER(PARTITION BY anopat ORDER BY rownumber) AS prev_meds
    FROM combined_meds
  ),
  -- Identify concurrent medication, partitioned by current and previous medications
  concurrent_meds AS
  (
    SELECT
      anopat,
      rownumber,
      -- afldat,
      meds,
      COUNT(CASE WHEN prev_meds != meds THEN 1 END) OVER(PARTITION BY anopat ORDER BY rownumber) AS parts
    FROM prev_meds
  )

-- Extract all concurrent medications
SELECT
  anopat,
  -- afldat,
  MIN(rownumber) AS rel_start,
  MAX(rownumber) AS rel_end,
  meds
FROM concurrent_meds
GROUP BY anopat, meds, parts
ORDER BY anopat, MIN(rownumber)
