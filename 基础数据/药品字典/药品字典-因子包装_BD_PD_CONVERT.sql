--因子表=包装数量,在旧系统中,因子是由个个药房进行维护,而不是在药品维护中进行维护
--旧系统数据转到新系统,就需要在包装表插入数据,再在仓库处方包装中进行维护
--tbWMMiniBuyList list 西药因子表
--UsingScopeFlag --使用范围  可用=3 , 0=停用
--西药
SELECT
  wm.MiniBuyFlag, --西药中的因子包装标志,该标志为1,则是有因子包装
  WMName,
  WMNo,
  WMSpec,
  DepartmentName,
  DepartmentID,
  Quantity,
  '1-'+cast(wm.WMID as varchar(10))
FROM tbWMMiniBuyList list
  INNER JOIN tbDepartment dept ON dept.DepartmentID = list.MedicineDepartmentID
  INNER JOIN tbWM wm ON wm.WMID = list.WMID
WHERE --DepartmentID = '2101' and
  list.UsingScopeFlag = '3' AND wm.IdleFlag = 0
--成药
union all
SELECT
  wm.MiniBuyFlag, --西药中的因子包装标志,该标志为1,则是有因子包装
  PCMName,
  PCMNo,
  PCMSpec,
  DepartmentName,
  DepartmentName,
  DepartmentID,
  Quantity,
  '2-'+cast(wm.PCMID as varchar(10))
FROM tbPCMMiniBuyList list
  INNER JOIN tbDepartment dept ON dept.DepartmentID = list.MedicineDepartmentID
  INNER JOIN tbPCM wm ON wm.PCMID = list.PCMID
WHERE --DepartmentID = '2101' and
  list.UsingScopeFlag = '3' AND wm.IdleFlag = 0
--草药
union all
SELECT
  wm.MiniBuyFlag, --西药中的因子包装标志,该标志为1,则是有因子包装
  TCMName,
  TCMNo,
  TCMSpec,
  DepartmentName,
  DepartmentName,
  DepartmentID,
  Quantity,
  '2-'+cast(wm.TCMID as varchar(10))
FROM tbTCMMiniBuyList list
  INNER JOIN tbDepartment dept ON dept.DepartmentID = list.MedicineDepartmentID
  INNER JOIN tbTCM wm ON wm.TCMID = list.TCMID
WHERE --DepartmentID = '2101' and
 wm.IdleFlag = 0;
--使用范围为3,药品删除标志为0


-------------------------
--新系统
--药品因子
SELECT DISTINCT QUANTITY,YB_ID,WMSPEC FROM A_BD_PD_CONVERT;
SELECT * from A_BD_PD_CONVERT;

SELECT CODE,NAME,OLD_ID,OLD_CODE,OLD_YB_ID from BD_PD where CODE = '000679';
SELECT * from BD_PD where PK_PD = '81BBFE9FF47144DD990D8680D9870A6B';
SELECT PK_PD,ACOM.*,'D964843BC56E4E33A547AC1097B2848C' PK_UNIT,NAME,CODE,DEL_FLAG from (SELECT DISTINCT QUANTITY,YB_ID,WMSPEC FROM A_BD_PD_CONVERT) ACOM
  INNER JOIN BD_PD PD ON PD.OLD_YB_ID = ACOM.YB_ID and DEL_FLAG = 0
WHERE NOT EXISTS( SELECT * FROM BD_PD_CONVERT CON WHERE PD.DEL_FLAG = 0 AND CON.PK_PD = PD.PK_PD AND QUANTITY = CON.PACK_SIZE);
SELECT * FROM BD_UNIT WHERE NAME = '包';

--添加药品因子
--INSERT INTO BD_PD_CONVERT
SELECT
  replace(sys_guid(), '-', '') PK_PDCONVERT,
  'a41476368e2943f48c32d0cb1179dab8' PK_ORG,
  PK_PD,
  WMSPEC SPEC,
  QUANTITY PACK_SIZE,
  PK_UNIT,
  '0' FLAG_OP,
  '0' FLAG_IP,
  'ben0408' CREATOR,
  sysdate CREATE_TIME,
  null MODIFIER,
  '0' DEL_FLAG,
  null TS
FROM (SELECT PK_PD,ACOM.*,'D964843BC56E4E33A547AC1097B2848C' PK_UNIT from (SELECT DISTINCT QUANTITY,YB_ID,WMSPEC FROM A_BD_PD_CONVERT) ACOM
  INNER JOIN BD_PD PD ON PD.OLD_YB_ID = ACOM.YB_ID
WHERE NOT EXISTS( SELECT * FROM BD_PD_CONVERT CON WHERE PD.DEL_FLAG = 0 AND CON.PK_PD = PD.PK_PD AND QUANTITY = CON.PACK_SIZE));



SELECT PK_DEPT,PK_PD,NAME,acon.* from A_BD_PD_CONVERT acon
  INNER JOIN BD_PD pd on YB_ID = OLD_YB_ID
  INNER JOIN BD_OU_DEPT dept on dept.OLD_ID = DEPARTMENTID
where exists(
    --查找当前药房缺失的包装数量
    SELECT
      --NAME_DEPT,
      store.PK_DEPT,
      store.PK_PD
    --NAME,
    --PK_PDSTOREPACK,
    --pack.PK_PDCONVERT,
    --FLAG_DEF,
    --pack.PK_UNIT,
    --pack.PACK_SIZE
    FROM BD_PD_STORE store
      INNER JOIN BD_PD pd ON pd.PK_PD = store.PK_PD
      INNER JOIN BD_OU_DEPT dept ON dept.PK_DEPT = store.PK_DEPT
      LEFT JOIN BD_PD_STORE_PACK pack ON pack.PK_PDSTORE = store.PK_PDSTORE AND pack.DEL_FLAG = 0
    WHERE PK_PDSTOREPACK IS NULL
          AND exists(
              --用旧系统的数据,关联新系统的数据
              SELECT
                       PK_DEPT,
                       PK_PD,
                       acon.*
                     FROM A_BD_PD_CONVERT acon
                       INNER JOIN BD_PD pdd ON YB_ID = OLD_YB_ID
                       INNER JOIN BD_OU_DEPT deptt ON deptt.OLD_ID = DEPARTMENTID
                     WHERE pd.PK_PD = pdd.PK_PD AND deptt.PK_DEPT = store.PK_DEPT)
    --where store.PK_DEPT = '3E6F13C8B5F44204B852C83928A51307';
  and store.PK_DEPT =dept.PK_DEPT and store.PK_PD = pd.PK_PD
)


SELECT * from
(
  --缺少仓库包装单位
  SELECT store.PK_PDSTORE,store.FLAG_STOP,NAME,pd.PK_PD,NAME_DEPT, dept.PK_DEPT,QUANTITY,con.PK_PDCONVERT,con.PK_UNIT,con.PACK_SIZE from BD_PD_STORE_PACK pack
  RIGHT JOIN BD_PD_STORE store on pack.PK_PDSTORE = store.PK_PDSTORE and pack.DEL_FLAG = 0 and store.DEL_FLAG = 0
  INNER JOIN BD_PD pd on pd.PK_PD = store.PK_PD
  INNER JOIN BD_OU_DEPT dept on dept.PK_DEPT = store.PK_DEPT
  INNER JOIN (  SELECT
  PK_DEPT,
  PK_PD,
  acon.*
FROM A_BD_PD_CONVERT acon
  INNER JOIN BD_PD pdd ON YB_ID = OLD_YB_ID
  INNER JOIN BD_OU_DEPT deptt ON deptt.OLD_ID = DEPARTMENTID) acon on acon.PK_DEPT = dept.PK_DEPT and acon.PK_PD = store.PK_PD
  INNER JOIN BD_PD_CONVERT con on con.PK_PD = acon.PK_PD and QUANTITY = con.PACK_SIZE
where PK_PDSTOREPACK is null) store
 where exists(
  --如果旧系统有因子,则取因子
  SELECT
  PK_DEPT,
  PK_PD,
  acon.*
FROM A_BD_PD_CONVERT acon
  INNER JOIN BD_PD pdd ON YB_ID = OLD_YB_ID
  INNER JOIN BD_OU_DEPT deptt ON deptt.OLD_ID = DEPARTMENTID
  where pdd.PK_PD = store.PK_PD and deptt.PK_DEPT = store.PK_DEPT
 )
AND NAME  = '左乙拉西坦片'
;

--导入因子包装,来源于旧系统的数据
insert into BD_PD_STORE_PACK
select
  replace(sys_guid(), '-', '') PK_PDSTOREPACK,
  'a41476368e2943f48c32d0cb1179dab8' PK_ORG,
  PK_PDSTORE,
  PK_PDCONVERT,
  '1' FLAG_DEF,
  'ben0408' CREATOR,
  sysdate CREATE_TIME,
  null MODIFIER,
  null MODITY_TIME,
  '0' DEL_FLAG,
  null TS,
  PK_UNIT,
  PACK_SIZE
from (SELECT * from
(
  --缺少仓库包装单位
  SELECT store.PK_PDSTORE,store.FLAG_STOP,NAME,pd.PK_PD,NAME_DEPT, dept.PK_DEPT,QUANTITY,con.PK_PDCONVERT,con.PK_UNIT,con.PACK_SIZE from BD_PD_STORE_PACK pack
  RIGHT JOIN BD_PD_STORE store on pack.PK_PDSTORE = store.PK_PDSTORE and pack.DEL_FLAG = 0 and store.DEL_FLAG = 0
  INNER JOIN BD_PD pd on pd.PK_PD = store.PK_PD
  INNER JOIN BD_OU_DEPT dept on dept.PK_DEPT = store.PK_DEPT
  INNER JOIN (  SELECT
  PK_DEPT,
  PK_PD,
  acon.*
FROM A_BD_PD_CONVERT acon
  INNER JOIN BD_PD pdd ON YB_ID = OLD_YB_ID
  INNER JOIN BD_OU_DEPT deptt ON deptt.OLD_ID = DEPARTMENTID) acon on acon.PK_DEPT = dept.PK_DEPT and acon.PK_PD = store.PK_PD
  INNER JOIN BD_PD_CONVERT con on con.PK_PD = acon.PK_PD and QUANTITY = con.PACK_SIZE
where PK_PDSTOREPACK is null) store
 where exists(
  --如果旧系统有因子,则取因子
  SELECT
  PK_DEPT,
  PK_PD,
  acon.*
FROM A_BD_PD_CONVERT acon
  INNER JOIN BD_PD pdd ON YB_ID = OLD_YB_ID
  INNER JOIN BD_OU_DEPT deptt ON deptt.OLD_ID = DEPARTMENTID
  where pdd.PK_PD = store.PK_PD and deptt.PK_DEPT = store.PK_DEPT
 ));


--导入因子包装,来源于BD_PD_CONVERT
--insert into BD_PD_STORE_PACK
select
  replace(sys_guid(), '-', '') PK_PDSTOREPACK,
  'a41476368e2943f48c32d0cb1179dab8' PK_ORG,
  PK_PDSTORE,
  PK_PDCONVERT,
  '1' FLAG_DEF,
  'ben0408' CREATOR,
  sysdate CREATE_TIME,
  null MODIFIER,
  null MODITY_TIME,
  '0' DEL_FLAG,
  null TS,
  PK_UNIT,
  PACK_SIZE
from (--在旧系统的因子表中找不到数据
SELECT * from
(
  --缺少仓库包装单位
  SELECT store.PK_PDSTORE,store.FLAG_STOP,NAME,pd.PK_PD,NAME_DEPT, dept.PK_DEPT,con.PK_PDCONVERT,con.PK_UNIT,con.PACK_SIZE from BD_PD_STORE_PACK pack
  RIGHT JOIN BD_PD_STORE store on pack.PK_PDSTORE = store.PK_PDSTORE and pack.DEL_FLAG = 0 and store.DEL_FLAG = 0
  INNER JOIN BD_PD pd on pd.PK_PD = store.PK_PD
  INNER JOIN BD_OU_DEPT dept on dept.PK_DEPT = store.PK_DEPT
  INNER JOIN BD_PD_CONVERT con on con.PK_PD = pd.PK_PD and con.FLAG_IP = 1 and con.DEL_FLAG = 0
--   INNER JOIN (  SELECT
--   PK_DEPT,
--   PK_PD,
--   acon.*
-- FROM A_BD_PD_CONVERT acon
--   INNER JOIN BD_PD pdd ON YB_ID = OLD_YB_ID
--   INNER JOIN BD_OU_DEPT deptt ON deptt.OLD_ID = DEPARTMENTID) acon on acon.PK_DEPT = dept.PK_DEPT and acon.PK_PD = store.PK_PD
--   INNER JOIN BD_PD_CONVERT con on con.PK_PD = acon.PK_PD and QUANTITY = con.PACK_SIZE
where PK_PDSTOREPACK is null));

--349
SELECT
  deptt.PK_DEPT,deptt.NAME_DEPT,
  pdd.PK_PD,CODE,pdd.NAME,
  acon.QUANTITY,
  t.PACK_SIZE,FLAG_DEF,
  store.PK_UNIT,
  store.PK_PDSTORE,
  con.PK_PDCONVERT,store.PK_PDSTORE,PK_PDSTOREPACK
FROM A_BD_PD_CONVERT acon
  INNER JOIN BD_PD pdd ON YB_ID = OLD_YB_ID and DEL_FLAG = 0
  INNER JOIN BD_OU_DEPT deptt ON deptt.OLD_ID = DEPARTMENTID and deptt.DEL_FLAG = 0
  --因子包装与药品包装的关联
  INNER JOIN BD_PD_CONVERT con ON con.PK_PD = pdd.PK_PD AND QUANTITY = con.PACK_SIZE and con.DEL_FLAG = 0
  INNER JOIN BD_PD_STORE store ON store.PK_PD = pdd.PK_PD AND store.PK_DEPT = deptt.PK_DEPT and store.DEL_FLAG = 0
  --旧系统的因子包装关联新系统的包装,t为当前药品的处方包装,如果包装数量不相等,则需要更改包装单位
  INNER JOIN
  (SELECT *
   FROM
     (
       --所有的仓库包装单位
       SELECT
         store.PK_PDSTORE,
         store.FLAG_STOP,
         pd.NAME,
         pd.PK_PD,
         dept.NAME_DEPT,
         dept.PK_DEPT,
         pack.PK_PDCONVERT,
        --包装主键
         pack.PK_UNIT,
        --包装单位
         pack.PACK_SIZE,
        --包装数量
         pack.FLAG_DEF,PK_PDSTOREPACK
       FROM BD_PD_STORE_PACK pack
         INNER JOIN BD_PD_STORE store ON pack.PK_PDSTORE = store.PK_PDSTORE AND pack.DEL_FLAG = 0 AND store.DEL_FLAG = 0 and pack.DEL_FLAG = 0
         INNER JOIN BD_PD pd ON pd.PK_PD = store.PK_PD and pd.DEL_FLAG = 0
         INNER JOIN BD_OU_DEPT dept ON dept.PK_DEPT = store.PK_DEPT
     )) t ON t.PK_PDSTORE = store.PK_PDSTORE
where t.PK_PDCONVERT <> con.PK_PDCONVERT
--cast(store.PACK_SIZE as VARCHAR2(10)) <> QUANTITY
;


--SELECT PK_PD,PACK_SIZE,PK_PDCONVERT from BD_PD_CONVERT GROUP BY PK_PD,PACK_SIZE,PK_PDCONVERT HAVING count(1) = 1;

-- UPDATE BD_PD_STORE_PACK
-- set DEL_FLAG = 1 , CREATOR = 'ben0408'
-- where PK_PDSTOREPACK in
      (SELECT DISTINCT
  PK_PDSTOREPACK
FROM A_BD_PD_CONVERT acon
  INNER JOIN BD_PD pdd ON YB_ID = OLD_YB_ID and DEL_FLAG = 0
  INNER JOIN BD_OU_DEPT deptt ON deptt.OLD_ID = DEPARTMENTID and deptt.DEL_FLAG = 0
  --因子包装与药品包装的关联
  INNER JOIN BD_PD_CONVERT con ON con.PK_PD = pdd.PK_PD AND QUANTITY = con.PACK_SIZE and con.DEL_FLAG = 0
  INNER JOIN BD_PD_STORE store ON store.PK_PD = pdd.PK_PD AND store.PK_DEPT = deptt.PK_DEPT and store.DEL_FLAG = 0
  --旧系统的因子包装关联新系统的包装,t为当前药品的处方包装,如果包装数量不相等,则需要更改包装单位
  INNER JOIN
  (SELECT *
   FROM
     (
       --所有的仓库包装单位
       SELECT
         store.PK_PDSTORE,
         store.FLAG_STOP,
         pd.NAME,
         pd.PK_PD,
         dept.NAME_DEPT,
         dept.PK_DEPT,
         pack.PK_PDCONVERT,
        --包装主键
         pack.PK_UNIT,
        --包装单位
         pack.PACK_SIZE,
        --包装数量
         pack.FLAG_DEF,PK_PDSTOREPACK
       FROM BD_PD_STORE_PACK pack
         INNER JOIN BD_PD_STORE store ON pack.PK_PDSTORE = store.PK_PDSTORE AND pack.DEL_FLAG = 0 AND store.DEL_FLAG = 0 and pack.DEL_FLAG = 0
         INNER JOIN BD_PD pd ON pd.PK_PD = store.PK_PD and pd.DEL_FLAG = 0
         INNER JOIN BD_OU_DEPT dept ON dept.PK_DEPT = store.PK_DEPT
     )) t ON t.PK_PDSTORE = store.PK_PDSTORE
where t.PK_PDCONVERT <> con.PK_PDCONVERT);
--cast(store.PACK_SIZE as VARCHAR2(10)) <> QUANTITY);

