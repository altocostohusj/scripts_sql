
-- resolucion 202 v.2

DECLARE @from DATETIME = '20260125', @to DATETIME = '20260201';

-- 1) Para las 3 categorías que provienen de diagnósticos (gestante / aborto / parto)
;WITH 

Nombres as (
	SELECT DISTINCT
		GENPACIEN.PACNUMDOC
		, 'NOMBRES' AS etiqueta
		, CASE WHEN TRIM(GENPACIEN.PACPRIAPE) = '' THEN 'NONE'
			ELSE
				REPLACE(
					TRANSLATE(
						TRIM(GENPACIEN.PACPRIAPE), 
							'áéíóúÁÉÍÓÚñÑ', 
							'aeiouAEIOUNN'
						),
						' ', 
						''
					)
			END AS tip0
		, CASE 
				WHEN TRIM(GENPACIEN.PACSEGAPE) = '' THEN 'NONE'
				ELSE
					REPLACE(
						TRANSLATE(
							TRIM(GENPACIEN.PACSEGAPE), 
							'áéíóúÁÉÍÓÚñÑ', 
							'aeiouAEIOUNN'
						),
						' ', 
						''
					)
			END AS tip
		, CASE 
				WHEN TRIM(GENPACIEN.PACPRINOM) = '' THEN 'NONE'
				ELSE
					REPLACE(
						TRANSLATE(
							TRIM(GENPACIEN.PACPRINOM), 
							'áéíóúÁÉÍÓÚñÑ', 
							'aeiouAEIOUNN'
						),
						' ', 
						''
					)
			END AS tip1
		, CASE 
				WHEN TRIM(GENPACIEN.PACSEGNOM) = '' THEN 'NONE'
				ELSE
					REPLACE(
						TRANSLATE(
							TRIM(GENPACIEN.PACSEGNOM), 
							'áéíóúÁÉÍÓÚñÑ', 
							'aeiouAEIOUNN'
						),
						' ', 
						''
					)
			END AS tip2
	FROM ADNINGRESO
		INNER JOIN GENPACIEN ON ADNINGRESO.GENPACIEN = GENPACIEN.OID
	WHERE 
		ADNINGRESO.AINFECING BETWEEN @from AND @to
),

Datosidentificac as (
	SELECT DISTINCT
		GENPACIEN.PACNUMDOC
		, 'DATOSBASICOS' AS etiqueta
		, ISNULL(CAST(DATEDIFF(YEAR, GENPACIEN.GPAFECNAC, ADNINGRESO.AINFECING) - CASE WHEN (MONTH(GENPACIEN.GPAFECNAC) > MONTH(ADNINGRESO.AINFECING) OR  (MONTH(GENPACIEN.GPAFECNAC) = MONTH(ADNINGRESO.AINFECING) AND DAY(GENPACIEN.GPAFECNAC) > DAY(ADNINGRESO.AINFECING))) THEN 1 ELSE 0 END AS VARCHAR(20)), '') AS tip0 
		, CASE GENPACIEN.PACTIPDOC WHEN 1 THEN 'CC' WHEN 2 THEN 'CE' WHEN 3 THEN 'TI' WHEN 4 THEN 'RC' WHEN 5 THEN 'PA' WHEN 6 THEN 'AS' WHEN 7 THEN 'MS' WHEN 8 THEN 'NU' WHEN 10 THEN 'CN' WHEN 12 THEN 'PE' WHEN 14 THEN 'PE' WHEN 15 THEN 'PE' WHEN 9 THEN 'PE' ELSE 'NONE' END AS tip
		, FORMAT(GENPACIEN.GPAFECNAC, 'yyyy-MM-dd', 'en-us') AS tip1
		, CASE WHEN GENPACIEN.GPASEXPAC = 1 THEN 'M' WHEN GENPACIEN.GPASEXPAC = 2 THEN 'F' ELSE NULL END AS tip2
	FROM ADNINGRESO
		INNER JOIN GENPACIEN ON ADNINGRESO.GENPACIEN = GENPACIEN.OID
	WHERE 
		ADNINGRESO.AINFECING BETWEEN @from AND @to
),

Etniaeduca as (
	SELECT DISTINCT
		GENPACIEN.PACNUMDOC
		, 'ETNIA_EDUCA' AS etiqueta
		, CASE ADNGRUETN.ADGECODIGO WHEN 06 THEN '5' WHEN 07 THEN '6' WHEN 05 THEN '5' ELSE '6' END AS tip0
		, TRY_CAST(adinfpaci AS XML).value('(/HCCLInfoPaciente/@CODOCUPA)[1]', 'nvarchar(400)') AS tip
		, TRY_CAST(adinfpaci AS XML).value('(/HCCLInfoPaciente/@NOMOCUPA)[1]', 'nvarchar(400)') AS tip1
		, CASE GENCARGO.GCACODIGO
			WHEN 005 THEN '1'
			WHEN 006 THEN '2'
			WHEN 007 THEN '3'
			WHEN 008 THEN '4'
			WHEN 009 THEN '5'
			WHEN 010 THEN '6'
			WHEN 011 THEN '7'
			WHEN 012 THEN '8'
			WHEN 003 THEN '8'
			WHEN 013 THEN '9'
			WHEN 001 THEN '9'
			WHEN 002 THEN '10'
			WHEN 014 THEN '10'
			WHEN 015 THEN '11'
			WHEN 016 THEN '12'
			WHEN 999 THEN '13'
			WHEN 004 THEN '13'
		ELSE '13'
		END AS tip2
	FROM ADNINGRESO
		INNER JOIN GENPACIEN ON ADNINGRESO.GENPACIEN = GENPACIEN.OID
		LEFT JOIN ADNGRUETN ON GENPACIEN.ADNGRUETN = ADNGRUETN.ADGGRUETN --ETNIA--
		LEFT JOIN GENCARGO on GENPACIEN.GENCARGO1 = GENCARGO.OID --NIVEL EDUCATIVO--
	WHERE 
		ADNINGRESO.AINFECING BETWEEN @from AND @to
),

Eapb_Pais as (
	SELECT DISTINCT
		GENPACIEN.PACNUMDOC
		, 'EAPB_PAIS' AS etiqueta
		, GENPAISES.GPACODNUM AS tip0
		, CASE GENDETCON.GDETIPREG
			WHEN 0 THEN 'Ninguno'
			WHEN 1 THEN 'Contributivo'
			WHEN 2 THEN 'Subsidiado'
			WHEN 3 THEN 'Excepción'
			WHEN 4 THEN 'Especial'
			WHEN 5 THEN 'No asegurado' 
		END as tip
		, GENDETCON.GDENOMBRE tip1
		, '' tip2
	FROM ADNINGRESO
		INNER JOIN GENPACIEN ON ADNINGRESO.GENPACIEN = GENPACIEN.OID
		LEFT JOIN GENDETCON ON GENDETCON.OID = GENPACIEN.GENDETCON --EAPB--
		LEFT JOIN GENPAISES ON GENPACIEN.GENPAIS = GENPAISES.OID--PAIS--
	WHERE 
		ADNINGRESO.AINFECING BETWEEN @from AND @to
),

GestanteCTE AS (
    SELECT DISTINCT
        t.PACNUMDOC
		, 'Gestante' AS etiqueta
		, CONCAT('Folio:', t.HCNUMFOL) AS tip0, '' tip, '' tip2, '' tip3
    FROM (
        SELECT
            p.PACNUMDOC
			, f.HCNUMFOL
			, ROW_NUMBER() OVER (PARTITION BY p.PACNUMDOC ORDER BY f.HCFECFOL DESC, f.HCNUMFOL DESC) AS rn
        FROM ADNINGRESO a
			JOIN GENPACIEN p ON a.GENPACIEN = p.OID
			JOIN HCNFOLIO f ON f.ADNINGRESO = a.OID
			JOIN HCNDIAPAC h ON h.HCNFOLIO = f.OID
			JOIN GENDIAGNO g ON g.OID = h.GENDIAGNO
        WHERE f.HCFECFOL BETWEEN @from AND @to
			AND p.GPASEXPAC = 2
			AND g.DIACODIGO IN (
            -- lista completa de códigos de "Gestante" 
            'O100','O101','O102','O103','O104','O109','O11X','O120','O121','O122','O13X','O140','O141','O142','O149',
            'O150','O151','O152','O159','O16X','O200','O208','O209','O210','O211','O212','O218','O219','O220','O221',
            'O222','O223','O224','O225','O228','O229','O230','O231','O232','O233','O234','O235','O239','O240','O241',
            'O242','O243','O244','O249','O25X','O260','O261','O262','O263','O264','O265','O266','O267','O268','O269',
            'O280','O281','O282','O283','O284','O285','O288','O289','O290','O291','O292','O293','O294','O295','O296',
            'O298','O299','O300','O301','O302','O308','O309','O311','O318','O320','O321','O322','O323','O324','O325',
            'O326','O328','O329','O330','O331','O332','O333','O334','O335','O336','O337','O338','O339','O340','O341',
            'O342','O343','O344','O345','O346','O347','O348','O349','O350','O351','O352','O353','O354','O355','O356',
            'O357','O358','O359','O360','O361','O362','O363','O365','O366','O367','O368','O369','O40X','O410','O411',
            'O418','O419','O420','O421','O422','O429','O430','O431','O432','O438','O439','O450','O458','O459','O470',
            'O471','O479','O48X','O710','O712','O715','O716','O717','O718','O719','O880','O881','O882','O883','O888',
            'O93X','O980','O981','O982','O983','O984','O985','O986','O987','O988','O989','O990','O991','O992','O993',
            'O994','O995','O996','O997','O998','P080','P081','P082','Z321','Z33X','Z340','Z348','Z349','Z350','Z351',
            'Z352','Z353','Z354','Z355','Z356','Z357','Z358','Z359','Z640'
          )
    ) t
    WHERE t.rn = 1
),

AbortoCTE AS (
    SELECT
        t.PACNUMDOC
		, 'Aborto' AS etiqueta
		, CONCAT('Folio:', t.HCNUMFOL) AS tip0 , '' tip , '' tip2 , '' tip3
    FROM (
        SELECT
            p.PACNUMDOC
			, f.HCNUMFOL
			, ROW_NUMBER() OVER (PARTITION BY p.PACNUMDOC ORDER BY f.HCFECFOL DESC, f.HCNUMFOL DESC) AS rn
        FROM ADNINGRESO a
			JOIN GENPACIEN p ON a.GENPACIEN = p.OID
			JOIN HCNFOLIO f ON f.ADNINGRESO = a.OID
			JOIN HCNDIAPAC h ON h.HCNFOLIO = f.OID
			JOIN GENDIAGNO g ON g.OID = h.GENDIAGNO
        WHERE f.HCFECFOL BETWEEN @from AND @to
			AND p.GPASEXPAC = 2
			AND g.DIACODIGO IN (
            -- lista completa de códigos "Aborto"
            'O000','O001','O002','O008','O009','O010','O011','O019','O020','O021','O028','O029','O030','O031','O032',
            'O033','O034','O035','O036','O037','O038','O039','O040','O041','O042','O043','O044','O045','O046','O047',
            'O048','O049','O050','O051','O052','O053','O054','O055','O056','O057','O058','O059','O060','O061','O062',
            'O063','O064','O065','O066','O067','O068','O069','O070','O071','O072','O073','O074','O075','O076','O077',
            'O078','O079','O080','O081','O082','O083','O084','O085','O086','O087','O088','O089','O312','O364','P964'
          )
    ) t
    WHERE t.rn = 1
),

PartoCTE AS (
    SELECT
        t.PACNUMDOC
		, 'Parto' AS etiqueta
		, CONCAT('Folio:', t.HCNUMFOL) AS tip0 , '' tip , '' tip2 , '' tip3
    FROM (
        SELECT
            p.PACNUMDOC
			, f.HCNUMFOL
			, ROW_NUMBER() OVER (PARTITION BY p.PACNUMDOC ORDER BY f.HCFECFOL DESC, f.HCNUMFOL DESC) AS rn
        FROM ADNINGRESO a
			JOIN GENPACIEN p ON a.GENPACIEN = p.OID
			JOIN HCNFOLIO f ON f.ADNINGRESO = a.OID
			JOIN HCNDIAPAC h ON h.HCNFOLIO = f.OID
			JOIN GENDIAGNO g ON g.OID = h.GENDIAGNO
        WHERE f.HCFECFOL BETWEEN @from AND @to
			AND p.GPASEXPAC = 2
			AND g.DIACODIGO IN (
            -- lista completa de códigos "Parto" 
            'O95X','O960','O961','O969','O970','O971','O979','O310','O440','O441','O460','O468','O469','O600','O601','O602',
            'O603','O60X','O610','O611','O618','O619','O620','O621','O622','O623','O624','O628','O629','O630','O631','O632',
            'O639','O640','O641','O642','O643','O644','O645','O648','O649','O650','O651','O652','O653','O654','O655','O658',
            'O659','O660','O661','O662','O663','O664','O665','O668','O669','O670','O678','O679','O680','O681','O682','O683',
            'O688','O689','O690','O691','O692','O693','O694','O695','O698','O699','O700','O701','O702','O703','O709','O711',
            'O713','O714','O720','O721','O722','O723','O730','O731','O740','O741','O742','O743','O744','O745','O746','O747',
            'O748','O749','O750','O751','O752','O753','O754','O755','O756','O757','O758','O759','O800','O801','O808','O809',
            'O810','O811','O812','O813','O814','O815','O820','O821','O822','O828','O829','O830','O831','O832','O833','O834',
            'O838','O839','O840','O841','O842','O848','O849','O85X','O860','O861','O862','O863','O864','O868','O870','O871',
            'O872','O873','O878','O879','O890','O891','O892','O893','O894','O895','O896','O898','O899','O900','O901','O902',
            'O903','O904','O905','O908','O909','O910','O911','O912','O920','O921','O922','O923','O924','O925','O926','O927',
            'O94X'
          )
    ) t
    WHERE t.rn = 1
),

-- 2) Negativo (resultado de laboratorio), tomar el último resultado negativo por paciente
NegativoCTE AS (
    SELECT
        t.PACNUMDOC
		, 'Negativo' AS etiqueta
		, CONCAT('Resultado Laboratorio Nombre: ', t.SIPNOMBRE) AS tip0 , '' tip , '' tip2 , '' tip3
    FROM (
        SELECT
            p.PACNUMDOC
			, f.HCNUMFOL
			, g.SIPNOMBRE
			, ROW_NUMBER() OVER (
                PARTITION BY p.PACNUMDOC
                ORDER BY TRY_CONVERT(DATETIME, r.HCRFECRES, 120) DESC
            ) AS rn
        FROM ADNINGRESO a
			JOIN GENPACIEN p ON a.GENPACIEN = p.OID
			JOIN HCNFOLIO f ON f.ADNINGRESO = a.OID
			JOIN HCNSOLEXA s ON s.HCNFOLIO = f.OID
			JOIN HCNRESEXA r ON r.HCNSOLEXA = s.OID
			JOIN GENSERIPS g ON g.OID = s.GENSERIPS
        WHERE g.SIPCODCUP IN ('906625','904508')
			AND LOWER(r.HCRDESCRIP) LIKE '%nega%'
			AND TRY_CONVERT(DATETIME, r.HCRFECRES,120)
				BETWEEN @from AND @to
    ) t
    WHERE t.rn = 1
),

-- 3) Planificacion por procedimiento QX (último por paciente)
PlanifQXCTE AS (
    SELECT DISTINCT
        p.PACNUMDOC
		, 'emergencia' AS etiqueta
        , CONCAT('Resultado Laboratorio Nombre: ', g.SIPNOMBRE) AS tip0
		, '13' tip
		, g.SIPDESCUP tip2 , '' tip3
    FROM ADNINGRESO a
		JOIN GENPACIEN p ON a.GENPACIEN = p.OID
		JOIN HCNFOLIO f ON f.ADNINGRESO = a.OID
		JOIN HCNQXEPAC q ON q.HCNFOLIO = f.OID
		JOIN GENSERIPS g ON q.GENSERIPS = g.OID
    WHERE f.HCFECFOL BETWEEN @from AND @to
      AND (
         LOWER(g.SIPDESCUP) LIKE '%legrad%'
         OR LOWER(g.SIPDESCUP) LIKE '%histerecto%'
      )
),

PlanifQXCTEDOS AS (
    SELECT DISTINCT
        p.PACNUMDOC
		, 'Planificacion' AS etiqueta
        , CONCAT('Resultado Laboratorio Nombre: ', g.SIPNOMBRE) AS tip0
		, '13' tip
		, g.SIPDESCUP tip2 , '' tip3
    FROM ADNINGRESO a
		JOIN GENPACIEN p ON a.GENPACIEN = p.OID
		JOIN HCNFOLIO f ON f.ADNINGRESO = a.OID
		JOIN HCNQXEPAC q ON q.HCNFOLIO = f.OID
		JOIN GENSERIPS g ON q.GENSERIPS = g.OID
    WHERE f.HCFECFOL BETWEEN @from AND @to
      AND (
         LOWER(g.SIPDESCUP) LIKE '%ablacion u oclusion de trompa%'
         OR LOWER(g.SIPDESCUP) LIKE '%dispositivo en trompa%'
      )
),

-- 4) Planificacion por medicamento (último por paciente)
PlanifMedCTE AS (
    SELECT
        p.PACNUMDOC
		, 'Planificacion' AS etiqueta
		--, CONCAT('Resultado Laboratorio Nombre: ', i.IPRDESLAR) AS prueba
		, FORMAT(f.HCFECFOL, 'yyyy-MM-dd', 'en-us') tip0
		, CASE i.IPRCODALT
				WHEN '20175926-2' THEN 'no def'
				WHEN '19969493-01' THEN '3'
				WHEN '19934015-2' THEN '3'
				WHEN '19989785-06' THEN '5'
			ELSE i.IPRCODALT
			END tip
		, i.IPRDESCOR tip2 -------------
		, '' tip3
    FROM ADNINGRESO a
		JOIN GENPACIEN p ON a.GENPACIEN = p.OID
		JOIN HCNFOLIO f ON f.ADNINGRESO = a.OID
		JOIN HCNMEDPAC m ON m.HCNFOLIO = f.OID
		JOIN INNPRODUC i ON m.INNPRODUC = i.OID
    WHERE f.HCFECFOL BETWEEN @from AND @to
		AND m.HCSINTRAH = 1
		AND (
			LOWER(i.IPRDESCOR) LIKE '%levonorgestrel%'
			 OR LOWER(i.IPRDESCOR) LIKE '%etonogestrel%'
			 OR LOWER(i.IPRDESCOR) LIKE '%medroxiprogesterona%'
			 --OR LOWER(i.IPRDESCOR) LIKE '%goserelina%'
			 --OR LOWER(i.IPRDESCOR) LIKE '%misoprostol%'
			 OR LOWER(i.IPRDESCOR) LIKE '%cond%'
      )
),

--- de emergencia
PlanifMedCTEDOS AS (
    SELECT
        p.PACNUMDOC
		, 'emergencia' AS etiqueta
		--, CONCAT('Resultado Laboratorio Nombre: ', i.IPRDESLAR) AS prueba
		, FORMAT(f.HCFECFOL, 'yyyy-MM-dd', 'en-us') tip0
		, i.IPRCODIGO tip
		, i.IPRDESCOR tip2 -------------
		, '' tip3
    FROM ADNINGRESO a
		JOIN GENPACIEN p ON a.GENPACIEN = p.OID
		JOIN HCNFOLIO f ON f.ADNINGRESO = a.OID
		JOIN HCNMEDPAC m ON m.HCNFOLIO = f.OID
		JOIN INNPRODUC i ON m.INNPRODUC = i.OID
    WHERE f.HCFECFOL BETWEEN @from AND @to
		AND m.HCSINTRAH = 1
		AND (
			 LOWER(i.IPRDESCOR) LIKE '%misoprostol%'
      )
),

-- 5) Parto por folio (tipo historia)
PartoFolioCTE AS (
    SELECT DISTINCT
        p.PACNUMDOC
		, 'Parto Folio' AS etiqueta
		, FORMAT(f.HCFECFOL, 'yyyy-MM-dd', 'en-us') AS tip0
		, FORMAT(ADNINGRESO.AINFECEGRE, 'yyyy-MM-dd', 'en-us') AS tip
		, '' tip2 , '' tip3
    FROM ADNINGRESO
		JOIN GENPACIEN p ON ADNINGRESO.GENPACIEN = p.OID
		JOIN HCNFOLIO f ON f.ADNINGRESO = ADNINGRESO.OID
		LEFT JOIN HCNTIPHIS t ON f.HCNTIPHIS = t.OID
    WHERE f.HCFECFOL BETWEEN @from AND @to
		AND t.HCCODIGO IN ('HC06','HC57')
),

Examenes AS (
		SELECT DISTINCT
		-- Extrae todos los examenes que se reportan en la institucion
			GENPACIEN.PACNUMDOC
			, case GENSERIPS.SIPCODCUP 
				--WHEN '904903' THEN 'TSH' WHEN '904904' THEN 'TSH' WHEN '904902' THEN 'TSH' WHEN '904912' THEN 'TSH'
				WHEN '908806' THEN 'HEPATITIS_B' WHEN '906223' THEN 'HEPATITIS_B' WHEN '906317' THEN 'HEPATITIS_B'
				WHEN '906225' THEN 'HEPATITIS_C' WHEN '908807' THEN 'HEPATITIS_C'
				WHEN '906039' THEN 'SIFILIS' WHEN '906915' THEN 'SIFILIS'
				WHEN '906249' THEN 'VIH' WHEN '908832' THEN 'VIH'
				WHEN '954629' THEN 'EVOCADOS' WHEN '954632' THEN 'EVOCADOS' 
			ELSE GENSERIPS.SIPDESCUP END etiqueta
			, '' tip0
			, FORMAT(HCNRESEXA.HCRFECRES, 'yyyy-MM-dd', 'en-us') tip
			--, HCNRESEXA.HCRDESCRIP tip2
			, LOWER(
				LTRIM(
					RTRIM(
						REPLACE(
							REPLACE(
								REPLACE(
									TRANSLATE(HCNRESEXA.HCRDESCRIP, CHAR(13) + CHAR(10) + CHAR(9), '   '),
								'    ', ' '),
							'  ', ' '),
						'  ', ' ')
					)
				)
			) AS tip1
			, HCNRESEXA.HCRANALIS tip2
		FROM ADNINGRESO
			JOIN GENPACIEN ON ADNINGRESO.GENPACIEN = GENPACIEN.OID
			JOIN HCNFOLIO ON HCNFOLIO.ADNINGRESO = ADNINGRESO.OID
			JOIN HCNSOLEXA ON HCNFOLIO.OID = HCNSOLEXA.HCNFOLIO
			inner JOIN HCNRESEXA ON HCNSOLEXA.OID = HCNRESEXA.HCNSOLEXA
			JOIN GENSERIPS ON GENSERIPS.OID = HCNSOLEXA.GENSERIPS
		WHERE GENSERIPS.SIPCODCUP IN (
			--'904903', '904904', '904902', '904912', --TSH
			'908806', '906223', '906317', -- HEPATITIS B
			'906225', '908807', -- HEPATITIS C
			'906249', '908832', -- VIH
			'906039', '906915', -- SIFILIS
			'954629', '954632' -- EVOCADOS
		)
		AND TRY_CONVERT(DATETIME, HCNRESEXA.HCRFECRES, 120) BETWEEN @from AND @to
),

-- 5) Parto por folio (tipo historia)
ase_planifica AS (
    SELECT DISTINCT
        GENPACIEN.PACNUMDOC
		, 'asesoria' AS etiqueta
        , FORMAT(HCRHORREG, 'yyyy-MM-dd', 'en-us') tip0
        , tip = '' , tip2 = '' , '' tip3
    FROM ADNINGRESO
        LEFT JOIN HCNREGENF ON HCNREGENF.ADNINGRESO = ADNINGRESO.OID
        LEFT JOIN HCNNOTENF ON HCNREGENF.OID = HCNNOTENF.HCNREGENF
        LEFT JOIN GENPACIEN ON HCNREGENF.GENPACIEN = GENPACIEN.OID
    WHERE TRY_CONVERT(DATETIME, HCRHORREG, 120) BETWEEN @from AND @to
	AND LOWER(CONCAT(HCNNOTENF.HCNSUBOBJ, ' ', HCNNOTENF.HCNANAPLAN)) LIKE '%PLANIF%'
),

ase_lacta AS (
	SELECT DISTINCT
        GENPACIEN.PACNUMDOC
		, 'lactancia' AS etiqueta
        , FORMAT(HCRHORREG, 'yyyy-MM-dd', 'en-us') AS tip0
		, tip = '' , tip2 = '' , '' tip3
    FROM ADNINGRESO
        LEFT JOIN HCNREGENF ON HCNREGENF.ADNINGRESO = ADNINGRESO.OID
        LEFT JOIN HCNNOTENF ON HCNREGENF.OID = HCNNOTENF.HCNREGENF
        LEFT JOIN GENPACIEN ON HCNREGENF.GENPACIEN = GENPACIEN.OID
    WHERE TRY_CONVERT(DATETIME, HCRHORREG, 120) BETWEEN @from AND @to
    AND LOWER(CONCAT(HCNNOTENF.HCNSUBOBJ, ' ', HCNNOTENF.HCNANAPLAN)) LIKE '%lactancia%'
),

fpp AS (
		SELECT DISTINCT
			GENPACIEN.PACNUMDOC
			, 'fpp' AS etiqueta
			, FORMAT(HCMHC67.HCCM05N312, 'yyyy-MM-dd', 'en-us')  as tip0
			, FORMAT(HCMHC67.HCCM05N312, 'yyyy-MM-dd', 'en-us') as tip
			, tip2 = '' , '' tip3
		FROM ADNINGRESO
			INNER JOIN HCNFOLIO ON HCNFOLIO.ADNINGRESO = ADNINGRESO.OID
			INNER JOIN GENPACIEN ON HCNFOLIO.GENPACIEN = GENPACIEN.OID
			INNER JOIN HCMHC67 on HCMHC67.HCNFOLIO = HCNFOLIO.OID
		WHERE TRY_CONVERT(DATETIME, ADNINGRESO.AINFECING, 120) BETWEEN @from AND @to

),

DUCTAL AS (
	SELECT DISTINCT
		GENPACIEN.PACNUMDOC
		, 'DUCTAL' AS etiqueta
		, FORMAT(HCNFOLIO.HCFECFOL, 'yyyy-MM-dd', 'en-us') tip0
		, HCMHC14.HCCM03N02 tip
		, tip2 = '' , '' tip3
	FROM ADNINGRESO
		INNER JOIN HCNFOLIO ON HCNFOLIO.ADNINGRESO = ADNINGRESO.OID
		INNER JOIN GENPACIEN ON ADNINGRESO.GENPACIEN = GENPACIEN.OID
		INNER join HCMHC14 on HCMHC14.HCNFOLIO = HCNFOLIO.OID
		LEFT JOIN GENMEDICO ON HCNFOLIO.GENMEDICO = GENMEDICO.OID
		LEFT JOIN GENESPECI on HCNFOLIO.GENESPECI = GENESPECI.OID
	WHERE
		TRY_CONVERT(DATETIME, HCNFOLIO.HCFECFOL, 120) BETWEEN @from AND @to
		--and GENPACIEN.PACNUMDOC = '1061226271'
		and GENESPECI.GEEDESCRI like '%pedia%'
		and (LOWER(HCMHC14.HCCM03N02) like '%DUCTAL%')
),

PESO_TALLA AS (
	SELECT
		t.PACNUMDOC
		, 'PESO' AS etiqueta
		, ISNULL(CAST(t.Peso_Kg AS VARCHAR(20)), '') AS tip0
		, ISNULL(CAST(t.Talla_Cm AS VARCHAR(20)), '') AS tip
		, FORMAT(t.f_fol, 'yyyy-MM-dd') tip2 , '' tip3
	FROM (
		SELECT *,
			   ROW_NUMBER() OVER (PARTITION BY PACNUMDOC ORDER BY f_fol DESC) AS rn
		FROM (
			SELECT DISTINCT
				GENPACIEN.PACNUMDOC,
				COALESCE(HCMHC01.HCCM00N113, HCMHC08.HCCM01N214, HCMHC104.HCCM01N01,
						 HCMHC26.HCCM01N75, HCMHC30.HCCM01N96, HCMHC36.HCCM01N03,
						 HCMHC42.HCCM01N123, HCMHC45.HCCM01N744, HCMHC45B.HCCM01N22,
						 HCMHC45C.HCCM01N08, HCMHC77.HCCM01N96, HCMHC95.HCCM01N01,
						 HCMHC84.HCCM01N187) AS Peso_Kg,
				COALESCE(HCMHC01.HCCM00N114, HCMHC08.HCCM01N215, HCMHC104.HCCM01N02,
						 HCMHC26.HCCM01N76, HCMHC30.HCCM01N97, HCMHC36.HCCM01N57,
						 HCMHC42.HCCM01N131, HCMHC45.HCCM01N742, HCMHC45B.HCCM01N24,
						 HCMHC45C.HCCM01N06, HCMHC77.HCCM01N97, HCMHC95.HCCM01N02,
						 HCMHC84.HCCM01N188) AS Talla_Cm,
				HCNFOLIO.HCFECFOLI AS f_fol
			FROM ADNINGRESO 
				INNER JOIN GENPACIEN ON ADNINGRESO.GENPACIEN = GENPACIEN.OID
				INNER JOIN HCNFOLIO ON HCNFOLIO.ADNINGRESO = ADNINGRESO.OID
				LEFT JOIN HCMHC01  ON HCMHC01.HCNFOLIO = HCNFOLIO.OID
				LEFT JOIN HCMHC08  ON HCMHC08.HCNFOLIO = HCNFOLIO.OID
				LEFT JOIN HCMHC104 ON HCMHC104.HCNFOLIO = HCNFOLIO.OID
				LEFT JOIN HCMHC26  ON HCMHC26.HCNFOLIO = HCNFOLIO.OID
				LEFT JOIN HCMHC30  ON HCMHC30.HCNFOLIO = HCNFOLIO.OID
				LEFT JOIN HCMHC36  ON HCMHC36.HCNFOLIO = HCNFOLIO.OID
				LEFT JOIN HCMHC42  ON HCMHC42.HCNFOLIO = HCNFOLIO.OID
				LEFT JOIN HCMHC45  ON HCMHC45.HCNFOLIO = HCNFOLIO.OID
				LEFT JOIN HCMHC45B ON HCMHC45B.HCNFOLIO = HCNFOLIO.OID
				LEFT JOIN HCMHC45C ON HCMHC45C.HCNFOLIO = HCNFOLIO.OID
				LEFT JOIN HCMHC77  ON HCMHC77.HCNFOLIO = HCNFOLIO.OID
				LEFT JOIN HCMHC95  ON HCMHC95.HCNFOLIO = HCNFOLIO.OID
				LEFT JOIN HCMHC84  ON HCMHC84.HCNFOLIO = HCNFOLIO.OID
				/* ... restantes LEFT JOINs ... */
			WHERE TRY_CONVERT(DATETIME, HCNFOLIO.HCFECFOL, 120) BETWEEN @from AND @to
		) base
		WHERE base.Peso_Kg IS NOT NULL
		  AND base.Talla_Cm IS NOT NULL
	) t
	WHERE t.rn = 1

),

-- Unión de todas las fuentes y pivot final
gestacion AS (
	SELECT * FROM Nombres
	UNION ALL
	SELECT * FROM Datosidentificac
	UNION ALL
	SELECT * FROM Etniaeduca
	UNION ALL
	SELECT * FROM Eapb_Pais
	UNION ALL
    SELECT * FROM GestanteCTE
    UNION ALL
    SELECT * FROM AbortoCTE
    UNION ALL
    SELECT * FROM PartoCTE
    UNION ALL
    SELECT * FROM NegativoCTE
    UNION ALL
    SELECT * FROM PlanifQXCTE
    UNION ALL
	SELECT * FROM PlanifQXCTEDOS
    UNION ALL
	SELECT * FROM PlanifMedCTEDOS
    UNION ALL
    SELECT * FROM PlanifMedCTE
    UNION ALL
    SELECT * FROM PartoFolioCTE	
	UNION ALL
    SELECT * FROM Examenes	
	UNION ALL
    SELECT * FROM ase_planifica
	UNION ALL
    SELECT * FROM ase_lacta
	UNION ALL
    SELECT * FROM fpp
	UNION ALL
    SELECT * FROM DUCTAL
	UNION ALL
	SELECT * FROM PESO_TALLA

)

SELECT DISTINCT
	ISNULL(MAX(CASE WHEN etiqueta = 'DATOSBASICOS' THEN tip0 END), '') Edad
	
	, '' _0_Tipo_registro
	, '' _1_Consecutivoderegistro
	, '' _2_Codigo_habilitación_IPS_primaria
	, ISNULL(MAX(CASE WHEN etiqueta = 'DATOSBASICOS' THEN tip END), '') _3_tipoidusuario
	
	,PACNUMDOC _4_numidentificacion
	
	, ISNULL(MAX(CASE WHEN etiqueta = 'NOMBRES' THEN tip0 END), '') _5_primerapellido
	, ISNULL(MAX(CASE WHEN etiqueta = 'NOMBRES' THEN tip END), '') _6_segundoapellido
	, ISNULL(MAX(CASE WHEN etiqueta = 'NOMBRES' THEN tip1 END), '') _7_primernombre
	, ISNULL(MAX(CASE WHEN etiqueta = 'NOMBRES' THEN tip2 END), '') _8_segundonombre
	, ISNULL(MAX(CASE WHEN etiqueta = 'DATOSBASICOS' THEN tip1 END), '') _9_fechanacimiento
	, ISNULL(MAX(CASE WHEN etiqueta = 'DATOSBASICOS' THEN tip2 END), '') _10_sexo
	, ISNULL(MAX(CASE WHEN etiqueta = 'ETNIA_EDUCA' THEN tip0 END), '') _11_codetnica
	, ISNULL(MAX(CASE WHEN etiqueta = 'ETNIA_EDUCA' THEN tip END), '') _12_codocupacion
	, ISNULL(MAX(CASE WHEN etiqueta = 'ETNIA_EDUCA' THEN tip1 END), '') _12_codocupacion_nomb
	, ISNULL(MAX(CASE WHEN etiqueta = 'ETNIA_EDUCA' THEN tip2 END), '') _13_codniveleducativo
	
	, CASE
        WHEN 
		 NULLIF(LTRIM(RTRIM(MAX(CASE WHEN etiqueta = 'Aborto' THEN tip0 END))), '') IS NOT NULL
         OR NULLIF(LTRIM(RTRIM(MAX(CASE WHEN etiqueta = 'Parto' THEN tip0 END))), '') IS NOT NULL
         OR NULLIF(LTRIM(RTRIM(MAX(CASE WHEN etiqueta = 'Parto Folio' THEN tip0 END))), '') IS NOT NULL
         OR NULLIF(LTRIM(RTRIM(MAX(CASE WHEN etiqueta = 'Planificacion' THEN tip0 END))), '') IS NOT NULL
         OR NULLIF(LTRIM(RTRIM(MAX(CASE WHEN etiqueta = 'Negativo' THEN tip0 END))), '') IS NOT NULL
         OR NULLIF(LTRIM(RTRIM(MAX(CASE WHEN etiqueta = 'emergencia' THEN tip0 END))), '') IS NOT NULL
         OR NULLIF(LTRIM(RTRIM(MAX(CASE WHEN etiqueta = 'emergencia' THEN tip0 END))), '') IS NOT NULL
         OR NULLIF(LTRIM(RTRIM(MAX(CASE WHEN etiqueta = 'Gestante' THEN tip0 END))), '') IS NULL
        THEN '2'
        ELSE '1'
    END AS _14_Gestación
	
	, '' _15_SífilisGestacionalocongénita
	, '' _16_Resultado_prueba_mini_mental_state
	, '' _17_HipotiroidismoCongénito
	, '' _18_SintomáticoRespiratorio
	, '' _19_Consumodetabaco
	, '' _20_Lepra
	, '' _21_ObesidadoDesnutriciónProteicoCalórica
	, '' _22_Resultadodeltactorectal
	, '' _23_Acidofólicopreconcepcional
	, '' _24_Resultadodelapruebadesangreocultaenmateriafecal
	, '' _25_EnfermedadMental
	, '' _26_CáncerdeCérvix
	, '' _27_Agudezavisuallejanaojoizquierdo
	, '' _28_Agudezavisuallejanaojoderecho
	
	, ISNULL(MAX(CASE WHEN etiqueta = 'PESO' THEN tip1 END), '') _29_FechadelPeso
	, ISNULL(MAX(CASE WHEN etiqueta = 'PESO' THEN tip0 END), '') _30_PesoenKilogramos
	, ISNULL(MAX(CASE WHEN etiqueta = 'PESO' THEN tip1 END), '') _31_FechadelaTalla
	, ISNULL(MAX(CASE WHEN etiqueta = 'PESO' THEN tip END), '') _32_TallaenCentímetros
	, ISNULL(MAX(CASE WHEN etiqueta = 'fpp' THEN tip0 END), '') _33_FechaProbabledePartoTodalapoblación
	, ISNULL(MAX(CASE WHEN etiqueta = 'EAPB_PAIS' THEN tip0 END), '') _34_Códigopaís
	
	, '' _35_Clasificacióndelriesgogestacional
	, '' _36_Resultadodecolonoscopiatamizaje 
	

	, ISNULL(MAX(CASE WHEN etiqueta = 'EVOCADOS' THEN tip2 END), '') _37_resultadotamizajeauditivoneonatal
	, ISNULL(MAX(CASE WHEN etiqueta = 'DUCTAL' THEN tip END), '') _38_resultadotamizajevisualneonatal
	
	, '' _39_DPTmenoresde5aNos
	, '' _40_ResultadodetamizajeVALE
	, '' _41_Neumococo
	
	, ISNULL(MAX(CASE WHEN etiqueta = 'HEPATITIS_C' THEN tip1 END), '') _42_ResultadodetamizajeparahepatitisC
	
	, '' _43_Resultadodeescalaabreviadadedesarrolloáreademotricidadgruesa
	, '' _44_Resultadodeescalaabreviadadedesarrolloáreademotricidadfinoadaptativa
	, '' _45_Resultadodeescalaabreviadadedesarrolloáreapersonalsocial
	, '' _46_Resultadodeescalaabreviadadedesarrolloáreademotricidadaudiciónlenguaje
	, '' _47_Tratamientoablativoodeescisiónposterioralarealizacióndelatécnicadeinspecciónvisual
	
	, ISNULL(MAX(CASE WHEN etiqueta = 'DUCTAL' THEN tip END), '') _48_resultadotamizacionoximetriaprepostductal
    , ISNULL(MAX(CASE WHEN etiqueta = 'Parto Folio' THEN tip0 END), '') _49_fechaatencionpartoocesarea
    , ISNULL(MAX(CASE WHEN etiqueta = 'Parto Folio' THEN tip END), '') _50_fechasalidaatencionpartocesarea 
	, ISNULL(MAX(CASE WHEN etiqueta = 'lactancia' THEN tip0 END), '') _51_fechaatencionsaludpromocionapoyolactanciamaterna
    
	, '' _52_Fechadeconsultadevaloraciónintegral
	
	, ISNULL(MAX(CASE WHEN etiqueta = 'asesoria' THEN tip0 END), '') _53_fechaatencionsaludasesoriaanticoncepcion
    , ISNULL(MAX(CASE WHEN etiqueta = 'Planificacion' THEN tip END), '') _54_suministrometodoanticonceptivo
	, ISNULL(MAX(CASE WHEN etiqueta = 'Planificacion' THEN tip0 END), '') _55_fechasuministrometodoanticonceptivo

	
	, '' _56_Fechadeprimeraconsultaprenatal
	, '' _57_Resultadodeglicemiabasal
	, '' _58_Fechadeúltimocontrolprenataldeseguimiento
	, '' _59_Suministrodeácidofólicoenelcontrolprenatal
	, '' _60_Suministrodesulfatoferrosoenelcontrolprenatal
	, '' _61_Suministrodecarbonatodecalcioenelcontrolprenatal
	, '' _62_Fechadevaloraciónagudezavisual
	, '' _63_FechadetamizajeVALE
	, '' _64_Fechadeltactorectal
	

	, ISNULL(MAX(CASE WHEN etiqueta = 'DUCTAL' THEN tip0 END), '') _65_fechatamizacionoximetriaprepostductal
	
	, '' _66_Fechaderealizacióncolonoscopiatamizaje
	, '' _67_Fechadelapruebasangreocultaenmateriafecal
	, '' _68_ConsultadePsicología
	
	, ISNULL(MAX(CASE WHEN etiqueta = 'EVOCADOS' THEN tip END), '') _69_fechatamizajeauditivoneonatal
	
	, '' _70_Suministrodefortificacióncaseraenlaprimerainfancia
	, '' _71_SuministrodevitaminaAenlaprimerainfancia
	, '' _72_FechadetomaLDL
	, '' _73_FechadetomaPSA
	, '' _74_PreservativosentregadosapacientesconITS
	
	, ISNULL(MAX(CASE WHEN etiqueta = 'DUCTAL' THEN tip0 END), '') _75_fechatamizajevisualneonatal
	
	, '' _76_Fechadeatenciónensaludbucalporprofesionalenodontología
	, '' _77_SuministrodehierroenlaprimeraInfancia
	
	, ISNULL(MAX(CASE WHEN etiqueta = 'HEPATITIS_B' THEN tip END), '') _78_fechaantigenosuperficiehepatitisb
	, ISNULL(MAX(CASE WHEN etiqueta = 'HEPATITIS_B' THEN tip1 END), '') _79_resultadoantigenosuperficiehepatitisb
	, ISNULL(MAX(CASE WHEN etiqueta = 'SIFILIS' THEN tip END), '') _80_fechatomapruebatamizajesifilis
	, ISNULL(MAX(CASE WHEN etiqueta = 'SIFILIS' THEN tip1 END), '') _81_resultadopruebatamizajesifilis
	, ISNULL(MAX(CASE WHEN etiqueta = 'VIH' THEN tip END), '') _82_fechatomapruebavih
	, ISNULL(MAX(CASE WHEN etiqueta = 'VIH' THEN tip1 END), '') _83_resultadopruebavih
	
	, '' _84_FechaTSHNeonatal
	, '' _85_ResultadodeTSHNeonatal
	, '' _86_Tamizajedelcáncerdecuellouterino
	, '' _87_Fechadetamizajecáncerdecuellouterino
	, '' _88_Resultadotamizajecáncerdecuellouterino
	, '' _89_Calidadenlamuestradecitologíacervicouterina
	, '' _90_CódigodehabilitaciónIPSdondeserealizatamizajecáncerdecuellouterino
	, '' _91_FechadeColposcopia
	, '' _92_ResultadodeLDL
	, '' _93_Fechadebiopsiacervicouterina
	, '' _94_Resultadodebiopsiacervicouterina
	, '' _95_ResultadodeHDL
	, '' _96_FechaMamografía
	, '' _97_ResultadoMamografía
	, '' _98_Resultadodetriglicéridos
	, '' _99_Fechadetomabiopsiademama
	, '' _100_Fechaderesultadobiopsiademama
	, '' _101_Resultadodebiopsiademama
	, '' _102_COPporpersona
	, '' _103_Fechadetomahemoglobina
	, '' _104_Resultadodehemoglobina
	, '' _105_Fechadetomaglicemiabasal
	, '' _106_Fechadetomacreatinina
	, '' _107_Resultadodecreatinina
	, '' _108_FechaHemoglobinaGlicosilada
	, '' _109_ResultadodePSA
	
	, ISNULL(MAX(CASE WHEN etiqueta = 'HEPATITIS_C' THEN tip END), '') _110_fechatomatamizajehepatitisc
	
	, '' _111_FechadetomaHDL
	, '' _112_Fechadetomadebaciloscopiadiagnóstico
	, '' _113_Resultadodebaciloscopiadiagnóstico
	, '' _114_Clasificacióndelriesgocardiovascular
	, '' _115_TratamientoparaSífilisgestacional
	, '' _116_TratamientoparaSífilisCongénita
	, '' _117_Clasificacióndelriesgometabólico
	, '' _118_Fechadetomatriglicéridos
	
	, '-------' sep
    , ISNULL(MAX(CASE WHEN etiqueta = 'Gestante' THEN tip0 END), '') [Gestante confirmada por cie]
    , ISNULL(MAX(CASE WHEN etiqueta = 'Aborto' THEN tip0 END), '') [Aborto]
    , ISNULL(MAX(CASE WHEN etiqueta = 'Parto' THEN tip0 END), '') [Parto]
    , ISNULL(MAX(CASE WHEN etiqueta = 'Negativo' THEN tip0 END), '') [Negativo] 
    , ISNULL(MAX(CASE WHEN etiqueta = 'Planificacion' THEN tip2 END), '') [Planificacion_tip]
    , ISNULL(MAX(CASE WHEN etiqueta = 'emergencia' THEN tip2 END), '') [Emergencia]
	, ISNULL(MAX(CASE WHEN etiqueta = 'EAPB_PAIS' THEN tip END), '') [TIP_ASE]
	, ISNULL(MAX(CASE WHEN etiqueta = 'EAPB_PAIS' THEN tip1 END), '') [EAPB]
FROM gestacion
GROUP BY PACNUMDOC
ORDER BY PACNUMDOC ASC;

--select * from INNPRODUC WHERE IPRCODALT = '20175926-2'

