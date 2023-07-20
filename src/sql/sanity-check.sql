-- Create an MRE table
CREATE TABLE t
  (
    `ID` INT,
    `atc` VARCHAR(7),
    `afldat` DATE,
    `ndgn` INT
  )
;

INSERT INTO t
  (`ID`, `atc`, `afldat`, `ndgn`)
VALUES
  (1, "R03AC02", "2009-06-16", 1),
  (1, "R03AC02", "2009-07-20", 1),
  (1, "R03AC02", "2009-09-14", 1),
  (1, "R03AC02", "2009-10-20", 1),
  (1, "G01AF04", "2009-11-24", 1),
  (1, "R03AC02", "2009-12-28", 1),
  (1, "G03AB03", "2010-04-12", 168),
  (1, "J01XE01", "2010-06-25", 5),
  (1, "G03AB03", "2010-11-08", 168),
  (1, "R03AC02", "2010-11-08", 1),
  (1, "N05BB01", "2010-12-10", 30),
  (1, "R03AC02", "2010-12-10", 1),
  (1, "R06AE09", "2010-12-10", 30),
  (2, "G03AB03", "2010-11-08", 168),
  (2, "R03AC02", "2010-11-08", 1),
  (2, "N05BB01", "2010-12-10", 30),
  (2, "R03AC02", "2010-12-10", 1),
  (2, "R06AE09", "2010-12-10", 30)
;

-- Fetch concurrent drug uses
SELECT
  *,
  DATE_ADD(afldat, INTERVAL ndgn DAY) AS med_until,
  JSON_ARRAYAGG(atc) OVER
  (
    PARTITION BY ID, afldat >= DATE_ADD(afldat, INTERVAL ndgn DAY)
  ) AS concurrent_atc,
  afldat >= DATE_ADD(afldat, INTERVAL ndgn DAY) AS less,
  JSON_ARRAYAGG(atc) OVER
  (
    PARTITION BY ID, afldat
    ORDER BY atc
  )
FROM t
;

-- User function to return concurrent drug uses (WIP)
DECLARE DELIMITER $$
CREATE FUNCTION IF NOT EXISTS get_concurrence (@ID AS INT, @atc AS VARCHAR, @afldat AS DATE)
  RETURNS JSON
  NOT DETERMINISTIC
  BEGIN
    DECLARE concurrent JSON
    SET concurrent = 
    (
      SELECT JSON_ARRAYAGG(atc)
      FROM t
      WHERE ID = @ID AND afldat = @afldat
    )
    RETURN concurrent
    ;
  END
  $$
