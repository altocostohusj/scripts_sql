SELECT GENPACIEN.pacnumdoc HISTORIA,GENPACIEN.GPANOMCOM NOMBRES,hcacodigo CAMA,hsunombre SERVICIO,
CONVERT(CHAR(10),AINFECING,103) FECHA_INGRESO,
CONVERT(CHAR(10),AINFECING,108) HORA_INGRESO,
datediff(day,ainfecing,getdate())   [DIAS ESTANCIA],

 (select TOP 1 DIACODIGO from hcnfolio inner join hcndiapac on hcndiapac.hcnfolio = hcnfolio.oid inner join gendiagno on gendiagno.oid = hcndiapac.gendiagno 
						 where hcnfolio.adningreso =  adningreso.oid AND HCPDIAPRIN= 1 ORDER BY HCNDIAPAC.OID DESC) CIE10,
						 (select TOP 1 DIANOMBRE from hcnfolio inner join hcndiapac on hcndiapac.hcnfolio = hcnfolio.oid inner join gendiagno on gendiagno.oid = hcndiapac.gendiagno 
						 where hcnfolio.adningreso =  adningreso.oid AND HCPDIAPRIN= 1 ORDER BY HCNDIAPAC.OID DESC) DIAGNOSTICO,munnommun MUNICIPIO,gdenombre EPS
FROM adningreso
inner join hpnestanc  on adningreso.oid = hpnestanc.adningres and hesfecsal is null 
inner join hpndefcam on hpndefcam.oid = adningreso.hpndefcam
inner join hpnsubgru on hpnsubgru.oid = hpndefcam.hpnsubgru
inner join genpacien on genpacien.oid =  adningreso.genpacien
inner join genmunici on genmunici.oid =  genpacien.DGNMUNICIPIO
inner join gendetcon on gendetcon.oid =  adningreso.gendetcon
WHERE ainestado in (0)
--and gdenombre like '%EMSS%'
group by  GENPACIEN.pacnumdoc,GENPACIEN.GPANOMCOM,hcacodigo,hsunombre,
AINFECING,munnommun,gdenombre,ADNINGRESO.OID
order by ainfecing