CREATE TEMPORARY TABLE `rectmp1` (
          `rijnr` int(10) unsigned NOT NULL AUTO_INCREMENT,
          `anopat` int(9) unsigned zerofill DEFAULT NULL,
          `afldat` date NOT NULL,
          `jaar` int(4),
          `atc` char(7) DEFAULT NULL,
          `nddd` float(9,3) DEFAULT NULL,
          `ndagen` int(6) DEFAULT NULL,
          `edat` date NOT NULL,
          `ldat` date NOT NULL,
          `gebdat` date NOT NULL,
          `enddat` date NOT NULL,
          PRIMARY KEY (`rijnr`),
          KEY `anopat` (`anopat`),
          KEY `afldat` (`afldat`),
          KEY `edat` (`edat`),
          KEY `enddat` (`enddat`),
          KEY `rijnr` (`rijnr`)
        ) DEFAULT CHARSET=utf8

/*
Query OK, 0 rows affected. Records: 0 Warnings: 0 rectmp1 created: Rows: 0, records: 0, warnings: 0
*/

INSERT INTO rectmp1
        SELECT 
        NULL,
        p.anopat,
        afldat,
        year(afldat) jaar,
        atc,
        nddd,
        ndgn ndagen,
        edat,
        ldat,
        gebdat,
        afldat + interval IFNULL(ndgn,0) day enddat 
        FROM recept p INNER JOIN patient r ON(p.anopat = r.anopat)
        WHERE (ATC IN ("N06AB02", "N06AB03", "N06AB04", "N06AB05", "N06AB06", "N06AB07", "N06AB08", "N06AB09", "N06AB10")) 
        ORDER BY anopat, enddat

/*
rectmp1 filled: Rows: 1460457, records: 1460457, warnings: 0
Copy tableQuery OK, 0 rows affected. Records: 0 Warnings: 1 Warning: 1051: Unknown table 'fe_alylam_psych_con.rectmp2' Query OK, 0 rows affected. Records: 0 Warnings: 0 Query OK, 1460457 rows affected. Records: 1460457 Warnings: 0
We gaan de fout start tabel maken
Warning: 1051: Unknown table 'fe_alylam_psych_con.fout_start'
*/

CREATE TEMPORARY  TABLE fout_start(PRIMARY KEY(rijnr))
          SELECT
          b.*
          FROM rectmp1 a INNER JOIN rectmp2 b USING(anopat)
          WHERE a.rijnr = b.rijnr - 1
          AND ( (TIMESTAMPDIFF(DAY, a.enddat, b.afldat) < 90) OR (a.afldat > b.afldat) )
          GROUP BY b.jaar, b.rijnr

/*
Query OK, 1378086 rows affected. Records: 1378086 Warnings: 0 Table fout_start created: Rows: 1378086, records: 1378086, warnings: 0

We gaan de fout stop tabel maken
Warning: 1051: Unknown table 'fe_alylam_psych_con.fout_stop'
*/

CREATE TEMPORARY TABLE fout_stop(PRIMARY KEY(rijnr))
          SELECT
          a.*
          FROM rectmp1 a INNER JOIN rectmp2 b USING(anopat)
          WHERE a.rijnr = b.rijnr - 1
          AND ( (TIMESTAMPDIFF(DAY, a.enddat, b.afldat) < 90) OR (a.afldat > b.afldat) )
          GROUP BY a.jaar, a.rijnr

/*
Table fout_stop created: Rows: 1378086, records: 1378086, warnings: 0
Warning: 1051: Unknown table 'fe_alylam_psych_con.start_good'
*/


        CREATE TEMPORARY TABLE start_good(INDEX(anopat))
        SELECT
        r.*
        FROM rectmp1 r LEFT JOIN fout_start f USING(rijnr)
        WHERE f.anopat IS NULL
        #AND TIMESTAMPDIFF(DAY, r.edat, r.afldat) > 90
        GROUP BY r.jaar, r.rijnr

/*
Table start_good created: Rows: 82371, records: 82371, warnings: 0
Warning: 1051: Unknown table 'fe_alylam_psych_con.stop_good'
*/


        CREATE TEMPORARY TABLE stop_good(INDEX(anopat))
        SELECT
        r.*
        FROM rectmp1 r LEFT JOIN fout_stop f USING(rijnr)
        WHERE f.anopat IS NULL
        #AND TIMESTAMPDIFF(DAY, r.edat, r.afldat) > 90
        GROUP BY r.jaar, r.rijnr

/*
Table stop_good created: Rows: 82371, records: 82371, warnings: 0
Warning: 1051: Unknown table 'fe_alylam_psych_con.combined_goods'
*/


        CREATE TEMPORARY TABLE combined_goods(
          `rn` int(10) unsigned NOT NULL AUTO_INCREMENT,
          `rijnr` int(10) unsigned NOT NULL DEFAULT 0,
          `anopat` int(10) unsigned DEFAULT NULL,
          `afldat` date NOT NULL DEFAULT '0000-00-00',
          `jaar` int(11) DEFAULT NULL,
          `atc` char(7) CHARACTER SET utf8 DEFAULT NULL,
          `nddd` float(10,4) DEFAULT NULL,
          `ndagen` int(11) DEFAULT NULL,
          `edat` date NOT NULL DEFAULT '0000-00-00',
          `ldat` date NOT NULL DEFAULT '0000-00-00',
          `gebdat` date NOT NULL DEFAULT '0000-00-00',
          `enddat` date NOT NULL DEFAULT '0000-00-00',
          `start_stop` decimal(32,0) DEFAULT NULL,
          PRIMARY KEY (`rn`))
        

/* 
Table combined_goods created: Rows: 0, records: 0, warnings: 0
*/


        INSERT INTO combined_goods
          SELECT 
          null,
          rijnr, 
          anopat,
          afldat, 
          jaar,
          atc,
          nddd,
          ndagen,
          edat,
          ldat,
          gebdat,
          enddat,
          start_stop
        FROM (
          SELECT *, 1 start_stop from start_good 
          UNION ALL 
          SELECT *, 2 FROM stop_good
        )a  
        #GROUP BY rijnr 
        ORDER BY rijnr, start_stop

/*
Query OK, 164742 rows affected. Records: 164742 Warnings: 0 Table combined_goods filled: Rows: 164742, records: 164742, warnings: 0
Copy tableQuery OK, 0 rows affected. Records: 0 Warnings: 1 Warning: 1051: Unknown table 'fe_alylam_psych_con.combined_goods1' Query OK, 0 rows affected. Records: 0 Warnings: 0 Query OK, 164742 rows affected. Records: 164742 Warnings: 0
*/

 
        CREATE TABLE `periods_of_use` (
        `anopat` int(9) unsigned zerofill,
        `startdat` date NOT NULL DEFAULT '0000-00-00',
        `stopdat` date NOT NULL DEFAULT '0000-00-00',
        `startAtc` char(7) CHARACTER SET utf8 DEFAULT NULL,
        `prescriptions`int(4) unsigned NOT NULL,
        `edat` date NOT NULL DEFAULT '0000-00-00',
        `ldat` date NOT NULL DEFAULT '0000-00-00',
        `gebdat` date NOT NULL DEFAULT '0000-00-00',
        `start_event` int(1) unsigned DEFAULT 0,
        `stop_event` int(1) unsigned DEFAULT 0,
        KEY `anopat` (`anopat`)
      )

/*
Table periods_of_use created: Rows: 0, records: 0, warnings: 0
*/


        INSERT INTO periods_of_use
        SELECT 
          a.anopat, 
          a.afldat startdat, 
          b.enddat stopdat, # + interval b.ndagen day stopdat, 
          a.atc startAtc,
          (b.rijnr - a.rijnr) + 1 prescriptions,   
          a.edat, 
          a.ldat, 
          a.gebdat,
          TIMESTAMPDIFF(DAY, a.edat, a.afldat) > 90,
          TIMESTAMPDIFF(DAY, b.enddat, a.ldat) > 90
        FROM combined_goods a INNER JOIN combined_goods1 b ON a.rn = b.rn-1 
        WHERE (a.start_stop = 1 AND b.start_stop = 2)  
        

/*
Table periods_of_use filled: Rows: 82371, records: 82371, warnings: 0 
*/
