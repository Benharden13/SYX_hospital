--如何获取新的数据sql
--缺失的数据人员-处方权关系
--人员表数据
SELECT
  EmployeeID,
  --OLD_ID
  EmployeeNo,
  --CODE
  EmployeeName,
  --NAME
  emp.SpellCode,
  emp.WBCode,
  IdentityCard,
  --idno 身份证号
  post.TechPostID,
  post.Description,
  --该字段数据可以用于新系统的dt_emptype,dt_empsrvtype
  duty.DutyID,
  duty.Description,
  CASE WHEN SexFlag = 0
    THEN '04'
  WHEN SexFlag = 1
    THEN '02'
  WHEN SexFlag = 2
    THEN '03'
  end  SexFlag,
  --dt_sex 性别
  emp.DepartmentID
  --人员所属科室,对应表bd_ou_empjob
FROM tbEmployee emp
  INNER JOIN tbDepartment dept on emp.DepartmentID = dept.DepartmentID
  LEFT JOIN tbDuty duty on emp.DutyID = duty.DutyID
  LEFT JOIN tbTechPost post on post.TechPostID = emp.TechPostID
WHERE emp.IdleFlag = 0