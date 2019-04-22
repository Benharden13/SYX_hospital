SELECT '1-' + cast(WMID as varchar(10)) WMID,WMName,DepartmentID,DepartmentName, '1' eu_ctrltype from tbSourceItemUseLimit limit
  INNER JOIN tbWM wm on wm.WMID = SourceID and SourceType = 1
  inner JOIN tbDepartment dept on dept.DepartmentID = limit.LimitSourceID and LimitSourceType in ('1','4')
  --1,4代表科室
where limit.IdleFlag = 0 and wm.IdleFlag = 0
UNION ALL
SELECT '1-' + cast(WMID as varchar(10)),WMName,EmployeeID,EmployeeName, '0' eu_ctrltype from tbSourceItemUseLimit limit
  INNER JOIN tbWM wm on wm.WMID = SourceID
  INNER JOIN tbEmployee emp ON emp.EmployeeID = LimitSourceID and LimitSourceType in ('2')
  --代表人员
where limit.IdleFlag = 0 and wm.IdleFlag = 0





INSERT into BD_PD_REST
SELECT
  replace(sys_guid(), '-', '') PK_PDREST,
  'a41476368e2943f48c32d0cb1179dab8' PK_ORG,
  PK_PD,
  EU_CTRLTYPE,
  CASE when t.EU_CTRLTYPE = 0 then PK_DEPT else null end PK_EMP,
  CASE when t.EU_CTRLTYPE = 0 then NAME_EMP else null end NAME_EMP,
  CASE when t.EU_CTRLTYPE = 1 then PK_DEPT else null end PK_DEPT,
  null PK_DIAG,
  null PK_DEPT_PHARM,
  'zlx0418' CREATOR,
  null CREATE_TIME,
  null MODIFIER,
  null MODITY_TIME,
  0 DEL_FLAG,
  null TS
FROM (SELECT PK_PD,PK_DEPT,null NAME_EMP,EU_CTRLTYPE FROM A_BD_PD_REST1 rest
 INNER JOIN BD_OU_DEPT dept on dept.OLD_ID = rest.DEPARTMENTID and EU_CTRLTYPE = 1
 INNER JOIN BD_PD pd on pd.OLD_YB_ID = rest.WMID
union ALL
SELECT PK_PD,PK_EMP,NAME_EMP,EU_CTRLTYPE FROM A_BD_PD_REST1 rest
 INNER JOIN BD_OU_EMPLOYEE emp on emp.OLD_ID = rest.DEPARTMENTID and EU_CTRLTYPE = 0
 INNER JOIN BD_PD pd on pd.OLD_YB_ID = rest.WMID) t;
