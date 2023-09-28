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

WITH __extendedPrescription AS
(
  SELECT 
    *, 
    afldat AS startdat,
    afldat + interval IFNULL(Ndgn,0) DAY AS stopdat,
    IF(IFNULL(ndgn, 0) <> 0, ROUND(nddd/ndgn, 1), NULL) AS doses
  FROM recept
  ORDER BY anopat, zinr, afldat
)

```

This table uses `recept` as its source of data, where it takes all values from `recept` and returned three additional fields:

- `startdat`: The start date of observation as obtained from `afldat`, i.e. the date of medication claim
- `stopdat`: The end date of observation, obtained by adding `ndgn` (days of medication uses) to `afldat`
- `doses`: The dose of claimed medication, obtained by dividing `nddd` (recommended maximum dose throughout medication uses) to `ndgn` (number of days taking the medicine)

The table is ordered by:

- `anopat`: Unique patient identifier
- `zinr`:
- `afldat`: Date of medication claim

## Gap 1A
