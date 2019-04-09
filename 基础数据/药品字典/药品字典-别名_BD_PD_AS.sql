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