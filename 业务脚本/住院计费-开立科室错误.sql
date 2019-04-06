
---修改计费表中的开立科室
/*需要注意的是,有的患者有转科记录,所以无法确认开立科室,需要单独处理*/

UPDATE BL_IP_DT ip
set PK_DEPT_APP = (SELECT  dept.PK_DEPT
                   --更新字段,用患者在转科记录中的数据,当前语句只处理没有转过科的患者
                   from BL_IP_DT cg
  INNER JOIN BD_OU_DEPT deptapp on deptapp.PK_DEPT = PK_DEPT_APP and DT_DEPTTYPE <> '01' and NAME_DEPT <> '电脑床位测试病区护理单元' --and NAME_DEPT = '病理科'
  INNER JOIN pv_adt adt on adt.PK_PV = cg.PK_PV
  INNER JOIN BD_OU_DEPT dept on dept.PK_DEPT = adt.PK_DEPT
where cg.PK_PV in (
SELECT PK_PV from
  (SELECT DISTINCT cg.PK_PV,adt.PK_DEPT from BL_IP_DT cg
  INNER JOIN BD_OU_DEPT deptapp on deptapp.PK_DEPT = PK_DEPT_APP and DT_DEPTTYPE <> '01' and NAME_DEPT <> '电脑床位测试病区护理单元'
  INNER JOIN pv_adt adt on adt.PK_PV = cg.PK_PV
) GROUP BY PK_PV HAVING count(1) = 1)  and cg.PK_CGIP = ip.PK_CGIP
  --关联条件,使用计费表主键
)
where exists(SELECT  PK_CGIP from BL_IP_DT cg
  INNER JOIN BD_OU_DEPT deptapp on deptapp.PK_DEPT = PK_DEPT_APP and DT_DEPTTYPE <> '01' and NAME_DEPT <> '电脑床位测试病区护理单元' --and NAME_DEPT = '病理科'
  INNER JOIN pv_adt adt on adt.PK_PV = cg.PK_PV
  INNER JOIN BD_OU_DEPT dept on dept.PK_DEPT = adt.PK_DEPT
where cg.PK_PV in (
SELECT PK_PV from
  (SELECT DISTINCT cg.PK_PV,adt.PK_DEPT from BL_IP_DT cg
  INNER JOIN BD_OU_DEPT deptapp on deptapp.PK_DEPT = PK_DEPT_APP and DT_DEPTTYPE <> '01' and NAME_DEPT <> '电脑床位测试病区护理单元'
  INNER JOIN pv_adt adt on adt.PK_PV = cg.PK_PV
) GROUP BY PK_PV HAVING count(1) = 1) and cg.PK_CGIP = ip.PK_CGIP);

SELECT  PK_CGIP,deptapp.NAME_DEPT,DATE_CG,DATE_BEGIN,DATE_END from BL_IP_DT cg
  INNER JOIN BD_OU_DEPT deptapp on deptapp.PK_DEPT = PK_DEPT_APP and DT_DEPTTYPE <> '01' and NAME_DEPT <> '电脑床位测试病区护理单元' --and NAME_DEPT = '病理科'
  INNER JOIN pv_adt adt on adt.PK_PV = cg.PK_PV
  INNER JOIN BD_OU_DEPT dept on dept.PK_DEPT = adt.PK_DEPT
where cg.PK_PV in (
SELECT PK_PV from
  (SELECT DISTINCT cg.PK_PV,adt.PK_DEPT from BL_IP_DT cg
  INNER JOIN BD_OU_DEPT deptapp on deptapp.PK_DEPT = PK_DEPT_APP and DT_DEPTTYPE <> '01' and NAME_DEPT <> '电脑床位测试病区护理单元'--and NAME_DEPT = '输血科'
  INNER JOIN pv_adt adt on adt.PK_PV = cg.PK_PV
) GROUP BY PK_PV)



/*处理患者有两条转科记录*/

UPDATE BL_IP_DT ipcg
set PK_DEPT_APP = (SELECT adt.PK_DEPT from BL_IP_DT cg
  INNER JOIN BD_OU_DEPT deptapp on deptapp.PK_DEPT = cg.PK_DEPT_APP and DT_DEPTTYPE <> '01' and NAME_DEPT <> '电脑床位测试病区护理单元'
  INNER JOIN (SELECT
                PK_PV,
                NAME_DEPT,
                DATE_BEGIN,
                DATE_END,adt.PK_DEPT
              FROM PV_ADT adt
                INNER JOIN BD_OU_DEPT deptapp ON deptapp.PK_DEPT = adt.PK_DEPT
              --WHERE PK_PV = '23983d70afb2489b9aa37f04d4aedd99'
             ) adt ON adt.PK_PV = cg.PK_PV AND DATE_CG > DATE_BEGIN AND DATE_CG < DATE_END where cg.PK_CGIP = ipcg.PK_CGIP)
where exists(SELECT 1 from BL_IP_DT cg
  INNER JOIN BD_OU_DEPT deptapp on deptapp.PK_DEPT = cg.PK_DEPT_APP and DT_DEPTTYPE <> '01' and NAME_DEPT <> '电脑床位测试病区护理单元'
  INNER JOIN (SELECT
                PK_PV,
                NAME_DEPT,
                DATE_BEGIN,
                DATE_END,adt.PK_DEPT
              FROM PV_ADT adt
                INNER JOIN BD_OU_DEPT deptapp ON deptapp.PK_DEPT = adt.PK_DEPT
              --WHERE PK_PV = '23983d70afb2489b9aa37f04d4aedd99'
             ) adt ON adt.PK_PV = cg.PK_PV
                      --AND DATE_CG > DATE_BEGIN AND DATE_CG < DATE_END
                      --如果出院的患者,上面的条件可以,
                      --AND DATE_CG > DATE_BEGIN AND DATE_END IS NULL
                      --在院患者他的DATE_END为空
                      --还发现5条记录的计费时间不在结束时间中,所有取消以上条件(前提患者只有一个转科记录)
where cg.PK_CGIP = ipcg.PK_CGIP);


SELECT
  deptapp.NAME_DEPT,
  DATE_CG,cg.PK_PV,
  adt.NAME_DEPT
FROM BL_IP_DT cg
  INNER JOIN BD_OU_DEPT deptapp
    ON deptapp.PK_DEPT = cg.PK_DEPT_APP AND DT_DEPTTYPE <> '01' AND NAME_DEPT <> '电脑床位测试病区护理单元'
  INNER JOIN (SELECT
                PK_PV,
                NAME_DEPT,
                DATE_BEGIN,
                DATE_END,
                adt.PK_DEPT
              FROM PV_ADT adt
                INNER JOIN BD_OU_DEPT deptapp ON deptapp.PK_DEPT = adt.PK_DEPT
               --WHERE PK_PV = '23983d70afb2489b9aa37f04d4aedd99'
             ) adt ON adt.PK_PV = cg.PK_PV
              --AND DATE_CG > DATE_BEGIN AND DATE_CG < DATE_END
              --AND DATE_CG > DATE_BEGIN AND DATE_END IS NULL
--计费时间在患者转科记录中的时间,
--where cg.PK_PV = '23983d70afb2489b9aa37f04d4aedd99';
