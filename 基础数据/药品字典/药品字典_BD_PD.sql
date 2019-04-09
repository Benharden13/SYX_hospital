
--INSERT into BD_PD
SELECT
  replace(sys_guid(), '-', '') PK_PD,
  CODE,
  NAME,
  SPEC,
  SHORT_NAME,
  null BARCODE,
  SPCODE,
  null CONCENT,
  null WEIGHT,
  null PK_UNIT_WT,
  VOL,
  CASE when volu is NOT  null then volu else '7C7170A0DC0645D6BF16FAF0C567523F' end  PK_UNIT_VOL,
  --7C7170A0DC0645D6BF16FAF0C567523F是单位无的主键,因为单位不能为空
  CASE when min is NOT  null then min else '7C7170A0DC0645D6BF16FAF0C567523F' end PK_UNIT_MIN,
  PACK_SIZE,
  CASE when pack is NOT  null then pack else '7C7170A0DC0645D6BF16FAF0C567523F' end PK_UNIT_PACK,
  EU_MUPUTYPE,
  '0' EU_PDTYPE,
  EU_DRUGTYPE,
  NAME_CHEM,
  CASE when FACTORY is NOT  null then FACTORY else 'B3EC5644BD4E48FBBBF7649060B3F886' end  PK_FACTORY,
  APPR_NO,
  '0' EU_PDPRICE,
  --计价模式
  null EU_PAP,
  null AMT_PAP,
  PAP_RATE,
  DT_ABRD,
  null DT_MADE,
  DT_DOSAGE,
  '01' DT_PHARM,
  --药理分类
  DT_POIS,
  DT_ANTI,
  FLAG_PRECIOUS,
  EU_USECATE,
  storecode DT_STORETYPE,
  DT_BASE,
  FLAG_RM,
  '0' FLAG_REAG,
  '0' FLAG_VACC,
  FLAG_ST,
  '0' FLAG_GMP,
  '0' FLAG_TPN,
  '0' FLAG_PED,
  NOTE,
  DOSAGE_DEF,
  volu PK_UNIT_DEF,
  CODE_SUPPLY,
  CODE_FREQ,
  DT_CHCATE,
  PK_ITEMCATE,
  PK_ORDTYPE,
  'ben0402' CREATOR,
  sysdate CREATE_TIME,
  null MODIFIER,
  '0' DEL_FLAG,
  '~                               ' PK_ORG,
  PRICE,
  '9999' VALID_CNT,
  '1' EU_VALID_UNIT,
  '0' FLAG_STOP,
  '0' EU_SOURCE,
  --采购来源
  sysdate TS,
  null PK_PDIND,
  --适应症用药
  null PK_PDCATE,
  null REG_NO,
  null DATE_VALID_REG,
  null EU_STOCKMODE,
  null CODE_COSTITEM,
  null PK_ITEM,
  '0' FLAG_SINGLE,
  '0' FLAG_IMP,
  '0' FLAG_USE,
  null PK_PDGN,
  '01' DT_PDTYPE,
  PACK_SIZE_MAX,
  null  DT_USAGENOTE,
  CASE WHEN EU_USECATE = '2'
    THEN '01'
   END DT_INJTYPE,
  --注射类药品,需要人工维护
  FLAG_CHRT,
  '9' EU_HERBTYPE,
  OLD_YB_ID,
  OLD_ID,
  '0' AGE_MIN,
  '999' AGE_MAX,
  '0' EU_SEX,
  code OLD_CODE,
  QUOTA_DOS,
  null EU_HPTYPE,
  OLD_YB_ID CODE_HP,
  null CODE_STD
FROM (SELECT wm.*,unitvol.PK_UNIT volu,unitpack.PK_UNIT pack,unitmin.PK_UNIT min,doc.CODE storecode,fac.PK_FACTORY FACTORY FROM A_BD_PD_WM wm
  LEFT JOIN BD_PD pd on pd.OLD_YB_ID  = wm.OLD_YB_ID
  LEFT JOIN BD_UNIT unitvol ON unitvol.NAME = wm.PK_UNIT_VOL
  LEFT JOIN BD_UNIT unitpack ON unitpack.NAME = wm.PK_UNIT_PACK
  LEFT JOIN BD_UNIT unitmin ON unitmin.NAME = wm.PK_UNIT_MIN
  LEFT JOIN BD_DEFDOC doc on doc.NAME = wm.DT_STORETYPE and CODE_DEFDOCLIST = '080012'
  LEFT JOIN BD_FACTORY fac on fac.OLD_ID = wm.PK_FACTORY
where pd.OLD_YB_ID is null)

--通用名,直接生成 NAME_CHEM
--insert into BD_PD_AS
select
  replace(sys_guid(), '-', '') PK_PDAS,
  'a41476368e2943f48c32d0cb1179dab8' PK_ORG,
  PK_PD,
  ALIAS,
  SPCODE,
  D_CODE,
  'ben0402' CREATOR,
  sysdate CREATE_TIME,
  null MODIFIER,
  '0' DEL_FLAG,
  null TS
from (SELECT pd.NAME_CHEM ALIAS,pd.NAME,pd.SPCODE,PYCODE D_CODE,PK_PD FROM A_BD_PD_WM wm
  INNER JOIN BD_PD pd on pd.OLD_YB_ID  = wm.OLD_YB_ID
where pd.CREATOR ='ben0402' and NOT exists(SELECT * from BD_PD_AS pdas where pdas.PK_PD = pd.PK_PD and wm.NAME_CHEM = ALIAS) );

--商品名,spcode需要自动生成
--如果通用名=商品名,则不生成
--insert into BD_PD_AS
select
  replace(sys_guid(), '-', '') PK_PDAS,
  'a41476368e2943f48c32d0cb1179dab8' PK_ORG,
  PK_PD,
  ALIAS,
  FN_GETPY(ALIAS) SPCODE,
  null D_CODE,
  'ben0402' CREATOR,
  sysdate CREATE_TIME,
  null MODIFIER,
  '0' DEL_FLAG,
  null TS
from (SELECT pd.NAME_CHEM,pd.NAME ALIAS,pd.SPCODE,PYCODE D_CODE,PK_PD FROM A_BD_PD_WM wm
  INNER JOIN BD_PD pd on pd.OLD_YB_ID  = wm.OLD_YB_ID
where wm.NAME_CHEM <> wm.NAME and  pd.CREATOR ='ben0402' and NOT exists(SELECT * from BD_PD_AS pdas where pdas.PK_PD = pd.PK_PD and wm.NAME = pdas.ALIAS)
);



---包装单位
--基本单位<>包装单位,维护基本单位
--INSERT INTO BD_PD_CONVERT
SELECT
  replace(sys_guid(), '-', '') PK_PDCONVERT,
  'a41476368e2943f48c32d0cb1179dab8' PK_ORG,
  PK_PD,
  SPEC,
  '1' PACK_SIZE,
  PK_UNIT,
  '0' FLAG_OP,
  '1' FLAG_IP,
  'ben0402' CREATOR,
  sysdate CREATE_TIME,
  null MODIFIER,
  '0' DEL_FLAG,
  null TS
FROM (SELECT PK_PD,pd.SPEC,pd.PK_UNIT_MIN PK_UNIT,pd.PK_UNIT_PACK,pd.PACK_SIZE FROM A_BD_PD_WM wm
  INNER JOIN BD_PD pd on pd.OLD_YB_ID  = wm.OLD_YB_ID
where pd.CREATOR ='ben0402' and pd.PK_UNIT_MIN <> pd.PK_UNIT_PACK
and NOT exists(SELECT * from BD_PD_CONVERT con where con.PK_PD = pd.PK_PD and con.PACK_SIZE = '1' and con.PK_UNIT = pd.PK_UNIT_MIN and FLAG_IP = 1 and FLAG_OP = 0)
);
--基本单位<>包装单位,维护包装单位
--INSERT INTO BD_PD_CONVERT
SELECT
  replace(sys_guid(), '-', '') PK_PDCONVERT,
  'a41476368e2943f48c32d0cb1179dab8' PK_ORG,
  PK_PD,
  SPEC,
  PACK_SIZE,
  PK_UNIT,
  '1' FLAG_OP,
  '0' FLAG_IP,
  'ben0402' CREATOR,
  sysdate CREATE_TIME,
  null MODIFIER,
  '0' DEL_FLAG,
  null TS
FROM (SELECT PK_PD,pd.SPEC,pd.PK_UNIT_MIN ,pd.PK_UNIT_PACK PK_UNIT,pd.PACK_SIZE FROM A_BD_PD_WM wm
  INNER JOIN BD_PD pd on pd.OLD_YB_ID  = wm.OLD_YB_ID
where pd.CREATOR ='ben0402' and pd.PK_UNIT_MIN <> pd.PK_UNIT_PACK
and NOT exists(SELECT * from BD_PD_CONVERT con where con.PK_PD = pd.PK_PD and con.PACK_SIZE = pd.PACK_SIZE and PK_UNIT = pd.PK_UNIT_PACK and FLAG_IP = 0 and FLAG_OP = 1)
);

---基本单位=包装单位,维护一条单位
--INSERT INTO BD_PD_CONVERT
SELECT
  replace(sys_guid(), '-', '') PK_PDCONVERT,
  'a41476368e2943f48c32d0cb1179dab8' PK_ORG,
  PK_PD,
  SPEC,
  PACK_SIZE,
  PK_UNIT,
  '1' FLAG_OP,
  '1' FLAG_IP,
  'ben0402' CREATOR,
  sysdate CREATE_TIME,
  null MODIFIER,
  '0' DEL_FLAG,
  null TS
FROM (SELECT PK_PD,pd.SPEC,pd.PK_UNIT_MIN PK_UNIT,pd.PK_UNIT_PACK,pd.PACK_SIZE FROM A_BD_PD_WM wm
  INNER JOIN BD_PD pd on pd.OLD_YB_ID  = wm.OLD_YB_ID
where pd.CREATOR ='ben0402' and pd.PK_UNIT_MIN = pd.PK_UNIT_PACK
and NOT exists(SELECT * from BD_PD_CONVERT con where con.PK_PD = pd.PK_PD and con.PACK_SIZE = pd.PACK_SIZE and PK_UNIT = pd.PK_UNIT_MIN and FLAG_IP = 1 and FLAG_OP = 1)
);





















---新系统数据
INSERT into BD_PD
SELECT
  replace(sys_guid(), '-', '') PK_PD,
  CODE,
  NAME,
  SPEC,
  SHORT_NAME,
  null BARCODE,
  SPCODE,
  null CONCENT,
  null WEIGHT,
  null PK_UNIT_WT,
  VOL,
  volu PK_UNIT_VOL,
  min PK_UNIT_MIN,
  PACK_SIZE,
  pack PK_UNIT_PACK,
  EU_MUPUTYPE,
  '0' EU_PDTYPE,
  EU_DRUGTYPE,
  NAME_CHEM,
  PK_FACTORY,
  APPR_NO,
  '0' EU_PDPRICE,
  --计价模式
  null EU_PAP,
  null AMT_PAP,
  PAP_RATE,
  DT_ABRD,
  null DT_MADE,
  DT_DOSAGE,
  '01' DT_PHARM,
  --药理分类
  DT_POIS,
  DT_ANTI,
  FLAG_PRECIOUS,
  EU_USECATE,
  storecode DT_STORETYPE,
  DT_BASE,
  FLAG_RM,
  '0' FLAG_REAG,
  '0' FLAG_VACC,
  FLAG_ST,
  '0' FLAG_GMP,
  '0' FLAG_TPN,
  '0' FLAG_PED,
  NOTE,
  DOSAGE_DEF,
  volu PK_UNIT_DEF,
  CODE_SUPPLY,
  CODE_FREQ,
  DT_CHCATE,
  PK_ITEMCATE,
  PK_ORDTYPE,
  'ben0402' CREATOR,
  sysdate CREATE_TIME,
  null MODIFIER,
  '0' DEL_FLAG,
  '~                               ' PK_ORG,
  PRICE,
  '9999' VALID_CNT,
  '1' EU_VALID_UNIT,
  '0' FLAG_STOP,
  '0' EU_SOURCE,
  --采购来源
  sysdate TS,
  null PK_PDIND,
  --适应症用药
  null PK_PDCATE,
  null REG_NO,
  null DATE_VALID_REG,
  null EU_STOCKMODE,
  null CODE_COSTITEM,
  null PK_ITEM,
  '0' FLAG_SINGLE,
  '0' FLAG_IMP,
  '0' FLAG_USE,
  null PK_PDGN,
  '01' DT_PDTYPE,
  PACK_SIZE_MAX,
  null  DT_USAGENOTE,
  CASE when EU_USECATE = '02' then '01' end  DT_INJTYPE,
  --注射类药品,需要人工维护
  FLAG_CHRT,
  '9' EU_HERBTYPE,
  OLD_YB_ID,
  OLD_ID,
  '0' AGE_MIN,
  '999' AGE_MAX,
  null EU_SEX,
  code OLD_CODE,
  QUOTA_DOS,
  null EU_HPTYPE,
  OLD_YB_ID CODE_HP,
  null CODE_STD
FROM (SELECT wm.*,unitvol.PK_UNIT volu,unitpack.PK_UNIT pack,unitmin.PK_UNIT min,doc.CODE storecode FROM A_BD_PD_WM wm
  LEFT JOIN BD_PD pd on pd.OLD_YB_ID  = wm.OLD_YB_ID
  LEFT JOIN BD_UNIT unitvol ON unitvol.NAME = wm.PK_UNIT_VOL
  LEFT JOIN BD_UNIT unitpack ON unitpack.NAME = wm.PK_UNIT_PACK
  LEFT JOIN BD_UNIT unitmin ON unitmin.NAME = wm.PK_UNIT_MIN
  LEFT JOIN BD_DEFDOC doc on doc.NAME = wm.DT_STORETYPE and CODE_DEFDOCLIST = '080012'
where pd.OLD_YB_ID is null and wm.CODE = '00258')



------------------------------------------------------
导入旧系统的数据

select distinct
  '1-' + cast(WM.WMID as varchar(10)) OLD_YB_ID,
  WM.WMID                                                          old_id,
  --旧系统药品ID,用于关联
  wm.WMNo                                                          code,
  --编码
  wm.WMName                                                        name_chem,
  --药品名称
  wm.WMSpec                                                           spec,
  --规格
  wmdetail.WMTradeName                                             name,
  --商品名
  wm.WMLabelName                                                   short_name,
  --标签名
  wm.SpellCode                                                     spcode,
  --助记码
  wm.WBCode                                                        pycode,
  --五笔码
  wm.WMDosage                                                         vol,
  --剂量
  wm.WMDosageUnit                                                     pk_unit_vol,
  --@剂量单位,@表示需要进行数据对照
  wm.WMUnit                                                           pk_unit_min,
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
  case when Wm.SpecialControlFlag in ('0','7','8','9')
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
  case when (select 1
   from tbWM pre
   where WMName like '△%' and IdleFlag = 0 and pre.WMID = wm.WMID) = '1' then '1'else '0' end  flag_precious,
  --贵重标志
  case when Wmdetail.WMBoxSpec = '50瓶'
    then '50' when Wmdetail.WMBoxSpec is null then '1' when Wmdetail.WMBoxSpec = '' then '1' else Wmdetail.WMBoxSpec    end                                          pack_size_max,
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
  CASE WHEN wm.DoseTypeFlag ='0'
THEN'0' --口服
WHEN wm.DoseTypeFlag ='1'
THEN'2' --针剂
WHEN wm.DoseTypeFlag ='10'
THEN'0' --舌下片
WHEN wm.DoseTypeFlag ='100'
THEN'1' --洗耳剂
WHEN wm.DoseTypeFlag ='101'
THEN'1' --耳用喷雾剂
WHEN wm.DoseTypeFlag ='102'
THEN'1' --耳用软膏剂
WHEN wm.DoseTypeFlag ='103'
THEN'1' --耳用乳膏剂
WHEN wm.DoseTypeFlag ='104'
THEN'1' --耳用凝胶剂
WHEN wm.DoseTypeFlag ='105'
THEN'1' --耳塞
WHEN wm.DoseTypeFlag ='106'
THEN'1' --耳用散剂
WHEN wm.DoseTypeFlag ='107'
THEN'1' --耳丸剂
WHEN wm.DoseTypeFlag ='108'
THEN'1' --贴剂
WHEN wm.DoseTypeFlag ='109'
THEN'1' --透皮贴剂
WHEN wm.DoseTypeFlag ='11'
THEN'0' --口腔贴片
WHEN wm.DoseTypeFlag ='110'
THEN'1' --膜剂
WHEN wm.DoseTypeFlag ='111'
THEN'1' --凝胶剂
WHEN wm.DoseTypeFlag ='112'
THEN'0' --咀嚼口胶
WHEN wm.DoseTypeFlag ='113'
THEN'0' --口服散剂
WHEN wm.DoseTypeFlag ='114'
THEN'1' --外用散剂
WHEN wm.DoseTypeFlag ='115'
THEN'1' --外用撒布剂
WHEN wm.DoseTypeFlag ='116'
THEN'1' --外用撒粉
WHEN wm.DoseTypeFlag ='117'
THEN'1' --其他剂型
WHEN wm.DoseTypeFlag ='118'
THEN'1' --晶剂
WHEN wm.DoseTypeFlag ='119'
THEN'1' --浸剂
WHEN wm.DoseTypeFlag ='12'
THEN'0' --泡腾片
WHEN wm.DoseTypeFlag ='120'
THEN'0' --蜜丸
WHEN wm.DoseTypeFlag ='121'
THEN'0' --水蜜丸
WHEN wm.DoseTypeFlag ='122'
THEN'0' --糖衣丸
WHEN wm.DoseTypeFlag ='123'
THEN'0' --糊丸
WHEN wm.DoseTypeFlag ='124'
THEN'0' --水丸
WHEN wm.DoseTypeFlag ='125'
THEN'0' --蜡丸
WHEN wm.DoseTypeFlag ='126'
THEN'0' --浓缩丸
WHEN wm.DoseTypeFlag ='127'
THEN'0' --糊丸
WHEN wm.DoseTypeFlag ='128'
THEN'1' --膏药
WHEN wm.DoseTypeFlag ='129'
THEN'1' --锭剂
WHEN wm.DoseTypeFlag ='13'
THEN'0' --咀嚼片
WHEN wm.DoseTypeFlag ='130'
THEN'1' --胶剂
WHEN wm.DoseTypeFlag ='131'
THEN'1' --贴膏剂
WHEN wm.DoseTypeFlag ='132'
THEN'1' --酒剂
WHEN wm.DoseTypeFlag ='133'
THEN'1' --露剂
WHEN wm.DoseTypeFlag ='134'
THEN'1' --块状茶剂
WHEN wm.DoseTypeFlag ='135'
THEN'1' --袋装茶剂
WHEN wm.DoseTypeFlag ='136'
THEN'1' --煎煮茶剂
WHEN wm.DoseTypeFlag ='137'
THEN'1' --草药
WHEN wm.DoseTypeFlag ='138'
THEN'1' --根茎类
WHEN wm.DoseTypeFlag ='139'
THEN'1' --果实类
WHEN wm.DoseTypeFlag ='14'
THEN'0' --多层片
WHEN wm.DoseTypeFlag ='140'
THEN'1' --全草
WHEN wm.DoseTypeFlag ='141'
THEN'1' --花叶类
WHEN wm.DoseTypeFlag ='142'
THEN'1' --树皮类
WHEN wm.DoseTypeFlag ='143'
THEN'1' --藤木树脂
WHEN wm.DoseTypeFlag ='144'
THEN'1' --菌藻类
WHEN wm.DoseTypeFlag ='145'
THEN'1' --动物类
WHEN wm.DoseTypeFlag ='146'
THEN'1' --矿物类
WHEN wm.DoseTypeFlag ='147'
THEN'1' --其他类
WHEN wm.DoseTypeFlag ='148'
THEN'1' --中药颗粒
WHEN wm.DoseTypeFlag ='149'
THEN'1' --中草药
WHEN wm.DoseTypeFlag ='15'
THEN'0' --划痕片
WHEN wm.DoseTypeFlag ='150'
THEN'0' --方剂
WHEN wm.DoseTypeFlag ='151'
THEN'0' --片剂
WHEN wm.DoseTypeFlag ='152'
THEN'0' --颗粒
WHEN wm.DoseTypeFlag ='153'
THEN'0' --薄膜衣片
WHEN wm.DoseTypeFlag ='16'
THEN'0' --可溶片
WHEN wm.DoseTypeFlag ='17'
THEN'1' --阴道片
WHEN wm.DoseTypeFlag ='18'
THEN'1' --阴道泡腾片
WHEN wm.DoseTypeFlag ='19'
THEN'0' --胶囊
WHEN wm.DoseTypeFlag ='2'
THEN'0' --片剂
WHEN wm.DoseTypeFlag ='20'
THEN'0' --硬胶囊
WHEN wm.DoseTypeFlag ='21'
THEN'0' --软胶囊(胶丸)
WHEN wm.DoseTypeFlag ='22'
THEN'0' --肠溶胶囊
WHEN wm.DoseTypeFlag ='23'
THEN'0' --缓释胶囊
WHEN wm.DoseTypeFlag ='24'
THEN'0' --控释胶囊
WHEN wm.DoseTypeFlag ='25'
THEN'2' --注射液
WHEN wm.DoseTypeFlag ='26'
THEN'2' --静脉滴注用注射液(静脉输液)
WHEN wm.DoseTypeFlag ='27'
THEN'2' --注射用混悬液
WHEN wm.DoseTypeFlag ='28'
THEN'2' --注射用乳状液
WHEN wm.DoseTypeFlag ='29'
THEN'2' --注射用油剂
WHEN wm.DoseTypeFlag ='3'
THEN'0' --薄膜衣片
WHEN wm.DoseTypeFlag ='30'
THEN'2' --注射用无菌粉末
WHEN wm.DoseTypeFlag ='31'
THEN'2' --注射用冻干粉针
WHEN wm.DoseTypeFlag ='32'
THEN'2' --注射用溶媒结晶粉
WHEN wm.DoseTypeFlag ='33'
THEN'2' --注射用浓溶液
WHEN wm.DoseTypeFlag ='34'
THEN'1' --溶液剂
WHEN wm.DoseTypeFlag ='35'
THEN'0' --口服液
WHEN wm.DoseTypeFlag ='36'
THEN'0' --口服溶液剂
WHEN wm.DoseTypeFlag ='37'
THEN'0' --口服混悬液
WHEN wm.DoseTypeFlag ='38'
THEN'0' --口服混悬滴剂
WHEN wm.DoseTypeFlag ='39'
THEN'0' --口服滴剂
WHEN wm.DoseTypeFlag ='4'
THEN'0' --肠溶片
WHEN wm.DoseTypeFlag ='40'
THEN'0' --口服糖浆剂
WHEN wm.DoseTypeFlag ='41'
THEN'0' --口服酊剂
WHEN wm.DoseTypeFlag ='42'
THEN'0' --口服乳剂
WHEN wm.DoseTypeFlag ='43'
THEN'1' --外用溶液剂
WHEN wm.DoseTypeFlag ='44'
THEN'1' --外用洗剂
WHEN wm.DoseTypeFlag ='45'
THEN'1' --冲洗剂
WHEN wm.DoseTypeFlag ='46'
THEN'1' --灌肠剂
WHEN wm.DoseTypeFlag ='47'
THEN'1' --含漱液
WHEN wm.DoseTypeFlag ='48'
THEN'1' --外用酊剂
WHEN wm.DoseTypeFlag ='49'
THEN'1' --外用油剂
WHEN wm.DoseTypeFlag ='5'
THEN'0' --糖衣片
WHEN wm.DoseTypeFlag ='50'
THEN'1' --外用混悬液
WHEN wm.DoseTypeFlag ='51'
THEN'1' --搽剂
WHEN wm.DoseTypeFlag ='52'
THEN'1' --涂剂
WHEN wm.DoseTypeFlag ='53'
THEN'1' --涂膜剂
WHEN wm.DoseTypeFlag ='54'
THEN'0' --丸剂
WHEN wm.DoseTypeFlag ='55'
THEN'0' --滴丸
WHEN wm.DoseTypeFlag ='56'
THEN'0' --糖丸
WHEN wm.DoseTypeFlag ='57'
THEN'0' --小丸
WHEN wm.DoseTypeFlag ='58'
THEN'1' --颗粒剂
WHEN wm.DoseTypeFlag ='59'
THEN'1' --肠溶颗粒剂
WHEN wm.DoseTypeFlag ='6'
THEN'0' --分散片
WHEN wm.DoseTypeFlag ='60'
THEN'1' --泡腾颗粒剂
WHEN wm.DoseTypeFlag ='61'
THEN'1' --干混悬剂
WHEN wm.DoseTypeFlag ='62'
THEN'1' --缓释颗粒剂
WHEN wm.DoseTypeFlag ='63'
THEN'1' --控释颗粒剂
WHEN wm.DoseTypeFlag ='64'
THEN'1' --软膏剂
WHEN wm.DoseTypeFlag ='65'
THEN'1' --乳膏剂
WHEN wm.DoseTypeFlag ='66'
THEN'1' --霜剂
WHEN wm.DoseTypeFlag ='67'
THEN'1' --糊剂
WHEN wm.DoseTypeFlag ='68'
THEN'1' --硬膏剂
WHEN wm.DoseTypeFlag ='69'
THEN'1' --亲水硬膏剂
WHEN wm.DoseTypeFlag ='7'
THEN'0' --缓释片
WHEN wm.DoseTypeFlag ='70'
THEN'1' --栓剂
WHEN wm.DoseTypeFlag ='71'
THEN'1' --直肠栓
WHEN wm.DoseTypeFlag ='72'
THEN'1' --阴道栓
WHEN wm.DoseTypeFlag ='73'
THEN'1' --尿道栓
WHEN wm.DoseTypeFlag ='74'
THEN'1' --缓释栓
WHEN wm.DoseTypeFlag ='75'
THEN'1' --喷雾剂
WHEN wm.DoseTypeFlag ='76'
THEN'1' --雾化吸入剂
WHEN wm.DoseTypeFlag ='77'
THEN'1' --雾化混悬液
WHEN wm.DoseTypeFlag ='78'
THEN'1' --雾化溶液剂
WHEN wm.DoseTypeFlag ='79'
THEN'1' --气雾剂
WHEN wm.DoseTypeFlag ='8'
THEN'0' --控释片
WHEN wm.DoseTypeFlag ='80'
THEN'1' --粉雾剂
WHEN wm.DoseTypeFlag ='81'
THEN'1' --滴眼液
WHEN wm.DoseTypeFlag ='82'
THEN'1' --滴眼混悬液
WHEN wm.DoseTypeFlag ='83'
THEN'1' --洗眼剂
WHEN wm.DoseTypeFlag ='84'
THEN'2' --眼内注射溶液
WHEN wm.DoseTypeFlag ='85'
THEN'1' --眼用乳膏剂
WHEN wm.DoseTypeFlag ='86'
THEN'1' --眼用凝胶剂
WHEN wm.DoseTypeFlag ='87'
THEN'1' --眼膜剂
WHEN wm.DoseTypeFlag ='88'
THEN'1' --眼丸剂
WHEN wm.DoseTypeFlag ='89'
THEN'1' --眼内插入剂
WHEN wm.DoseTypeFlag ='9'
THEN'0' --含片
WHEN wm.DoseTypeFlag ='90'
THEN'1' --滴鼻液
WHEN wm.DoseTypeFlag ='91'
THEN'1' --洗鼻剂
WHEN wm.DoseTypeFlag ='92'
THEN'1' --鼻用喷雾剂
WHEN wm.DoseTypeFlag ='93'
THEN'1' --鼻用软膏剂
WHEN wm.DoseTypeFlag ='94'
THEN'1' --鼻用乳膏剂
WHEN wm.DoseTypeFlag ='95'
THEN'1' --鼻用凝胶剂
WHEN wm.DoseTypeFlag ='96'
THEN'1' --鼻用散剂
WHEN wm.DoseTypeFlag ='97'
THEN'1' --鼻用粉雾剂
WHEN wm.DoseTypeFlag ='98'
THEN'1' --鼻用棒剂
WHEN wm.DoseTypeFlag ='99'
THEN'1' --滴耳液
end                                                  eu_usecate,
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
    then 0
  else 1 end                                                       flag_st,
  --皮试标志
  case when sort.SourceID is null
    then 0
  else 1 end                                                       flag_chrt,
  --化疗标志
  wm.WMDescription                                                note,
  --备注
  wm.WMLimitDosagePerTime                                          quota_dos,
  --用量上限
  wm.DefaultDosagePerTime                                          dosage_def,
  --默认用量
  using.MedicineUsingMethodID                                      code_supply,
  --默认用法,这里使用ID是因为在导入用法字典时,是将ID导入到code中
  using.TakingMedicineTimeID                                       code_freq,
  --@默认频次,需要管理表转换一下
  '13'                                                            dt_chcate,
  --病案分类,西药写死
  'CA5FBE4D99314595981FA79C68585D45'                               pk_itemcate,
  ---收费分类,西药写死
  'NHIS12345NEW1001ZZ10000000007V99'                               pk_ordtype,
  ----医嘱分类,西药写死
  RetailPrice                                                        price,
  --零售价格
  wm.StoreQualification                                               dt_storetype,
--@存储要求
  wm.ModifyDateTime ts
  --时间
from tbWM wm
  inner join tbWMDetail wmdetail on wm.WMID = wmdetail.WMID and wm.WMID != '-1'
  inner join WIS20.dbo.t_WM twm on twm.WMID = wm.WMID
  left join tbMedicineDefaultUsingMethod usingst
    on usingst.MedicineID = wm.WMID and MedicineTypeFlag = 1 and SecondMedicineUsingMethodID = 236 and wm.IdleFlag = 0
       and usingst.TakingMedicineTimeID != '-1' and usingst.MedicineUsingMethodID != '-1'
  --皮试标志,切换类型需要修改MedicineTypeFlag
  left join tbMedicineDefaultUsingMethod using
    on using.MedicineID = wm.WMID and using.MedicineTypeFlag = 1 and using.TakingMedicineTimeID != '-1' and
       using.MedicineUsingMethodID != '-1'
  left join tbAssort sort on sort.SourceID = wm.WMID and AssortType = '1803' --化疗标志,1803是化疗西药目录
where wm.IdleFlag = '0';

---成药
--成药字典
select
  pcm.pcmid             old_id,
  pcmno                 code,
  pcmname               name,
  pcmspec               spec,
  spellcode             spcode,
  wbcode                d_code,
  pcmdosage             vol,
  pcmdosageunit         pk_unit_vol,
  pcmunit               pk_unit_min,
  packageunit           pk_unit_pack,
  case when dosetypeflag = 2
    then '0'
  when dosetypeflag = 3
    then '152'
  else dosetypeflag end dt_dosage,
  --0-口服,1-针剂,2-外用,3-颗粒,
  integratingtypeflag,
  specialcontrolflag    dt_anti,
  specialcontrolflag    dt_pois,
  transrate             pack_size,
  producerid            pk_factory,
  providerid            providerid,
  authorizeno           appr_no,
  storequalification    dt_storetype,
  --@存储要求
  null     price,
  '1'                   eu_drugtype,
  case when detail.nationalitybasemedicineflag = '0'
    then '00'
  when detail.nationalitybasemedicineflag = '1'
    then '01'
  when detail.nationalitybasemedicineflag = '2'
    then '02' end       dt_base,
  pcm.pcmdescription    note,
    pcm.DefaultDosagePerTime                                          dosage_def,
  --默认用量
  usingst.MedicineUsingMethodID                                      code_supply,
  --默认用法,这里使用ID是因为在导入用法字典时,是将ID导入到code中
  usingst.TakingMedicineTimeID                                       code_freq,PCMLimitTotalDosage quota_dos,
  '14'                                                            dt_chcate,
  --病案分类,西药写死
  '4DC8445B90B34EB5A96C65DD450CF9BF'                               pk_itemcate,
  ---收费分类,西药写死
  'NHIS12345NEW1001ZZ1000000000SAK2'                               pk_ordtype, AddMultiRatio pap_rate
from tbpcm pcm
  inner join tbpcmdetail detail on pcm.pcmid = detail.pcmid
  left join tbmedicinedefaultusingmethod usingst
    on usingst.medicineid = pcm.pcmid and medicinetypeflag = 2 and pcm.idleflag = 0
    and (MedicineDefaultUsingMethodID !='1726' and MedicineDefaultUsingMethodID !='1857' and MedicineDefaultUsingMethodID !='2113')
      --因为旧系统默认用法这3个id维护重复,所以此处过滤
       and usingst.takingmedicinetimeid != '-1' and usingst.medicineusingmethodid != '-1'
where pcm.idleflag = 0 and pcm.pcmid != -1