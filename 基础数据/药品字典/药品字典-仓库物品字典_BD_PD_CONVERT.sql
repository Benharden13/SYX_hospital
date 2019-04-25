--查询各个科室/药房/库房的药品清单数量
--SELECT DEPARTMENTNAME,DEPARTMENTID,count(1) FROM A_BD_PD_STORE GROUP BY  DEPARTMENTNAME,DEPARTMENTID

--该脚本用于生产仓库物品
insert into BD_PD_STORE
	select
		replace(sys_guid(), '-', '')       PK_PDSTORE,
		'a41476368e2943f48c32d0cb1179dab8' PK_ORG,
		 PK_DEPT,
		 PK_STORE,
		PK_PD                              PK_PD,
		PK_PDCONVERT                       PK_PDCONVERT,
		'0'                                FLAG_STOP,
		NULL                            POSI_NO,
		'1000'                             STOCK_MAX,
		'100'                              STOCK_MIN,
		'180'                              COUNT_PER,
		null                               LAST_DATE,
		'20190403'                         CREATOR,
		SYSDATE                            CREATE_TIME,
		null                               MODIFIER,
		'0'                                DEL_FLAG,
		null                               TS,
		null                               QUAN_THRE,
		PK_UNIT                       PK_UNIT,
		--包装单位
		PACK_SIZE                          PACK_SIZE
from (SELECT bdstore.PK_STORE,adept.PK_DEPT,con.PK_PDCONVERT,unit.PK_UNIT,pd.PK_PD,con.PACK_SIZE,PK_PDSTORE,pd.NAME,astore.* from A_BD_PD_STORE astore
  INNER JOIN BD_OU_DEPT adept on adept.OLD_ID = DEPARTMENTID
  --获取仓库主键
  INNER JOIN BD_STORE bdstore on bdstore.PK_DEPT = adept.PK_DEPT
  INNER JOIN BD_PD pd on pd.OLD_YB_ID = YB_ID
  INNER JOIN BD_PD_CONVERT con on con.PK_PD = pd.PK_PD and con.FLAG_IP = 1 and pd.DEL_FLAG = 0 and con.DEL_FLAG = 0 and FLAG_STOP = 0
  INNER JOIN BD_UNIT unit on unit.PK_UNIT = con.PK_UNIT
  LEFT JOIN BD_PD_STORE store on store.PK_DEPT = adept.PK_DEPT and store.PK_PD = pd.PK_PD
where DEPARTMENTID in ('1604','1809','2101','1871','2408','2055','1870','1674','1810','1599','2854','1601','2546','2544')
      --这些是所有药房的id '南院中心药房','南院中药房','中心药房','门诊西药房','急诊药房','保健药房','特诊中心药房','南院药房','门诊中药房','南院西药房','门诊自助药房','南院急诊药房',两个静配中心
      and USINGSCOPEFLAG <> 0 and PK_PDSTORE is null
      and ( NOT (NAME_DEPT = '南院中药房' and YB_ID like '1-%' and STOCK = 0 ) and (pd.NAME not LIKE '%(自%' AND pd.NAME not LIKE '%（自%' ) and STOCK <> 0));
      --发现中药房有西药记录,这个可不导入,条件:不包括中药房的西药导入,而且库存为0而且不是自备药)



---检查对照关系,保证OLD_ID,OLD_YB_ID,OLD_CODE唯一而且不为空
SELECT PK_PD,code,name,SPEC,OLD_YB_ID,OLD_ID,OLD_CODE,DEL_FLAG from BD_PD 
where OLD_YB_ID is null or OLD_ID is null or OLD_CODE is null or OLD_CODE like '%-%' or OLD_ID like '%-%'  or OLD_YB_ID NOT like '%-%';
SELECT PK_PD,code,name,SPEC,OLD_YB_ID,OLD_ID,OLD_CODE,DEL_FLAG,FLAG_STOP,PRICE,CREATE_TIME,PK_FACTORY from BD_PD where OLD_ID <> '1'  and  OLD_YB_ID in
         (SELECT OLD_YB_ID from BD_PD  GROUP BY OLD_YB_ID HAVING count(1) > 1);


-------------------------------------------------------------------------------------------------------------------------------
---
/*
	获取旧系统仓库物品的数据

	  仓库物品维护
	  usingScopeFlag  使用范围
	    0的是不使用
	    1=门诊使用
	    2=住院使用
	    3=门诊,住院使用
	  stock 库存数量
	    为0表示没有库存,部分7开头的药品(自购药)即使库存为0也需要在新系统进行维护
*/

with stock as (SELECT
	c.DepartmentID                     DepartmentID,
	c.DepartmentName                   DepartmentName,
	'1-' + cast(B.WMID AS VARCHAR(10)) YB_ID,
	B.WMNo                             WMNo,
	B.WMName,
	WMSpec,
	Stock,
	A.UsingScopeFlag
	--这是库存中的使用标志,标明这个药品允许住院还是门诊使用,3是住院与门诊,1是门诊,2是住院,同时药品本身也有一个这个字段,但是在导入时没有用到
--西药库存表
FROM tWMStock A
--关联西药明细
INNER JOIN tbWM B ON A.WMID = B.WMID
--关联使用药房
INNER JOIN tbDepartment c ON c.DepartmentID = A.MedicineDepartmentID
where b.IdleFlag = 0 AND
			DepartmentID <> '-1'  -- -1为根科室
UNION ALL
SELECT
	c.DepartmentID                     DEPT_ID,
	c.DepartmentName                   DEPT_NAME,
	'1-' + cast(B.PCMID AS VARCHAR(10)) YB_ID,
	B.PCMNo                             CODE,
	B.PCMName,
	PCMSpec,
	Stock,
	A.UsingScopeFlag
	--这是库存中的使用标志,标明这个药品允许住院还是门诊使用,3是住院与门诊,1是门诊,2是住院,同时药品本身也有一个这个字段,但是在导入时没有用到
--西药库存表
FROM tPCMStock A
--关联西药明细
INNER JOIN tbPCM B ON A.PCMID = B.PCMID
--关联使用药房
INNER JOIN tbDepartment c ON c.DepartmentID = A.MedicineDepartmentID
where b.IdleFlag = 0 AND DepartmentID <> '-1'
UNION ALL
SELECT
	c.DepartmentID                     DEPT_ID,
	c.DepartmentName                   DEPT_NAME,
	'1-' + cast(B.TCMID AS VARCHAR(10)) YB_ID,
	B.TCMNo                             CODE,
	B.TCMName,
	TCMSpec,
	Stock,
	A.UsingScopeFlag
	--这是库存中的使用标志,标明这个药品允许住院还是门诊使用,3是住院与门诊,1是门诊,2是住院,同时药品本身也有一个这个字段,但是在导入时没有用到
--西药库存表
FROM tTCMStock A
--关联西药明细
INNER JOIN tbTCM B ON A.TCMID = B.TCMID
--关联使用药房
INNER JOIN tbDepartment c ON c.DepartmentID = A.MedicineDepartmentID
where b.IdleFlag = 0 AND DepartmentID <> '-1')
SELECT * from stock
  where UsingScopeFlag <> 0
        --药房
        AND DepartmentID in ('1604','1809','2101','1871','2408','2055','1870','1674','1810','1599','2854','1601','2546','2544')
        --药库
        OR  DepartmentID in ('2051','2579','2062','2485')
order by DepartmentID,YB_ID asc



/*
	新系统的仓库物品字典
*/

SELECT
  PK_PDSTORE,
  dept.PK_DEPT,
  dept.OLD_ID deptOldId,
  NAME,
  NAME_DEPT,
  pd.PK_PD,
  pd.OLD_YB_ID pdOldId,
  store.FLAG_STOP
FROM BD_PD_STORE store
  INNER JOIN BD_OU_DEPT dept ON dept.PK_DEPT = store.PK_DEPT
  INNER JOIN BD_PD pd ON pd.PK_PD = store.PK_PD
WHERE
      --药房药库的数据,没有停止没有删除
      (dept.OLD_ID IN
      ('1604', '1809', '2101', '1871', '2408', '2055', '1870', '1674', '1810', '1599', '2854', '1601', '2546', '2544')
      OR dept.OLD_ID IN ('2051', '2579', '2062', '2485'))
      and store.DEL_FLAG = 0 and store.FLAG_STOP = 0
order by dept.OLD_ID, pd.OLD_YB_ID asc