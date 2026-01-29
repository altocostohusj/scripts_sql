WITH cte AS (
    SELECT
        gp.pacnumdoc                                    AS HISTORIA,
        gp.gpanomcom                                    AS NOMBRES,
        dc.hcacodigo                                    AS CAMA,
        sg.hsunombre                                    AS SERVICIO,
        a.ainfecing                                     AS FECHA_INGRESO_RAW,
        CONVERT(CHAR(10), a.ainfecing, 103)             AS FECHA_INGRESO,
        CONVERT(CHAR(8),  a.ainfecing, 108)             AS HORA_INGRESO,
        DATEDIFF(DAY, a.ainfecing, GETDATE())           AS DIAS_ESTANCIA,
        g.diacodigo                                     AS CIE10,
        g.dianombre                                     AS DIAGNOSTICO,
        mu.munnommun                                    AS MUNICIPIO,
        det.gdenombre                                   AS EPS,
        f.HCFECFOL                                      AS HCFECFOL_FULL,
        FORMAT(f.HCFECFOL, 'yyyy-MM-dd hh:mm', 'es-co') AS FECHA_FOLIO,
        ROW_NUMBER() OVER (
            PARTITION BY gp.pacnumdoc
            ORDER BY f.HCFECFOL DESC
        ) AS rn
    FROM adningreso a
    INNER JOIN hpnestanc he  ON a.oid = he.adningres AND he.hesfecsal IS NULL
    INNER JOIN hpndefcam dc  ON dc.oid = a.hpndefcam
    INNER JOIN hpnsubgru sg  ON sg.oid = dc.hpnsubgru
    INNER JOIN genpacien gp  ON gp.oid = a.genpacien
    INNER JOIN genmunici mu  ON mu.oid = gp.DGNMUNICIPIO
    INNER JOIN gendetcon det  ON det.oid = a.gendetcon
    INNER JOIN hcnfolio f    ON f.adningreso = a.oid
    INNER JOIN hcndiapac dp  ON dp.hcnfolio = f.oid
    INNER JOIN gendiagno g   ON g.oid = dp.gendiagno
    WHERE a.ainestado IN (0)
)
SELECT
    HISTORIA,
    NOMBRES,
    CAMA,
    SERVICIO,
    FECHA_INGRESO,
    HORA_INGRESO,
    DIAS_ESTANCIA,
    CIE10,
    DIAGNOSTICO,
    MUNICIPIO,
    EPS
FROM cte
WHERE rn = 1
ORDER BY FECHA_INGRESO_RAW DESC;