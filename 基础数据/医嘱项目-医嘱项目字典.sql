/*
   旧系统UsingScopeFlag:
					  WHEN 1 THEN '门诊'
                      WHEN 2 THEN '住院'
                      WHEN 4 THEN '技诊'
                      WHEN 8 THEN '检验'
                      WHEN 16 THEN '库存'
                      WHEN 32 THEN '体检'
                      WHEN 3 THEN '门诊、住院'
                      WHEN 7 THEN '门诊、住院、技诊'
                      WHEN 63 THEN '门诊、住院、技诊、检验、库存、体检'
                      WHEN 0 THEN '停用'
                      WHEN 28 THEN '技诊、检验、库存'
                      WHEN 30 THEN '住院、技诊、检验、库存'
                      WHEN 14 THEN '住院、技诊、检验'
                      WHEN 11 THEN '门诊、住院、检验'
                      WHEN 12 THEN '技诊、检验'
                      WHEN 15 THEN '门诊、住院、技诊、检验'
                      WHEN 31 THEN '门诊、住院、技诊、检验、库存'
                      WHEN 39 THEN '门诊、住院、技诊、体检'
                      WHEN 47 THEN '门诊、住院、技诊、检验、体检'
                      WHEN 56 THEN '检验、库存、体检'
                      WHEN 33 THEN '门诊、体检'
                      WHEN 60 THEN '技诊、检验、库存、体检'
                      WHEN 40 THEN '检验、体检'
                      WHEN 62 THEN '住院、技诊、检验、库存、体检'
                      WHEN 48 THEN '库存、体检'
                      WHEN 35 THEN '门诊、住院、体检'*/

--检验项目
select
	'1-' + cast(ItemSetID as varchar(10)) YB_ID,
	'1' OLD_TYPE,
	ItemSetID OLD_ID, --医嘱ID
	ItemSetNo ORD_CODE, --医嘱编码
	itemset.Description ORD_NAME,
	itemset.UnitPrice ORD_PRICE,
	Unit,
	itemset.SpellCode SPCODE,itemset.WBCode D_CODE,
	--ItemID ITEM_ID,
	--ItemNo ITEM_CODE,
	--item.Description ITEM_NAME,
	--match.Quantity QUAN,
	--item.UnitPrice ITEM_PRICE,
	--match.Quantity * item.UnitPrice AMOUNT,
	ExamineDepartmentID, --执行科室
	ExamineExemplarID, --标本ID
	ContainerID, --容器ID
	CASE when UsingScopeFlag in ('1','3','7','11','15','31','39','47','33','35') then 1 ELSE 0 end FLAG_OP,
	--门诊启用
	CASE when UsingScopeFlag in ('2','3','7','63','30','14','11','15','31','39','47','62','35') then 1 ELSE 0 end FLAG_IP,
	--住院启用
	'NHIS12345NEW1001ZZ1000000000SAKM' PK_ORDTYPE
	--医嘱项目分类
from tbItemSet itemset
	--inner join tbItemMatch match on match.ParentSourceID = itemset.ItemSetID
	--inner join tbItem item on item.ItemID = match.SourceID
where itemset.IdleFlag = 0
UNION ALL
SELECT
	 '6-' + cast(item.ItemID AS VARCHAR(10)) YB_ID,
	 '6' OLD_TYPE,
	ItemID OLD_ID,
	ItemNo                                                     ContainerNo,
	Description                                                Description,
	UnitPrice,Unit,
	SpellCode,
	WBCode,
	NULL ExamineDepartmentID,
	--执行科室,收费项目中包含检查项目,其实是有执行科室的
	NULL ExamineExemplarID, --标本ID
	NULL ContainerID, --容器ID
	'1' FLAG_OP,
	'1' FLAG_IP,
	--'NHIS12345NEW1001ZZ1000000000SALL' PK_ORDTYPE
	--医嘱项目分类,收费项目 需要修改
FROM tbItem item
	--INNER JOIN tbAdditionalCorresponding ding on ding.
where item.IdleFlag = 0
UNION ALL
--材料
SELECT
	rtrim('5-' + cast(material.MaterialID as VARCHAR(10))) YB_ID,
	'5' OLD_TYPE,
	material.MaterialID OLD_ID,
	MaterialNo   ContainerNo,
	MaterialName Description,
	UnitPrice,Unit,
	SpellCode,
	WBCode,
	NULL ExamineDepartmentID,
	--执行科室,收费项目中包含检查项目,其实是有执行科室的
	NULL ExamineExemplarID, --标本ID
	NULL ContainerID, --容器ID
	'1' FLAG_OP,
	'1' FLAG_IP,
	'NHIS12345NEW1001ZZ1000000000SALL' PK_ORDTYPE
	--医嘱项目分类,材料
FROM tbMaterial material
	LEFT JOIN tbChargeItemFeeKindAndPayproportion pay
		ON SourceID = material.MaterialID AND SourceType = 5 AND PatientChargeTypeID = '95'
	--tbchargeitemfeekindandpayproportion='95' 是旧系统中患者记账类型:材料自费类
	inner join tbMaterialDetail detail on material.MaterialID = detail.MaterialID
WHERE material.IdleFlag = 0
UNION ALL
--容器
SELECT
	rtrim('9-' + cast(containerid as VARCHAR(10))) YB_ID,
	'9' OLD_TYPE,
	con.ContainerID OLD_ID,
	containerno                             containerno,
	description                             description,
	unitprice,Unit,
	NULL                                    spellcode,
	NULL                                    wbcode,
	NULL ExamineDepartmentID,
	--执行科室,收费项目中包含检查项目,其实是有执行科室的
	NULL ExamineExemplarID, --标本ID
	NULL ContainerID, --容器ID
	'1' FLAG_OP,
	'1' FLAG_IP,
	'NHIS12345NEW1001ZZ1000000000SALL' PK_ORDTYPE
	--医嘱项目分类,材料
FROM tbcontainer con
	LEFT JOIN tbchargeitemfeekindandpayproportion pay
		ON sourceid = con.containerid AND sourcetype = 9 AND patientchargetypeid = '102'
--tbchargeitemfeekindandpayproportion='102' 是旧系统中患者记账类型:标本自费类
WHERE idleflag = 0;