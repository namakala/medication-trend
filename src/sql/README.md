# What to achieve?

1. We have two tables, each for patient and prescription
1. I need to query the prescription table and obtain concurrent medication claims
1. Concurrency is defined as different medications being prescribed for the same duration of time

## Data example

In the prescription table, the minimum information I need to query are:

- `anopat`: Unique patient's identifier
- `afldat`: The date of medication claim
- `ndgn`: Number of days the medication is being prescribed for
- `atc`: The medication code according to WHO

For an example, the following dummy table is used:

| `anopat` |  `afldat`  | `ndgn` | `atc` |
|----------|------------|--------|-------|
|   1      | 2023-02-01 |   90   |   A   |
|   1      | 2023-03-01 |   10   |   B   |
|   1      | 2023-03-15 |   15   |   C   |
|   2      | 2023-02-05 |   10   |   B   |
|   2      | 2023-02-13 |   30   |   A   |

## Rough idea

1. I want to transform the table using `afldat` as an index for each patient
2. In this case, `afldat` should act as the primary starting point
3. This way, we can add the transformed `afldat` to `ndgn` so that we obtain the relative ending date of uses as `index` + `ndgn` - 1

   | `anopat` | `index` | `ndgn` | `end` | `atc` |
   |----------|---------|--------|-------|-------|
   | 1        | 1       | 90     | 90    | A     |
   | 1        | 30      | 10     | 39    | B     |
   | 1        | 44      | 15     | 58    | C     |
   | 2        | 1       | 10     | 10    | B     |
   | 2        | 9       | 30     | 38    | A     |

4. Visually, the patient journey would be:
   
   Patient 1:  
                                                 +--------------C (15)  
                                  +---------B (10)  
   +------------------------------------------------------------------------------------------A (90)  
   +------------------------------+--------------+-------------------------------------------->  
   1                              30             44                                         90  

   Patient 2:  
           +--------------------------------A (30)  
   +---------B (10)  
   +-------+-------------------------------->  
   1       9                              40  

5. Therefore, we can evaluate concurrency as an overlap of medication claims

   | `anopat` | `index` | `end` | `atc` |
   |----------|---------|-------|-------|
   | 1        | 1       | 29    | A     |
   | 1        | 30      | 39    | A, B  |
   | 1        | 40      | 43    | A     |
   | 1        | 44      | 58    | A, C  |
   | 1        | 59      | 90    | A     |
   | 2        | 1       | 8     | B     |
   | 2        | 9       | 10    | A, B  |
   | 2        | 11      | 38    | A     |
