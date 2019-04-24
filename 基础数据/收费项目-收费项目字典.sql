------------------------------------
/*
收费项目由三部分组成
	收费项目
	材料
	容器
包含的内容有
	项目名称
	项目编码
	单价
	单位
	拼音码/五笔码
	小孩加收
	特诊加收/分住院与门诊
		门诊加收30%
		住院加收300%
	病案费用统计类别
		该值对应新系统码表的old_id,材料默认的病案分类为22
	上传编码
	患者记账类型-自费类-费别	
		对应新系统的费用分类
	附加收费项目
其中有两段sql,一段为查询在用收费项目,一段为收费项目下的组套  
	*/

--患者记账类型,需要注意的是自费类,因为收费项目使用费用分类pk_itemcate是使用自费类型下收费项目对应的费别
SELECT * from tbPatientChargeType where PatientChargeTypeName like '%自费%'
--收费项目费别及自付比例设定 数据为患者记账类型-收费项目  收费项目-费别
SELECT * from tbChargeItemFeeKindAndPayproportion = '86';



------------------------------------
--旧系统当前存在的收费项目

SELECT *
FROM
  (SELECT
     (SELECT total
      FROM
        (SELECT ORD_ID,
                COUNT(1) total
         FROM (--如果项目本身有价格,那么该关系也需要在系统中进行维护

               SELECT '6-' + cast(item.ItemID AS VARCHAR(10)) ORD_ID,
                             item.ItemNo OrdNo,
                             item.Description,
                             '6-' + cast(ItemID AS VARCHAR(10)) YB_ID,
                                    ItemNo,
                                    Description addname,
                                    ItemID,
                                    '6' AppType,
                                        '1' QUAN,
                                            '0' IsMergeReceiptFlag
               FROM tbItem item
               WHERE IdleFlag = 0
                 AND UnitPrice > 0
               UNION ALL --医嘱项目与收费项目的对照关系

               SELECT '6-' + cast(item.ItemID AS VARCHAR(10)) ORD_ID,
                             item.ItemNo OrdNo,
                             item.Description,
                             '6-' + cast(additem.ItemID AS VARCHAR(10)) YB_ID,
                                    additem.ItemNo,
                                    additem.Description addname,
                                    AppID,
                                    AppType,
                                    Quantity QUAN,
                                    IsMergeReceiptFlag flag_union
               FROM tbItem item
               INNER JOIN tbAdditionalCorresponding ding ON ding.MainID = item.ItemID
               AND AppType = '6'
               INNER JOIN tbItem additem ON additem.ItemID = ding.AppID
               WHERE item.IdleFlag = '0'
                 AND additem.IdleFlag = 0
               UNION ALL --医嘱关联材料项目,

               SELECT '6-' + cast(item.ItemID AS VARCHAR(10)) ORD_ID,
                             item.ItemNo OrdNo,
                             item.Description,
                             '5-' + cast(additem.MaterialID AS VARCHAR(10)) YB_ID,
                                    additem.MaterialNo,
                                    additem.MaterialName addname,
                                    AppID,
                                    AppType,
                                    Quantity QUAN,
                                    IsMergeReceiptFlag flag_union
               FROM tbItem item
               INNER JOIN tbAdditionalCorresponding ding ON ding.MainID = item.ItemID
               AND AppType = '5'
               INNER JOIN tbMaterial additem ON additem.MaterialID = ding.AppID
               WHERE item.IdleFlag = '0'
                 AND additem.IdleFlag = 0
               UNION ALL --医嘱关联药品字典,这里使用到的药品都需要维护诊断标志flag_gmp,该标志维护后,医技才能开出该药品

               SELECT '6-' + cast(item.ItemID AS VARCHAR(10)) ORD_ID,
                             item.ItemNo OrdNo,
                             item.Description,
                             '1-' + cast(additem.WMID AS VARCHAR(10)) YB_ID,
                                    additem.WMNo,
                                    additem.WMName,
                                    AppID,
                                    AppType,
                                    Quantity QUAN,
                                    IsMergeReceiptFlag flag_union
               FROM tbItem item
               INNER JOIN tbAdditionalCorresponding ding ON ding.MainID = item.ItemID
               AND AppType = '1'
               INNER JOIN tbWM additem ON additem.WMID = ding.AppID
               WHERE item.IdleFlag = '0'
                 AND additem.IdleFlag = 0
               UNION ALL --材料对应的收费项目,旧系统没有材料没有附加项目.   新系统中材料也是存在收费项目中

               SELECT '5-' + cast(item.MaterialID AS VARCHAR(10)) ORD_ID,
                             item.MaterialNo OrdNo,
                             item.MaterialName,
                             '5-' + cast(item.MaterialID AS VARCHAR(10)) YB_ID,
                                    MaterialNo WMNo,
                                    MaterialName,
                                    MaterialID,
                                    '5' AppType,
                                        '1' QUAN,
                                            '0' flag_union
               FROM tbMaterial item
               WHERE item.IdleFlag = '0'
               UNION ALL --检验项目对应的收费项目,只会关联收费项目,不关联材料,药品等

               SELECT '1-' + cast(ItemSetID AS VARCHAR(10)) ORD_ID,
                             ItemSetNo ORD_CODE,
                             --医嘱编码

                             itemset.Description ORD_NAME,
                             '6-' + cast(item.ItemID AS VARCHAR(10)) YB_ID,
                                    --旧系统检验项目只会关联收费项目,不关联材料,药品等,所以写6

                                    ItemNo WMNo,
                                    item.Description ITEM_NAME,
                                    ItemID,
                                    '6' AppType,
                                        match.Quantity QUAN,
                                        '0' flag_union
               FROM tbItemSet itemset
               INNER JOIN tbItemMatch MATCH ON MATCH.ParentSourceID = itemset.ItemSetID
               INNER JOIN tbItem item ON item.ItemID = MATCH.SourceID
               WHERE item.IdleFlag = 0
                 AND itemset.IdleFlag = 0 ) T
         GROUP BY ORD_ID) tt
      WHERE tt.ORD_ID = '6-' + cast(item.ItemID AS VARCHAR(10))) addtotal,
                                                                 --附加收费项目数量

                                                                 '6-' + cast(item.ItemID AS VARCHAR(10)) YB_ID,
                                                                        --唯一标识

                                                                        ItemNo ContainerNo,
                                                                        --编码

                                                                        Description Description,
     (SELECT total
      FROM
        (SELECT ORD_ID,
                sum(UnitPrice) total
         FROM (--如果项目本身有价格,那么该关系也需要在系统中进行维护

               SELECT '6-' + cast(item.ItemID AS VARCHAR(10)) ORD_ID,
                             item.ItemNo OrdNo,
                             item.Description,
                             '6-' + cast(ItemID AS VARCHAR(10)) YB_ID,
                                    ItemNo,
                                    Description addname,
                                    ItemID,
                                    '6' AppType,
                                        '1' QUAN,
                                            '0' IsMergeReceiptFlag,
                                                item.UnitPrice
               FROM tbItem item
               WHERE IdleFlag = 0
                 AND UnitPrice > 0
               UNION ALL --医嘱项目与收费项目的对照关系

               SELECT '6-' + cast(item.ItemID AS VARCHAR(10)) ORD_ID,
                             item.ItemNo OrdNo,
                             item.Description,
                             '6-' + cast(additem.ItemID AS VARCHAR(10)) YB_ID,
                                    additem.ItemNo,
                                    additem.Description addname,
                                    AppID,
                                    AppType,
                                    Quantity QUAN,
                                    IsMergeReceiptFlag flag_union,
                                    additem.UnitPrice
               FROM tbItem item
               INNER JOIN tbAdditionalCorresponding ding ON ding.MainID = item.ItemID
               AND AppType = '6'
               INNER JOIN tbItem additem ON additem.ItemID = ding.AppID
               WHERE item.IdleFlag = '0'
                 AND additem.IdleFlag = 0
               UNION ALL --医嘱关联材料项目,

               SELECT '6-' + cast(item.ItemID AS VARCHAR(10)) ORD_ID,
                             item.ItemNo OrdNo,
                             item.Description,
                             '5-' + cast(additem.MaterialID AS VARCHAR(10)) YB_ID,
                                    additem.MaterialNo,
                                    additem.MaterialName addname,
                                    AppID,
                                    AppType,
                                    Quantity QUAN,
                                    IsMergeReceiptFlag flag_union,
                                    additem.UnitPrice
               FROM tbItem item
               INNER JOIN tbAdditionalCorresponding ding ON ding.MainID = item.ItemID
               AND AppType = '5'
               INNER JOIN tbMaterial additem ON additem.MaterialID = ding.AppID
               WHERE item.IdleFlag = '0'
                 AND additem.IdleFlag = 0
               UNION ALL --医嘱关联药品字典,这里使用到的药品都需要维护诊断标志flag_gmp,该标志维护后,医技才能开出该药品

               SELECT '6-' + cast(item.ItemID AS VARCHAR(10)) ORD_ID,
                             item.ItemNo OrdNo,
                             item.Description,
                             '1-' + cast(additem.WMID AS VARCHAR(10)) YB_ID,
                                    additem.WMNo,
                                    additem.WMName,
                                    AppID,
                                    AppType,
                                    Quantity QUAN,
                                    IsMergeReceiptFlag flag_union,
                                    additem.UnitPrice
               FROM tbItem item
               INNER JOIN tbAdditionalCorresponding ding ON ding.MainID = item.ItemID
               AND AppType = '1'
               INNER JOIN tbWM additem ON additem.WMID = ding.AppID
               WHERE item.IdleFlag = '0'
                 AND additem.IdleFlag = 0
               UNION ALL --材料对应的收费项目,旧系统没有材料没有附加项目.   新系统中材料也是存在收费项目中

               SELECT '5-' + cast(item.MaterialID AS VARCHAR(10)) ORD_ID,
                             item.MaterialNo OrdNo,
                             item.MaterialName,
                             '5-' + cast(item.MaterialID AS VARCHAR(10)) YB_ID,
                                    MaterialNo WMNo,
                                    MaterialName,
                                    MaterialID,
                                    '5' AppType,
                                        '1' QUAN,
                                            '0' flag_union,
                                                item.UnitPrice
               FROM tbMaterial item
               WHERE item.IdleFlag = '0'
               UNION ALL --检验项目对应的收费项目,只会关联收费项目,不关联材料,药品等

               SELECT '1-' + cast(ItemSetID AS VARCHAR(10)) ORD_ID,
                             ItemSetNo ORD_CODE,
                             --医嘱编码

                             itemset.Description ORD_NAME,
                             '6-' + cast(item.ItemID AS VARCHAR(10)) YB_ID,
                                    --旧系统检验项目只会关联收费项目,不关联材料,药品等,所以写6

                                    ItemNo WMNo,
                                    item.Description ITEM_NAME,
                                    ItemID,
                                    '6' AppType,
                                        MATCH.Quantity QUAN,
                                              '0' flag_union,
                                                  itemset.UnitPrice
               FROM tbItemSet itemset
               INNER JOIN tbItemMatch MATCH ON MATCH.ParentSourceID = itemset.ItemSetID
               INNER JOIN tbItem item ON item.ItemID = MATCH.SourceID
               WHERE item.IdleFlag = 0
                 AND itemset.IdleFlag = 0 ) T
         GROUP BY ORD_ID) tt
      WHERE tt.ORD_ID = '6-' + cast(item.ItemID AS VARCHAR(10))) UnitPrice,
                                                                 --价格,包括组套价格

                                                                 Unit,
                                                                 --单位

                                                                 SpellCode,
                                                                 WBCode,
                                                                 AddProportion,
                                                                 --小孩加收比例

                                                                 SDProportion,
                                                                 --门诊特诊加收

                                                                 NULL DisPubPatientSelfPayFlag,
                                                                      --材料项目拥有的字段,区公医先自费类型

                                                                      NULL PreSelfPayFlag,
                                                                           --材料项目拥有的字段,先自费类型

                                                                           NewCaseChargeTypeFlag,
                                                                           CASE
                                                                               WHEN pay.FeeKindID IS NOT NULL THEN pay.FeeKindID
                                                                               ELSE '287'
                                                                           END FeeKindID --病案分类
FROM tbItem item
   LEFT JOIN tbChargeItemFeeKindAndPayproportion pay ON SourceID = item.ItemID
   AND SourceType = 6
   AND PatientChargeTypeID = '86' --INNER JOIN tbAdditionalCorresponding ding on ding.

   WHERE item.IdleFlag = 0
   UNION ALL --材料
SELECT NULL addtotal,
            rtrim('5-' + cast(material.MaterialID AS VARCHAR(10))) YB_ID,
            MaterialNo ContainerNo,
            MaterialName Description,
            UnitPrice,
            Unit,
            SpellCode,
            WBCode,
            NULL AddProportion,
                 --小孩加收比例

                 NULL SDProportion,
                      DisPubPatientSelfPayFlag,
                      --材料项目拥有的字段,区公医先自费类型

                      PreSelfPayFlag,
                      --材料项目拥有的字段,先自费类型

                      '22' NewCaseChargeTypeFlag,
                           pay.FeeKindID --病案分类,材料默认的病案分类为22,该值对应新系统码表的old_id
FROM tbMaterial material
   LEFT JOIN tbChargeItemFeeKindAndPayproportion pay ON SourceID = material.MaterialID
   AND SourceType = 5
   AND PatientChargeTypeID = '95' --tbchargeitemfeekindandpayproportion='95' 是旧系统中患者记账类型:材料自费类

   INNER JOIN tbMaterialDetail detail ON material.MaterialID = detail.MaterialID
   WHERE material.IdleFlag = 0
   UNION ALL --容器
SELECT NULL addtotal,
            rtrim('9-' + cast(containerid AS VARCHAR(10))) YB_ID,
            containerno containerno,
            description description,
            unitprice,
            Unit,
            NULL spellcode,
                 NULL wbcode,
                      NULL AddProportion,
                           --小孩加收比例

                           NULL SDProportion,
                                NULL DisPubPatientSelfPayFlag,
                                     --材料项目拥有的字段,区公医先自费类型

                                     NULL PreSelfPayFlag,
                                          --材料项目拥有的字段,先自费类型

                                          '22' NewCaseChargeTypeFlag,
                                               '281' FeeKindID --病案分类,材料默认的病案分类为22,该值对应新系统码表的old_id
FROM tbcontainer con
   LEFT JOIN tbchargeitemfeekindandpayproportion pay ON sourceid = con.containerid
   AND sourcetype = 9
   AND patientchargetypeid = '102' --tbchargeitemfeekindandpayproportion='102' 是旧系统中患者记账类型:标本自费类

   WHERE idleflag = 0) T
ORDER BY YB_ID ASC

























------------------------------------------------------------
--------------旧
--在对比前一定要保证医嘱的YB_ID与旧系统的一致
/*
	收费项目的对照关系
	系统医嘱/收费项目对应的收费项目
	收费项目如果需要维护,需要维护成组套即可
*/
SELECT ORD_ID,
       --bd_ord.OLD_ID   前缀1-为检验项目,5-为材料项目,6-为收费项目

       OrdNo,
       --医嘱编码  CODE

       Description,
       --医嘱名称

       YB_ID,
       --医嘱关联的收费项目旧ID  bd_ord.YB_ID

       ItemNo,
       --收费项目的编码

       addname,
       --收费项目的名称

       ItemID,
       --bd_item_YB_ID

       AppType,
       --项目类型,1-西药,2-成药,3-草药,5-材料,6-收费项目,9-容器,唯一标志YB_ID就是使用AppType-ItemID组成

       QUAN,
       --数量

       IsMergeReceiptFlag --是否合并标志,部分检查项目存在该字段,例如:开立两个相同的检查项目,项目中可能包含着相同的收费项目,只需要收一次
FROM ( --如果项目本身有价格,那么该关系也需要在系统中进行维护

      SELECT '6-' + cast(item.ItemID AS VARCHAR(10)) ORD_ID,
                    item.ItemNo OrdNo,
                    item.Description,
                    '6-' + cast(ItemID AS VARCHAR(10)) YB_ID,
                           ItemNo,
                           Description addname,
                           ItemID,
                           '6' AppType,
                               '1' QUAN,
                                   '0' IsMergeReceiptFlag
      FROM tbItem item
      WHERE IdleFlag = 0
        AND UnitPrice > 0
      UNION ALL --医嘱项目与收费项目的对照关系

      SELECT '6-' + cast(item.ItemID AS VARCHAR(10)) ORD_ID,
                    item.ItemNo OrdNo,
                    item.Description,
                    '6-' + cast(additem.ItemID AS VARCHAR(10)) YB_ID,
                           additem.ItemNo,
                           additem.Description addname,
                           AppID,
                           AppType,
                           Quantity QUAN,
                           IsMergeReceiptFlag flag_union
      FROM tbItem item
      INNER JOIN tbAdditionalCorresponding ding ON ding.MainID = item.ItemID
      AND AppType = '6'
      INNER JOIN tbItem additem ON additem.ItemID = ding.AppID
      WHERE item.IdleFlag = '0'
        AND additem.IdleFlag = 0
      UNION ALL --医嘱关联材料项目,

      SELECT '6-' + cast(item.ItemID AS VARCHAR(10)) ORD_ID,
                    item.ItemNo OrdNo,
                    item.Description,
                    '5-' + cast(additem.MaterialID AS VARCHAR(10)) YB_ID,
                           additem.MaterialNo,
                           additem.MaterialName addname,
                           AppID,
                           AppType,
                           Quantity QUAN,
                           IsMergeReceiptFlag flag_union
      FROM tbItem item
      INNER JOIN tbAdditionalCorresponding ding ON ding.MainID = item.ItemID
      AND AppType = '5'
      INNER JOIN tbMaterial additem ON additem.MaterialID = ding.AppID
      WHERE item.IdleFlag = '0'
        AND additem.IdleFlag = 0
      UNION ALL --医嘱关联药品字典,这里使用到的药品都需要维护诊断标志flag_gmp,该标志维护后,医技才能开出该药品

      SELECT '6-' + cast(item.ItemID AS VARCHAR(10)) ORD_ID,
                    item.ItemNo OrdNo,
                    item.Description,
                    '1-' + cast(additem.WMID AS VARCHAR(10)) YB_ID,
                           additem.WMNo,
                           additem.WMName,
                           AppID,
                           AppType,
                           Quantity QUAN,
                           IsMergeReceiptFlag flag_union
      FROM tbItem item
      INNER JOIN tbAdditionalCorresponding ding ON ding.MainID = item.ItemID
      AND AppType = '1'
      INNER JOIN tbWM additem ON additem.WMID = ding.AppID
      WHERE item.IdleFlag = '0'
        AND additem.IdleFlag = 0
      UNION ALL --材料对应的收费项目,旧系统没有材料没有附加项目.   新系统中材料也是存在收费项目中

      SELECT '5-' + cast(item.MaterialID AS VARCHAR(10)) ORD_ID,
                    item.MaterialNo OrdNo,
                    item.MaterialName,
                    '5-' + cast(item.MaterialID AS VARCHAR(10)) YB_ID,
                           MaterialNo WMNo,
                           MaterialName,
                           MaterialID,
                           '5' AppType,
                               '1' QUAN,
                                   '0' flag_union
      FROM tbMaterial item
      WHERE item.IdleFlag = '0'
      UNION ALL --检验项目对应的收费项目,只会关联收费项目,不关联材料,药品等

      SELECT '1-' + cast(ItemSetID AS VARCHAR(10)) ORD_ID,
                    ItemSetNo ORD_CODE,
                    --医嘱编码

                    itemset.Description ORD_NAME,
                    '6-' + cast(item.ItemID AS VARCHAR(10)) YB_ID,
                           --旧系统检验项目只会关联收费项目,不关联材料,药品等,所以写6

                           ItemNo WMNo,
                           item.Description ITEM_NAME,
                           ItemID,
                           '6' AppType,
                               match.Quantity QUAN,
                               '0' flag_union
      FROM tbItemSet itemset
      INNER JOIN tbItemMatch MATCH ON MATCH.ParentSourceID = itemset.ItemSetID
      INNER JOIN tbItem item ON item.ItemID = MATCH.SourceID
      WHERE item.IdleFlag = 0
        AND itemset.IdleFlag = 0 ) t














------------------------------vip住院加收
/*
	vip加收部分,区分住院和门诊
	门诊的直接在表中可以搜索到(上面的sql有)
	住院的则是下面的sql,其中HospitalLevel是等级
*/

SELECT a.ItemID,
       a.ItemNo,
       a.Description,
       a.Unit,
       a.UnitPrice 标准单价,
       t.UnitPrice 当前单价
FROM tbSourceItemUnitPrice t
INNER JOIN SVRCLUSTERSQL.his.dbo.tbitem a ON t.SourceID=a.itemid
AND SourceType=6
WHERE t.HospitalLevel=1

















-------------------------------

/*
	导入数据使用
	1.创建临时表
	2.导入数据
*/
CREATE TABLE NHIS.A_BD_ITEM
(
    YB_ID VARCHAR2(32),
    CODE VARCHAR2(32),
    NAME VARCHAR2(100),
    PRICE VARCHAR2(32),
    UNIT VARCHAR2(32),
    SPCODE VARCHAR2(32),
    D_CODE VARCHAR2(32),
    DT_CHA VARCHAR2(32),
    PK_ITEMCATE VARCHAR2(32)
);



insert into BD_ITEM
select
	replace(sys_guid(), '-', '') PK_ITEM,
	CODE,
	NAME,
	NAME NAME_PRT,
	SPCODE,
	D_CODE,
	PK_UNIT,
	null SPEC,
	PRICE,
	'1' FLAG_SET,
	'0' FLAG_PD,
  '0' FLAG_ACTIVE,
	'1' EU_PRICEMODE,
	PK_ITEMCATE1 PK_ITEMCATE,
	DT_CHCATE,
	null NOTE,
	'ben0422' CREATOR,
	sysdate CREATE_TIME,
	null MODIFIER,
	'0' DEL_FLAG,
	sysdate TS,
	YB_ID,
	OLD_ID,
	OLD_TYPE,
	null DESC_ITEM,
	null EXCEPT_ITEM,
	YB_ID CODE_HP,
	null CODE_STD,
	DT_ITEMTYPE
from (
  SELECT
    case when PK_UNIT is null then '7C7170A0DC0645D6BF16FAF0C567523F'
    else PK_UNIT end PK_UNIT,
    case when DT_CHA is null then '04'
    else DT_CHA end DT_CHCATE,
    case when cate.PK_ITEMCATE is null then 'FFB73D5B32A74D4A8C27F7040EC3039C'
    else cate.PK_ITEMCATE end PK_ITEMCATE1,
    '02'  DT_ITEMTYPE,
    substr(YB_ID,3,10) OLD_ID,
    SUBSTR(YB_ID,1,1) OLD_TYPE,
    item.* FROM A_BD_ITEM item
  LEFT JOIN BD_UNIT unit on unit.NAME = item.UNIT
  LEFT JOIN BD_DEFDOC def on def.OLD_ID = DT_CHA and CODE_DEFDOCLIST = '030800'
  LEFT JOIN BD_ITEMCATE cate on cate.OLD_ID = item.PK_ITEMCATE
);