



--需要增加/删除的数据u
SELECT --VAL_COMT,NAME_CD,cndiag.CODE_ICD,cndiag.CODE_ADD,
   comt.PK_CNDIAGCOMT
  FROM BD_CNDIAG cndiag
     INNER JOIN bd_cndiag_comt comt ON comt.PK_CNDIAG = cndiag.PK_CNDIAG
    INNER JOIN (SELECT * from BD_CNDIAG_COMT_DT where VAL_COMT like 'IA期%') comtdt ON comtdt.PK_CNDIAGCOMT = comt.PK_CNDIAGCOMT
WHERE  (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M80000/3')
or (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M80700/3')
or (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M80900/3')
or (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M82000/3')
or (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M87200/3')
or (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M88040/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M80000/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M80700/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M80900/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M82000/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M87200/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M88040/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M80000/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M80700/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M80900/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M82000/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M87200/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M88040/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M80000/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M80700/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M80900/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M82000/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M87200/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M88040/3')
;



--新增
--INSERT into BD_CNDIAG_COMT_DT
SELECT
  replace(sys_guid(), '-', '') PK_CNDIAGCOMTDT,
  '~                               'PK_ORG,
  PK_CNDIAGCOMT,
  '0' SORTNO,
  VAL_COMT,
  null PK_DIAG,
  null PK_DIAG_ADD,
  null PK_DIAG_ADD2,
  null NOTE,
  'ben0415'CREATOR,
  sysdate CREATE_TIME,
  null MODIFIER,
  null MODITY_TIME,
  '0' DEL_FLAG,
  null TS,
  null CODE_ICD,
  null CODE_ADD,
  null CODE_ADD2
FROM (SELECT adiag.*,diag.PK_DIAG,PK_CNDIAGCOMT,CODE VAL_COMT
from
--新诊断备注数据
(SELECT CODE_ICD,CODE_APP,CODE from A_BD_CNDIAG,A_BD_CNDIAG_B) adiag
--诊断备注表,根据icd编码,附加编码,一个值找到想要的数据
INNER JOIN (SELECT PK_DIAG,PK_CNDIAGCOMT,CODE_ADD,CODE_ICD from  BD_CNDIAG_COMT com
  INNER JOIN BD_CNDIAG diag on com.PK_CNDIAG = diag.PK_CNDIAG
where com.PK_CNDIAGCOMT in
(
  --根据icd编码,附加编码,一个值找到想要的数据
  SELECT --VAL_COMT,NAME_CD,cndiag.CODE_ICD,cndiag.CODE_ADD,
   comt.PK_CNDIAGCOMT
  FROM BD_CNDIAG cndiag
     INNER JOIN bd_cndiag_comt comt ON comt.PK_CNDIAG = cndiag.PK_CNDIAG
    INNER JOIN (SELECT * from BD_CNDIAG_COMT_DT where VAL_COMT like 'IA期%') comtdt ON comtdt.PK_CNDIAGCOMT = comt.PK_CNDIAGCOMT
WHERE  (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M80000/3')
or (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M80700/3')
or (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M80900/3')
or (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M82000/3')
or (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M87200/3')
or (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M88040/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M80000/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M80700/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M80900/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M82000/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M87200/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M88040/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M80000/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M80700/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M80900/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M82000/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M87200/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M88040/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M80000/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M80700/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M80900/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M82000/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M87200/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M88040/3'))) diag on diag.CODE_ICD = adiag.CODE_ICD and CODE_ADD = CODE_APP

where not exists(SELECT diag1.CODE_ICD,diag1.CODE_ADD,VAL_COMT from BD_CNDIAG_COMT_DT dt
  INNER JOIN BD_CNDIAG_COMT com on dt.PK_CNDIAGCOMT = com.PK_CNDIAGCOMT
  INNER JOIN BD_CNDIAG diag1 on com.PK_CNDIAG = diag1.PK_CNDIAG
where dt.PK_CNDIAGCOMT in
(
  --根据icd编码,附加编码,一个值找到想要的数据
  SELECT --VAL_COMT,NAME_CD,cndiag.CODE_ICD,cndiag.CODE_ADD,
   comt.PK_CNDIAGCOMT
  FROM BD_CNDIAG cndiag
     INNER JOIN bd_cndiag_comt comt ON comt.PK_CNDIAG = cndiag.PK_CNDIAG
    INNER JOIN (SELECT * from BD_CNDIAG_COMT_DT where VAL_COMT like 'IA期%') comtdt ON comtdt.PK_CNDIAGCOMT = comt.PK_CNDIAGCOMT
WHERE  (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M80000/3')
or (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M80700/3')
or (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M80900/3')
or (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M82000/3')
or (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M87200/3')
or (cndiag.code_icd = 'C51.000' and cndiag.code_add =   'M88040/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M80000/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M80700/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M80900/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M82000/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M87200/3')
or (cndiag.code_icd = 'C51.001' and cndiag.code_add =   'M88040/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M80000/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M80700/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M80900/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M82000/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M87200/3')
or (cndiag.code_icd = 'C51.100' and cndiag.code_add =   'M88040/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M80000/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M80700/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M80900/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M82000/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M87200/3')
or (cndiag.code_icd = 'C51.200' and cndiag.code_add =   'M88040/3')) and dt.PK_CNDIAGCOMT = diag.PK_CNDIAGCOMT and adiag.CODE = dt.VAL_COMT));






--需要删除
SELECT dt.* from BD_CNDIAG_COMT_DT dt
  INNER JOIN BD_CNDIAG_COMT com on dt.PK_CNDIAGCOMT = com.PK_CNDIAGCOMT
  INNER JOIN BD_CNDIAG diag1 on com.PK_CNDIAG = diag1.PK_CNDIAG
where dt.PK_CNDIAGCOMT in
(
  --根据icd编码,附加编码,一个值找到想要的数据
  SELECT --VAL_COMT,NAME_CD,cndiag.CODE_ICD,cndiag.CODE_ADD,
   comt.PK_CNDIAGCOMT
  FROM BD_CNDIAG cndiag
     INNER JOIN bd_cndiag_comt comt ON comt.PK_CNDIAG = cndiag.PK_CNDIAG
    INNER JOIN (SELECT * from BD_CNDIAG_COMT_DT where VAL_COMT like 'IA期%') comtdt ON comtdt.PK_CNDIAGCOMT = comt.PK_CNDIAGCOMT
WHERE  (cndiag.code_icd = 'C51.000' and	cndiag.code_add = 	'M80000/3')
or (cndiag.code_icd = 'C51.000' and	cndiag.code_add = 	'M80700/3')
or (cndiag.code_icd = 'C51.000' and	cndiag.code_add = 	'M80900/3')
or (cndiag.code_icd = 'C51.000' and	cndiag.code_add = 	'M82000/3')
or (cndiag.code_icd = 'C51.000' and	cndiag.code_add = 	'M87200/3')
or (cndiag.code_icd = 'C51.000' and	cndiag.code_add = 	'M88040/3')
or (cndiag.code_icd = 'C51.001' and	cndiag.code_add = 	'M80000/3')
or (cndiag.code_icd = 'C51.001' and	cndiag.code_add = 	'M80700/3')
or (cndiag.code_icd = 'C51.001' and	cndiag.code_add = 	'M80900/3')
or (cndiag.code_icd = 'C51.001' and	cndiag.code_add = 	'M82000/3')
or (cndiag.code_icd = 'C51.001' and	cndiag.code_add = 	'M87200/3')
or (cndiag.code_icd = 'C51.001' and	cndiag.code_add = 	'M88040/3')
or (cndiag.code_icd = 'C51.100' and	cndiag.code_add = 	'M80000/3')
or (cndiag.code_icd = 'C51.100' and	cndiag.code_add = 	'M80700/3')
or (cndiag.code_icd = 'C51.100' and	cndiag.code_add = 	'M80900/3')
or (cndiag.code_icd = 'C51.100' and	cndiag.code_add = 	'M82000/3')
or (cndiag.code_icd = 'C51.100' and	cndiag.code_add = 	'M87200/3')
or (cndiag.code_icd = 'C51.100' and	cndiag.code_add = 	'M88040/3')
or (cndiag.code_icd = 'C51.200' and	cndiag.code_add = 	'M80000/3')
or (cndiag.code_icd = 'C51.200' and	cndiag.code_add = 	'M80700/3')
or (cndiag.code_icd = 'C51.200' and	cndiag.code_add = 	'M80900/3')
or (cndiag.code_icd = 'C51.200' and	cndiag.code_add = 	'M82000/3')
or (cndiag.code_icd = 'C51.200' and	cndiag.code_add = 	'M87200/3')
or (cndiag.code_icd = 'C51.200' and	cndiag.code_add = 	'M88040/3'))
and NOT exists(SELECT adiag.*,diag.PK_DIAG,PK_CNDIAGCOMT
from
--新诊断备注数据
(SELECT CODE_ICD,CODE_APP,CODE from A_BD_CNDIAG,A_BD_CNDIAG_B) adiag
--诊断备注表,根据icd编码,附加编码,一个值找到想要的数据
INNER JOIN (SELECT PK_DIAG,PK_CNDIAGCOMT,CODE_ADD,CODE_ICD from  BD_CNDIAG_COMT com
  INNER JOIN BD_CNDIAG diag on com.PK_CNDIAG = diag.PK_CNDIAG
where com.PK_CNDIAGCOMT in
(
  --根据icd编码,附加编码,一个值找到想要的数据
  SELECT --VAL_COMT,NAME_CD,cndiag.CODE_ICD,cndiag.CODE_ADD,
   comt.PK_CNDIAGCOMT
  FROM BD_CNDIAG cndiag
     INNER JOIN bd_cndiag_comt comt ON comt.PK_CNDIAG = cndiag.PK_CNDIAG
    INNER JOIN (SELECT * from BD_CNDIAG_COMT_DT where VAL_COMT like 'IA期%') comtdt ON comtdt.PK_CNDIAGCOMT = comt.PK_CNDIAGCOMT
WHERE  (cndiag.code_icd = 'C51.000' and	cndiag.code_add = 	'M80000/3')
or (cndiag.code_icd = 'C51.000' and	cndiag.code_add = 	'M80700/3')
or (cndiag.code_icd = 'C51.000' and	cndiag.code_add = 	'M80900/3')
or (cndiag.code_icd = 'C51.000' and	cndiag.code_add = 	'M82000/3')
or (cndiag.code_icd = 'C51.000' and	cndiag.code_add = 	'M87200/3')
or (cndiag.code_icd = 'C51.000' and	cndiag.code_add = 	'M88040/3')
or (cndiag.code_icd = 'C51.001' and	cndiag.code_add = 	'M80000/3')
or (cndiag.code_icd = 'C51.001' and	cndiag.code_add = 	'M80700/3')
or (cndiag.code_icd = 'C51.001' and	cndiag.code_add = 	'M80900/3')
or (cndiag.code_icd = 'C51.001' and	cndiag.code_add = 	'M82000/3')
or (cndiag.code_icd = 'C51.001' and	cndiag.code_add = 	'M87200/3')
or (cndiag.code_icd = 'C51.001' and	cndiag.code_add = 	'M88040/3')
or (cndiag.code_icd = 'C51.100' and	cndiag.code_add = 	'M80000/3')
or (cndiag.code_icd = 'C51.100' and	cndiag.code_add = 	'M80700/3')
or (cndiag.code_icd = 'C51.100' and	cndiag.code_add = 	'M80900/3')
or (cndiag.code_icd = 'C51.100' and	cndiag.code_add = 	'M82000/3')
or (cndiag.code_icd = 'C51.100' and	cndiag.code_add = 	'M87200/3')
or (cndiag.code_icd = 'C51.100' and	cndiag.code_add = 	'M88040/3')
or (cndiag.code_icd = 'C51.200' and	cndiag.code_add = 	'M80000/3')
or (cndiag.code_icd = 'C51.200' and	cndiag.code_add = 	'M80700/3')
or (cndiag.code_icd = 'C51.200' and	cndiag.code_add = 	'M80900/3')
or (cndiag.code_icd = 'C51.200' and	cndiag.code_add = 	'M82000/3')
or (cndiag.code_icd = 'C51.200' and	cndiag.code_add = 	'M87200/3')
or (cndiag.code_icd = 'C51.200' and	cndiag.code_add = 	'M88040/3'))) diag on diag.CODE_ICD = adiag.CODE_ICD and CODE_ADD = CODE_APP
where diag.PK_CNDIAGCOMT = dt.PK_CNDIAGCOMT and CODE = VAL_COMT
      );