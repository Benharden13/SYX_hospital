select distinct
  WM.WMID                                                          OLD_ID,
  --旧系统药品ID,用于关联
  wm.WMNo                                                          code,
  --编码
  wm.WMName                                                        name,
  --药品名称
  WMSpec                                                           spec,
  --规格
  wmdetail.WMTradeName                                             name_chem,
  --商品名
  wm.WMLabelName                                                   short_name,
  --标签名
  wm.SpellCode                                                     spcode,
  --助记码
  wm.WBCode                                                        pycode,
  --五笔码
  WMDosage                                                         vol,
  --剂量
  WMDosageUnit                                                     pk_unit_vol,
  --@剂量单位
  WMUnit                                                           pk_unit_min,
  --@基本单位
  Wmdetail.TransRate                                               pack_size,
  --包装数量
  wmdetail.PackageUnit                                             pk_unit_pack,
  --@包装单位
  case when wm.IntegratingTypeFlag in ('0', '3')
    then '0'
  when wm.IntegratingTypeFlag in ('1', '2')
    then '1' end                                                   eu_muputype,
  --包装单位取整模式
  wm.ProducerID                                                    pk_factory,
  --@生产厂家
  wm.ProviderID                                                    pk_ProviderID,
  --@供应商
  case when Wm.SpecialControlFlag = '0'
    then '00'
  when Wm.SpecialControlFlag = '1'
    then '01'
  when Wm.SpecialControlFlag = '2'
    then '04'
  when Wm.SpecialControlFlag = '3'
    then '02'
  when Wm.SpecialControlFlag = '4'
    then '03'
  when Wm.SpecialControlFlag = '5'
    then '00' --将未知规划到普通
  when Wm.SpecialControlFlag = '6'
    then '04'
  --  WHEN Wm.SpecialControlFlag = '7'
  --    THEN '(抗生)非限制使用的抗菌药物'
  --  WHEN Wm.SpecialControlFlag = '8'
  --    THEN '(抗生)限制使用的抗菌药物'
  --  WHEN Wm.SpecialControlFlag = '9'
  --    THEN '(抗生)特殊使用的抗菌药'
  when Wm.SpecialControlFlag = '10'
    then '06'
  when Wm.SpecialControlFlag = '11'
    then '05'
  when Wm.SpecialControlFlag = '16'
    then '04'
  end                                                              dt_pois,
  --毒麻分类
  case when Wm.SpecialControlFlag = '0'
    then '00'
  when Wm.SpecialControlFlag = '7'
    then '01'
  when Wm.SpecialControlFlag = '8'
    then '02'
  when Wm.SpecialControlFlag = '9'
    then '03' end                                                  dt_anti,
  --抗菌分类
  (select 1
   from tbWM pre
   where WMName like '△%' and IdleFlag = 0 and pre.WMID = wm.WMID) flag_precious,
  --贵重标志
  Wmdetail.WMBoxSpec                                               pack_size_max,
  --箱包装量
  Wm.AuthorizeNo                                                   appr_no,
  --批准文号/注册号
  wm.DoseTypeFlag                                                  dt_dosage,
  --药品剂型
  '0'                                                              eu_drugtype,
  --药品类别 0西药,1成药,2草药
  wmdetail.AddMultiRatio                                           pap_rate,
  --加成比例
  case when wm.SourceFlag = '0'
    then '01'
  when wm.SourceFlag = '1'
    then '02'
  when wm.SourceFlag = '2'
    then '03' end                                                  dt_abrd,
  --来源分类
  wm.DoseTypeFlag                                                  eu_usecate,
  --@@用法分类
  case when wmdetail.NationalityBaseMedicineFlag = '0'
    then '00'
  when wmdetail.NationalityBaseMedicineFlag = '1'
    then '01'
  when wmdetail.NationalityBaseMedicineFlag = '2'
    then '02' end                                                  dt_base,
  --基本药物分类
  wm.StuffFlag                                                     flag_rm,
  --原料标志
  case when usingst.SecondMedicineUsingMethodID is null
    then null
  else 1 end                                                       flag_st,
  --皮试标志
  case when sort.SourceID is null
    then null
  else 1 end                                                       flag_chrt,
  --化疗标志
  wmdetail.WMRemark                                                note,
  --备注
  wm.WMLimitDosagePerTime                                          quota_dos,
  --用量上限
  wm.DefaultDosagePerTime                                          dosage_def,
  --默认用量
  using.MedicineUsingMethodID                                      code_supply,
  --默认用法,这里使用ID是因为在导入用法字典时,是将ID导入到code中
  using.TakingMedicineTimeID                                       code_freq,
  --@默认频次,需要管理表转换一下
  '268'                                                            dt_chcate,
  --病案分类,西药写死
  'CA5FBE4D99314595981FA79C68585D45'                               pk_itemcate,
  ---收费分类,西药写死
  'NHIS12345NEW1001ZZ10000000007V99'                               pk_ordtype,
  ----医嘱分类,西药写死
  UnitPrice                                                        price,
  --零售价格
  StoreQualification                                               dt_storetype
--@存储要求
from tbWM wm
  inner join tbWMDetail wmdetail on wm.WMID = wmdetail.WMID and wm.WMID != '-1'
  left join tbMedicineDefaultUsingMethod usingst
    on usingst.MedicineID = wm.WMID and MedicineTypeFlag = 1 and SecondMedicineUsingMethodID = 236 and wm.IdleFlag = 0
       and usingst.TakingMedicineTimeID != '-1' and usingst.MedicineUsingMethodID != '-1'
  --皮试标志,切换类型需要修改MedicineTypeFlag
  left join tbMedicineDefaultUsingMethod using
    on using.MedicineID = wm.WMID and using.MedicineTypeFlag = 1 and using.TakingMedicineTimeID != '-1' and
       using.MedicineUsingMethodID != '-1'
  left join tbAssort sort on sort.SourceID = wm.WMID and AssortType = '1803' --化疗标志,1803是化疗西药目录
where wm.IdleFlag = '0' and wm.WMID != '27716'