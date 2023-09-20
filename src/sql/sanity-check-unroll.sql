-- Create a dummy table
CREATE TABLE tbl (
  id int,
  start_date date,
  day_of_use int,
  item varchar(8)
)
;

-- Populating table with sample data
INSERT INTO tbl VALUES (1, "2023-02-01", 90, "A");
INSERT INTO tbl VALUES (1, "2023-03-02", 10, "B");
INSERT INTO tbl VALUES (1, "2023-03-15", 15, "C");
INSERT INTO tbl VALUES (2, "2023-02-05", 10, "B");
INSERT INTO tbl VALUES (2, "2023-02-13", 30, "A");

-- Querying the overlap
WITH
  RECURSIVE cte AS
  (
    SELECT id, start_date AS date_, day_of_use, item
    FROM tbl
  
    UNION ALL 
  
    SELECT id, DATE_ADD(date_, INTERVAL 1 DAY), day_of_use-1, item  
    FROM cte
    WHERE day_of_use > 0
  ),
  cte2 AS
  (
    SELECT
      id, 
      DENSE_RANK() OVER(PARTITION BY id ORDER BY date_) AS rn, 
      item
    FROM cte
  ),
  cte3_1 AS
  (
    SELECT
      id, 
      rn,
      GROUP_CONCAT(item) AS items
    FROM cte2
    GROUP BY id, rn
  ),
  cte3_2 AS
  (
    SELECT
      id, 
      rn,
      items,
      LAG(items) OVER(PARTITION BY id ORDER BY rn) AS prev_items
    FROM cte3_1
  ),
  cte4 AS (
    SELECT
      id,
      rn,
      items,
      COUNT(CASE WHEN prev_items != items THEN 1 END) OVER(PARTITION BY id ORDER BY rn) AS parts
    FROM cte3_2 
  )

SELECT id, MIN(rn) AS start_, MAX(rn) AS end_, items 
FROM cte4
GROUP BY id, items, parts
;
