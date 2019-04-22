--药品别名
--西药
SELECT  '1-'+cast(wma.WMID as varchar(10)),WMAlias,wma.SpellCode,wma.WBCode from tbWMAlias wma
  INNER JOIN tbWM wm ON wma.WMID = wm.WMID and IdleFlag = 0
UNION ALL
--中成药
SELECT  '2-'+cast(wma.PCMID as varchar(10)),PCMAlias,wma.SpellCode,wma.WBCode from tbPCMAlias wma
  INNER JOIN tbPCM wm ON wma.PCMID = wm.PCMID and IdleFlag = 0
UNION ALL
--中草药
SELECT  '3-'+cast(wma.TCMID as varchar(10)),TCMAlias,wma.SpellCode,wma.WBCode from tbTCMAlias wma
  INNER JOIN tbTCM wm ON wma.TCMID = wm.TCMID and IdleFlag = 0




-----医嘱别名含有非法字符,药品别名也是如此操作

SELECT * from BD_ORD_ALIAS where SPCODE like '%%';
SELECT *  from BD_ORD_ALIAS where PK_ORDALIA = '0DA55CA8EC7042168E1DF3E3F84201A4'

UPDATE BD_ORD_ALIAS
set SPCODE = replace(SPCODE,'+', ''),D_CODE = replace(D_CODE, '+', '')
where SPCODE like '%+%'