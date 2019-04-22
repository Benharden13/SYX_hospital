SELECT
  DOC.NAME                           STTYPE,
  --业务类型
  PD.NAME,
  --药品名称
  PD.SPEC,
  FACTORY.NAME                       FACTORY,
  --库存
  UNIT.NAME                          UNITPACK,
  DT.QUAN_MIN                       QUANPACK,
  --数量,使用基本数量 QUAN_MIN = QUAN_OACK*PACK_SIZE
  DT.AMOUNT_COST                     AMOUNTCOST,
  --购入金额
  DT.AMOUNT                          AMOUNT,
  --临售金额
  ST.DATE_CHK,
  dept.NAME_DEPT
  
FROM PD_ST ST
  --出入库单明细
  INNER JOIN PD_ST_DETAIL DT ON ST.PK_PDST = DT.PK_PDST
  --药品
  INNER JOIN BD_PD PD ON DT.PK_PD = PD.PK_PD
  --厂商
  INNER JOIN BD_FACTORY FACTORY ON FACTORY.PK_FACTORY = PD.PK_FACTORY
  --包装单位
  LEFT JOIN BD_UNIT UNIT ON UNIT.PK_UNIT = PD.PK_UNIT_PACK
  --码表中的业务类型(出入库)
  INNER JOIN BD_DEFDOC DOC ON DOC.CODE = ST.DT_STTYPE AND DOC.CODE_DEFDOCLIST = '080008'
  --库单部门
  INNER JOIN BD_OU_DEPT dept on dept.PK_DEPT = ST.PK_DEPT_ST
 where {Sql.Where("{name}", "dt.pk_pd like '%{name}%' ")}
       and {Sql.Where("{stType}", " st.dt_sttype = '{stType}' ")}
       and {Sql.Where("{dateBegin}", "  st.date_chk >= to_date('{dateBegin} 00:00:00','yyyy-mm-dd hh24:mi:ss')")} 
       and {Sql.Where("{dateEnd}", "  st.date_chk <= to_date('{dateEnd} 23:59:59','yyyy-mm-dd hh24:mi:ss')")}
       and PK_DEPT_ST = '{pkDept}'
       --当前科室
       and st.flag_chk='1'
       --单子状态必须是审核状态,否则不入统计
       ORDER BY st.dt_sttype ASC
