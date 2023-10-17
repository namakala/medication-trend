# Persistence Query

The query creates 9 tables:

1. Extended prescription
1. Gap 1A
1. Gap 1
1. Gap
1. Gap corrected
1. Shifted 1
1. Persistence A
1. Persistence B
1. Persistence

Each table is created sequentially, where the higher sequence linearly source the value from the lower sequence. For example, gap 1A (2) gets its values from the extended prescription (1) table.

## Extended prescription

```sql

CREATE TABLE __extendedPrescription(INDEX(anopat), INDEX(afldat), INDEX(doses))

SELECT 
  *, 
  afldat AS startdat,
  afldat + interval IFNULL(Ndgn,0) DAY AS stopdat,
  IF(IFNULL(ndgn, 0) <> 0, ROUND(nddd/ndgn, 1), NULL) AS doses
FROM recept
ORDER BY anopat, zinr, afldat

```

This query uses `recept` as its source of data, where it takes all values from `recept` and returned three additional fields:

- `startdat`: The start date of observation as obtained from `afldat`, i.e. the date of medication claim
- `stopdat`: The end date of observation, obtained by adding `ndgn` (days of medication uses) to `afldat`
- `doses`: The dose of claimed medication, obtained by dividing `nddd` (recommended maximum dose throughout medication uses) to `ndgn` (number of days taking the medicine)

The table is ordered by:

- `anopat`: Unique patient identifier
- `zinr`:
- `afldat`: Date of medication claim

## Gap 1A

```sql

CREATE TABLE __gap_1_a(INDEX(anopat), INDEX(zinr), INDEX(startdat), index(doses))

SELECT 
  *,
  @d AS prev_stop,
  @d := stopdat AS tmp
FROM __extendedPrescription 
ORDER BY anopat, zinr, afldat

```

This query uses `__extendedPrescription` as its source of data, where it takes all fields and returned two additional fields:

- `prev_stop` which takes the values assigned to `d`
- `tmp` which takes the value assigned to `d`, as it is assigned from `stopdat` field from the previous query

It means that it takes field `stopdat` and assign it to a local variable called `d`, which is then used to create two other fields. Note that the `:=` operator is an assignment operator used within a `SELECT` clause. I don't particularly understand the intent of this query, but it seems to be a temporary fields to be used in later queries.

## Gap 1

```sql

CREATE TABLE __gap_1

SELECT 
  *,
  IF
  (
    @a = anopat
      AND @z = zinr
      AND @d = doses
      AND prev_stop IS NOT NULL,
    TIMESTAMPDIFF(DAY, prev_stop, startdat - interval 1 day),
    null
  ) AS gap, 
  @z := zinr,
  @a := anopat,
  @d := doses
FROM __gap_1_a
ORDER BY anopat, zinr, afldat

```

This query uses `__gap_1` as its source of data, where it takes all fields and returned four additional fields:

- `gap` which tests for the assigned variables against the following conditions:
  - Conditions:
    - `@a` == `anopat`
    - `@z` == `zinr`
    - `@d` == `doses`
    - `prev_stop` is not a null
  - On success: Return a date time difference of the `prev_stop` and (`startdat` - 1 day)
  - On failure: Return a null
- `@z` which takes the value of `zinr`
- `@a` which takes the value of `anopat`
- `@d` which takes the value of `doses`

## Gap

```sql

CREATE TABLE __gap

SELECT
  jaar,
  recnr,
  anopat,
  Zinr,
  Afldat,
  Aantal,
  eenheid,
  Dagdos,
  VK,
  Arts,
  ATC,
  Nddd,
  Ndgn,
  doses,
  startdat,
  stopdat,
  gap,
IF(gap is null, @sum_gap := 0, @sum_gap:= IFNULL(@sum_gap,0) + gap) total_gap
FROM __gap_1

```

This query uses `__gap_1` as its source of data, where it takes only the necessary fields and returning one additional field:

- `total_gap` which tests the `gap` against the following condition:
  - Condition: `gap` is null
  - On success: Set the `@sum_gap` as 0
  - On failure: Increment the `@sum_gap` by the number of `gap`

## Gap corrected

```sql

CREATE TABLE __gap_corrected(INDEX(anopat), INDEX(ATC), INDEX(Zinr)) 

SELECT  
  jaar, 
  recnr, 
  anopat, 
  Zinr,     
  Afldat,     
  Aantal,  
  eenheid, 
  Dagdos,    
  Vk,   
  Arts, 
  ATC,     
  Nddd,   
  Ndgn, 
  doses,
  startdat,   
  stopdat,    
  gap, 
  IF(gap IS NULL, 0, IF(@g + gap > 0, 0, IF(@g + gap < -10000, 0,  @g + gap))) sum_gapp,
  @g := IF(gap IS NULL, 0, IF(@g + gap > 0, 0, IF(@g + gap < -10000, 0,  @g + gap))) test
FROM __gap
ORDER BY anopat, zinr, afldat

UPDATE __gap_corrected 
SET corrected_startdat = startdat + interval (-1 * sum_gapp) day, 
corrected_stopdat = stopdat + interval (-1 * sum_gapp) day

```

This query uses `__gap` as its source of data and return two additional fields:

- `sum_gapp` which test for the following condition:
  - Condition: `gap` is null
  - On success: Return 0
  - On failure: Test for the following condition:
    - Condition: `@g` + `gap` > 0
    - On success: Return 0
    - On failure: Test for the following condition:
      - Condition: `@g` + `gap` < -10000
      - On success: Return 0
      - On failure: `@g` + `gap`
  - Side note: This step is intended to correct the value of the `total_gap`, for when if `gap` is not null and within a realistic scale, it will be added to the value of `@g`
- `test` which takes the value of `@g`, an assigned variables coming from the condition set above (see explanation on `sum_gapp`)

## Shifted 1

```sql

CREATE TABLE shifted_1(INDEX(anopat), INDEX(ATC), INDEX(Zinr), INDEX(startdat), INDEX(stopdat)) 

SELECT  
  jaar, 
  recnr, 
  anopat, 
  Zinr,     
  Afldat,     
  Aantal,  
  eenheid, 
  Dagdos,    
  Vk,   
  Arts, 
  ATC,     
  Nddd,   
  Ndgn, 
  doses,
  corrected_startdat startdat,   
  corrected_stopdat stopdat    
FROM __gap_corrected
ORDER BY anopat, startdat

```

This query uses `__gap_corrected` data as its source then it replaced `startdat` and `stopdat` with `corrected_startdat` and `corrected_stopdat` respectively.

## Persistence A

```sql

CREATE TABLE persistence_a(INDEX(anopat), INDEX(zinr), INDEX(startdat), index(doses))

SELECT 
  *,
  @d prev_stop,
  @d := stopdat tmp
FROM shifted_1 
ORDER BY anopat, startdat

```

This query use `shifted_1` as its source, taking all the fields and returning two additional fields:

- `prev_stop` from `@d`
- `tmp` from `@d`, an assigned variable containing `stopdat`

## Persistence B

```sql

CREATE TABLE persistence_b

SELECT 
  a.*,
  IF
  (
    (prev_stop = '0001-01-01') OR (@a != anopat),
    null,
    IF
    (
      -1 * (TIMESTAMPDIFF(DAY, startdat, prev_stop)+1)<0,
      0,
      -1 * (TIMESTAMPDIFF(DAY, startdat, prev_stop)+1)
    )
  ) gap,
  @at := atc,
  @a := anopat
FROM persistence_a a
ORDER BY anopat, startdat

```

This query uses `persistence_a` as its source, returning three additional fields:

- `@at` as a variable assigned to contain `atc`
- `@a` as a variable assigned to contain `anopat`
- `gap` which test for the following condition:
  - Condition: Semantically undefined `prev_stop` (`0001-01-01`) OR variable `@a` does not hold the same value as `anopat`
  - On success: Return `null`, implying data incoherence
  - On failure: Test for the following condition:
    - Condition: (1 + `prev_stop` - `startdat`) < 0
    - On success: Return 0
    - On failure: Return -1 * (1 + `prev_stop` - `startdat`)

## Persistence

```sql

CREATE  TABLE persistence2

SELECT
  jaar,
  recnr,
  anopat,
  Zinr,
  Afldat,
  Aantal,
  eenheid,
  Dagdos,
  VK,
  Arts,
  ATC,
  Nddd,
  Ndgn,
  doses,
  startdat,
  stopdat,
  gap,
IF(gap is null, @sum_gap := 0, @sum_gap:= IFNULL(@sum_gap,0) + gap) total_gap
FROM persistence_b

```

This query uses `persistence_b` as its source, returning one additional field:

- `total_gap` which test for the following condition:
  - Condition: `gap` is `null`
  - On success: Set the variable `@sum_gap` as 0
  - On failure: Increment the value of variable `@sum_gap` by `gap`
