--检验医嘱分类,数据来源于科室字典
--医嘱分类的数据在旧系统中对应这执行科室
SELECT concat('000',ROWNUM),NAME_DEPT from
  (SELECT DISTINCT NAME_DEPT from BD_ORD ord
  LEFT JOIN BD_ORD_DEPT dept on dept.PK_ORD = ord.PK_ORD
  INNER JOIN BD_OU_DEPT deptou on deptou.PK_DEPT = dept.PK_DEPT
  INNER JOIN BD_DEFDOC doc on doc.NAME = NAME_DEPT and CODE_DEFDOCLIST = '030000' and doc.DEL_FLAG = 0 and BA_CODE = '03'
where OLD_TYPE = '1')



--INSERT INTO BD_DEFDOC
SELECT
  replace(sys_guid(), '-', '') PK_DEFDOC,
  '~                               '                           PK_ORG,
  '030000' CODE_DEFDOCLIST,
  CODE,
  '03' BA_CODE,
  NAME,
  name SHORTNAME,
  PY_CODE PY_CODE,
  null D_CODE,
  null MEMO,
  'ben0410' CREATOR,
  sysdate CREATE_TIME,
  '0' DEL_FLAG,
  '0' FLAG_DEF,
  null TS,
  null CODE_PARENT,
  null PK_DEFDOCLIST,
  null SPCODE,
  null MODIFIER,
  null MODITY_TIME,
  null EU_TYPE,
  null  CODE_STD,
  null  OLD_ID,
  null NAME_STD
FROM (SELECT concat('000',ROWNUM+33) code, --编码自动生成,没有规律
        NAME_DEPT name,PY_CODE  from
  (SELECT DISTINCT NAME_DEPT,PY_CODE from BD_ORD ord
  LEFT JOIN BD_ORD_DEPT dept on dept.PK_ORD = ord.PK_ORD
  INNER JOIN BD_OU_DEPT deptou on deptou.PK_DEPT = dept.PK_DEPT
where OLD_TYPE = '1')
     ) t



UPDATE BD_ORD ordd
set DT_ORDCATE = (  SELECT  doc.CODE from BD_ORD ord
  LEFT JOIN BD_ORD_DEPT dept on dept.PK_ORD = ord.PK_ORD and ord.DEL_FLAG = 0 and FLAG_ACTIVE = 1
  INNER JOIN BD_OU_DEPT deptou on deptou.PK_DEPT = dept.PK_DEPT and dept.DEL_FLAG = 0
  --码表
  INNER JOIN BD_DEFDOC doc on doc.NAME = NAME_DEPT and CODE_DEFDOCLIST = '030000' and doc.DEL_FLAG = 0 and BA_CODE = '03'
where OLD_TYPE = '1' and ord.PK_ORD = ordd.PK_ORD)
where exists(  SELECT  doc.CODE,ord.NAME from BD_ORD ord
  LEFT JOIN BD_ORD_DEPT dept on dept.PK_ORD = ord.PK_ORD and ord.DEL_FLAG = 0 and FLAG_ACTIVE = 1
  INNER JOIN BD_OU_DEPT deptou on deptou.PK_DEPT = dept.PK_DEPT and dept.DEL_FLAG = 0
  INNER JOIN BD_DEFDOC doc on doc.NAME = NAME_DEPT and CODE_DEFDOCLIST = '030000' and doc.DEL_FLAG = 0 and BA_CODE = '03'
where OLD_TYPE = '1' and ord.PK_ORD = ordd.PK_ORD)