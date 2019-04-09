SELECT  'aaa' aaa,detail.PK_PDAPDT pdapdt,
            pi.code_ip, --住院号
    --pi.CODE_OP codeIp,--门诊号
    pi.name_pi namePi, --患者姓名
   case when pv.DT_SEX = '02' then '男' else '女' end sex , --性别
   BED_NO bed, --床位
   pv.TEL_REL tel, --电话
   NAME_DEPT nameDept, --所在科室
   PD.NAME nameOrd,    --药品名称
   ord.spec,        --规格
   ord.dosage,      --用量
     unit_dos.name unitDos, --用量单位
   sup.name sup,    --用法
   sup.NAME_PRINT supprint, --用法打印名称
   freq.name freq,  --频次
   ord.quan,        --数量
   unit.name nameUnit,       --数量单位
   NAME_EMP nameEmp,--医生
   CODE_EMP codeEmp, --工号
   NAME_DIAG nameDiag, --诊断
   AGE_PV age, --年龄
   ID_NO idNo, --身份证
   DATE_SIGN datesign, --签署日期
   concat(pv.addr_cur, pv.ADDR_CUR_DT) addr, --地址
  VOL vol --默认剂量
      from EX_PD_APPLY apply
  INNER JOIN EX_PD_APPLY_DETAIL detail on apply.PK_PDAP = detail.PK_PDAP
  INNER JOIN bl_ip_dt ipdt ON ipdt.PK_PDSTDT = detail.PK_PDAPDT
  inner join cn_order ord on ipdt.PK_CNORD=ord.PK_CNORD
  inner join pv_encounter pv on ipdt.pk_pv=pv.pk_pv
     inner join pi_master pi on pv.pk_pi=pi.pk_pi
   --inner join bd_defdoc pt on pres.dt_prestype=pt.code and pt.code_defdoclist='060101'
   inner join bd_unit unit_dos on ord.pk_unit_dos=unit_dos.pk_unit
   inner join bd_unit unit on ord.pk_unit=unit.pk_unit
   inner join bd_supply sup on ord.code_supply=sup.code
   inner join bd_term_freq freq on ord.code_freq=freq.code
   INNER JOIN BD_OU_DEPT dept on dept.PK_DEPT = pv.PK_DEPT
   INNER JOIN BD_OU_EMPLOYEE emp on emp.PK_EMP = PK_EMP_ORD
   INNER JOIN PV_DIAG diag on diag.PK_PV = pv.PK_PV and FLAG_MAJ = 1 and diag.DEL_FLAG = '0'
   INNER JOIN BD_PD PD ON PD.PK_PD = ORD.PK_ORD
   where detail.PK_PDAP = '049ca0c4ddc44d1eb889fc1643c9e64c'
   --detail.{Sql.In(pk_pdap,'{pkPdap}')} 
  Order BY NAME_ORD,pv.NAME_PI asc




select cg.date_cg,
       dept.name_dept,
       pi.code_ip,
       pi.name_pi,
       pv.age_pv,
       pv.dt_sex,
       pi.id_no,
       diag.name_diag,
       cg.name_cg,
       cg.spec,
       QUAN quan,
       unit.name unit,
       cg.batch_no,  --空瓶批号
       cg.name_emp_app
             apply.date_ap,   --请领时间
          CASE WHEN eu_print = '0'
    THEN 0
  ELSE 1 END eu_print --打印标志
  from EX_PD_APPLY apply
  INNER JOIN EX_PD_APPLY_DETAIL detail on detail.PK_PDAP = apply.PK_PDAP
  INNER JOIN BL_IP_DT cg on cg.PK_PDSTDT = detail.PK_PDAPDT
  inner join pv_encounter pv on cg.pk_pv=pv.pk_pv
  inner join pi_master pi on pv.pk_pi=pi.pk_pi
  inner join bd_unit unit on cg.pk_unit=unit.pk_unit
  inner join bd_ou_dept dept on cg.pk_dept_app=dept.pk_dept
  left outer join pv_diag diag on pv.pk_pv=diag.pk_pv and diag.flag_maj='1'
 where apply.PK_PDAP = '049ca0c4ddc44d1eb889fc1643c9e64c'
   and PK_CGIP_BACK is null
   --退费记录为空,就意味着这条记费记录是正确的,需要请领药品,不为空的就是产生了退费记录
  and not exists(SELECT 1 from BL_IP_DT ipcg where PK_CGIP_BACK is not null and ipcg.PK_CGIP_BACK = cg.PK_CGIP)
  --如果PK_CGIP_BACK = PK_CGIP,就意味着这条记录是是退费记录
ORDER BY NAME_CG,NAME_PI ASC;
-- group by cg.date_cg,
--        dept.name_dept,
--        pi.code_ip,
--        pi.name_pi,
--        pv.age_pv,
--        pv.dt_sex,
--        pi.id_no,
--        diag.name_diag,
--        cg.name_cg,
--        cg.spec,
--        unit.name,
--        cg.batch_no,
--        cg.name_emp_app;



select cg.date_cg,
       dept.name_dept,
       pi.code_ip,
       pi.name_pi,
       pv.age_pv,
       pv.dt_sex,
       pi.id_no,
       diag.name_diag,
       cg.name_cg,
       cg.spec,
       QUAN quan,
       unit.name unit,
       cg.batch_no,  --空瓶批号
       cg.name_emp_app,
      CODE_APPLY,
      apply.date_ap   --请领时间
  from EX_PD_APPLY apply
  INNER JOIN EX_PD_APPLY_DETAIL detail on detail.PK_PDAP = apply.PK_PDAP
  INNER JOIN BL_IP_DT cg on cg.PK_PDSTDT = detail.PK_PDAPDT
  inner join pv_encounter pv on cg.pk_pv=pv.pk_pv
  inner join pi_master pi on pv.pk_pi=pi.pk_pi
  inner join bd_unit unit on cg.pk_unit=unit.pk_unit
  inner join bd_ou_dept dept on cg.pk_dept_app=dept.pk_dept
  left outer join pv_diag diag on pv.pk_pv=diag.pk_pv and diag.flag_maj='1'
 where  detail.{Sql.In(pk_pdap,'{pkPdap}')}
ORDER BY NAME_CG,NAME_PI ASC