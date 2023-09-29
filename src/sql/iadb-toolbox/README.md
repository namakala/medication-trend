# Persistence Query

The query creates xx tables:

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

CREATE TEMPORARY TABLE __gap_1_a(INDEX(anopat), INDEX(zinr), INDEX(startdat), index(doses))

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

CREATE TEMPORARY TABLE __gap_1

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

This query uses `__gap_1` as its source of data, where it takes all fields and returned two additional fields:

## Gap

## Gap corrected

## Shifted 1

## Persistence A

## Persistence B

## Persistence

