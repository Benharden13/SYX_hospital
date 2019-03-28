--该脚本用于生产仓库物品

insert into BD_PD_STORE
	select
		replace(sys_guid(), '-', '')       PK_PDSTORE,
		'a41476368e2943f48c32d0cb1179dab8' PK_ORG,
		 PK_DEPT,
		--变量
		 PK_STORE,
		--变量
		PK_PD                              PK_PD,
		PK_PDCONVERT                       PK_PDCONVERT,
		'0'                                FLAG_STOP,
		NULL                            POSI_NO,
		'1000'                             STOCK_MAX,
		'100'                              STOCK_MIN,
		'180'                              COUNT_PER,
		null                               LAST_DATE,
		'20190328'                         CREATOR,
		SYSDATE                            CREATE_TIME,
		null                               MODIFIER,
		'0'                                DEL_FLAG,
		null                               TS,
		null                               QUAN_THRE,
		PK_UNIT                       PK_UNIT,
		--包装单位
		PACK_SIZE                          PACK_SIZE
from (SELECT pd.PK_PD,PK_PDCONVERT,con.PACK_SIZE,PK_UNIT,DEPARTMENTNAME,dept.PK_DEPT,PK_STORE
FROM A_BD_PD_STORE astore
  LEFT JOIN BD_PD pd ON pd.OLD_YB_ID = astore.YB_ID AND YB_ID LIKE '1%' AND DEL_FLAG = 0 AND FLAG_STOP = 0
  --YB_ID为1 表示西药,未删除,未停用
  INNER JOIN BD_PD_CONVERT con on con.PK_PD = pd.PK_PD and FLAG_IP = 1 and con.DEL_FLAG = 0
  --FLAP_IP表示住院包装,如果使用门诊包装则换成OP
  INNER JOIN BD_OU_DEPT dept on dept.OLD_ID = DEPARTMENTID and dept.DEL_FLAG = 0
  INNER JOIN BD_STORE store on store.PK_DEPT = dept.PK_DEPT and store.DEL_FLAG = 0
WHERE DEPARTMENTNAME IN ('中心药房', '静脉配置中心')
      AND USINGSCOPEFLAG IN ('2', '3')
      --表示使用范围,2,3表示住院
      AND pd.OLD_ID is NOT null
      --过滤掉未匹配的数据
      and not exists(select * from BD_PD_STORE storeo
        INNER JOIN BD_PD pdo on pdo.PK_PD = storeo.PK_PD
        where storeo.PK_STORE = store.PK_STORE and storeo.PK_DEPT = store.PK_DEPT and pdo.PK_PD = pd.PK_PD)
      --过滤掉已经存在的bd_pd_store中的数据,防止重复添加
)


---获取旧系统仓库物品的数据
SELECT c.DepartmentID DEPT_ID, c.DepartmentName DEPT_NAME,
	'1-'+cast(B.WMID as varchar(10)) YB_ID, B.WMNo CODE,
	B.WMName
FROM tWMStock A
INNER JOIN tbWM B ON A.WMID = B.WMID
INNER JOIN tbDepartment c ON c.DepartmentID = A.MedicineDepartmentID
where b.IdleFlag = 0

SELECT c.DepartmentID , c.DepartmentName , B.PCMID , B.PCMNo , B.PCMName , B.PCMSpec , A.Stock , A.MinStock,a.*
FROM tPCMStock A
INNER JOIN tbPCM B ON A.PCMID = B.PCMID
INNER JOIN tbDepartment c ON c.DepartmentID = A.MedicineDepartmentID
WHERE A.MedicineDepartmentID = '2652'
where b.IdleFlag = 0

SELECT c.DepartmentID , c.DepartmentName , B.TCMID , B.TCMNo , B.TCMName , B.TCMSpec , A.Stock , A.MinStock,a.*
FROM tTCMStock A
INNER JOIN tbTCM B ON A.TCMID = B.TCMID
INNER JOIN tbDepartment c ON c.DepartmentID = A.MedicineDepartmentID
WHERE A.MedicineDepartmentID = '2615'
where b.IdleFlag = 0
