# What to achieve?

1. We have two tables, each for patient and prescription
1. I need to query the prescription table and obtain concurrent medication claims
1. Concurrency is defined as different medications being prescribed for the same duration of time

## Data example

In the prescription table, the minimum information I need to query are:

- `anopat`: Unique patient's identifier; `id` for brevity
- `afldat`: The date of medication claim; `date`
- `ndgn`: Number of days the medication is being prescribed for; `use`
- `atc`: The medication code according to WHO; `item`

For an example, the following dummy table is used:

| `id` |   `date`   | `use`  | `item` |
|------|------------|--------|--------|
|   1  | 2023-02-01 |   90   |   A    |
|   1  | 2023-03-01 |   10   |   B    |
|   1  | 2023-03-15 |   15   |   C    |
|   2  | 2023-02-05 |   10   |   B    |
|   2  | 2023-02-13 |   30   |   A    |

## Rough idea

1. I want to transform the table using `date` as a starting index for each personnel `id`
3. This way, we can transform the transformed `date` to `use` so that we obtain the relative ending date of uses as `start` + `use` - 1

   | `id` | `start` | `use` | `end` | `item` |
   |------|---------|-------|-------|--------|
   | 1    | 1       | 90    | 90    | A      |
   | 1    | 30      | 10    | 39    | B      |
   | 1    | 44      | 15    | 58    | C      |
   | 2    | 1       | 10    | 10    | B      |
   | 2    | 9       | 30    | 38    | A      |

4. Visually, the item acquisition journey for each personnel would be:
   
   Personnel 1:  

   ```
                                                 +--------------C (15)  
                                  +---------B (10)  
   +------------------------------------------------------------------------------------------A (90)  
   +------------------------------+--------------+-------------------------------------------->  
   1                              30             44                                         90  
   ```

   Personnel 2:  

   ```
           +--------------------------------A (30)  
   +---------B (10)  
   +-------+-------------------------------->  
   1       9                              40  
   ```

5. Finally, I can evaluate concurrent item acquisition as follow:

   | `id` | `start` | `end` | `item` |
   |------|---------|-------|--------|
   | 1    | 1       | 29    | A      |
   | 1    | 30      | 39    | A, B   |
   | 1    | 40      | 43    | A      |
   | 1    | 44      | 58    | A, C   |
   | 1    | 59      | 90    | A      |
   | 2    | 1       | 8     | B      |
   | 2    | 9       | 10    | A, B   |
   | 2    | 11      | 38    | A      |

# Solution

After looking around and [asking in SE](https://stackoverflow.com/questions/77095783/transform-a-table-based-on-date-overlap), it seems the best option at the moment is to create a recursive CTE. This step unrolls the table and fills in the blank between the dates of claim (`afldat`). Suppose we have the following table:

| `id` |   `date`   | `use`  | `item` |
|------|------------|--------|--------|
|   1  | 2023-03-11 |   3    |   B    |

Then we can apply a recursive CTE with:

```sql

WITH RECURSIVE cte AS
(
  SELECT id, date, use, item
  FROM table
  
  UNION ALL

  SELECT id, DATE_ADD(date, INTERVAL 1 DAY), use - 1, item
  FROM cte
  WHERE use > 0
)

```

We can obtain:

| `id` |   `date`   | `use`  | `item` |
|------|------------|--------|--------|
|   1  | 2023-03-11 |   3    |   B    |
|   1  | 2023-03-12 |   2    |   B    |
|   1  | 2023-03-13 |   1    |   B    |
|   1  | 2023-03-14 |   0    |   B    |

By using `LAG`, we can easily capture the concurrent uses as:

| `id` |   `date`   | `use`  | `item` | `prev` |
|------|------------|--------|--------|--------|
|   1  | 2023-03-11 |   3    |   B    | *null* |
|   1  | 2023-03-12 |   2    |   B    |   B    |
|   1  | 2023-03-13 |   1    |   B    |   B    |
|   1  | 2023-03-14 |   0    |   B    |   B    |
