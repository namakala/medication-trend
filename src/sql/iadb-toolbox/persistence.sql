-- Extended Prescription
CREATE TEMPORARY TABLE __extendedPrescription(INDEX(anopat), INDEX(afldat), INDEX(doses))
SELECT 
  *, 
  afldat AS startdat,
  afldat + interval IFNULL(Ndgn,0) DAY AS stopdat,
  IF(IFNULL(Ndgn,0) <> 0, ROUND(Nddd/Ndgn,1), NULL) doses
FROM recept
WHERE ((LEFT(ATC,3) IN ("N01", "N02", "N03", "N04", "N05", "N06", "N07")))
AND afldat BETWEEN '1994-01-01' AND '2022-12-31'
ORDER BY anopat, zinr, afldat

-- Gap 1A
CREATE TEMPORARY TABLE __gap_1_a(INDEX(anopat), INDEX(zinr), INDEX(startdat), index(doses))
SELECT 
  *,
  @d prev_stop,
  @d := stopdat tmp
FROM __extendedPrescription 
ORDER BY anopat, zinr, afldat

-- Gap 1
CREATE TEMPORARY TABLE __gap_1
SELECT 
  *,
  IF(@a = anopat AND @z = zinr AND @d = doses AND prev_stop IS NOT NULL, TIMESTAMPDIFF(DAY, prev_stop, startdat - interval 1 day), null) gap, 
  @z := zinr,
  @a := anopat,
  @d := doses
FROM __gap_1_a
ORDER BY anopat, zinr, afldat

-- Gap
CREATE TEMPORARY TABLE __gap
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

-- Gap corrected
CREATE TEMPORARY TABLE __gap_corrected(INDEX(anopat), INDEX(ATC), INDEX(Zinr)) 
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

-- Shifted 1
CREATE TEMPORARY TABLE shifted_1(INDEX(anopat), INDEX(ATC), INDEX(Zinr), INDEX(startdat), INDEX(stopdat)) 
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

-- Persistence A
CREATE TEMPORARY TABLE persistence_a(INDEX(anopat), INDEX(zinr), INDEX(startdat), index(doses))
SELECT 
  *,
  @d prev_stop,
  @d := stopdat tmp
FROM shifted_1 
ORDER BY anopat, startdat

-- Persistence B
CREATE TEMPORARY TABLE persistence_b
SELECT 
  a.*,
  IF((prev_stop = '0001-01-01') OR (@a != anopat), null, IF(-1 * (TIMESTAMPDIFF(DAY, startdat, prev_stop)+1)<0, 0, -1 * (TIMESTAMPDIFF(DAY, startdat, prev_stop)+1))) gap,
  @at := atc,
  @a := anopat
FROM persistence_a a
ORDER BY anopat, startdat

-- Persistence
CREATE  TABLE persistence
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
