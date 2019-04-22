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
		该值对应新系统码表的old_id,材料默认的病案分类为22,
	上次编码
	患者记账类型-自费类-费别	
		对应新系统的费用分类
	附加收费项目
其中有两段sql,一段为查询在用收费项目,一段为收费项目下的组套  
	*/

--患者记账类型,需要注意的是自费类,因为收费项目使用费用分类pk_itemcate是使用自费类型下收费项目对应的费别
SELECT * from tbPatientChargeType where PatientChargeTypeName like '%自费%'
--收费项目费别及自付比例设定 数据为患者记账类型-收费项目  收费项目-费别
SELECT * from tbChargeItemFeeKindAndPayproportion = '86';



SELECT
	(SELECT total
	 FROM (SELECT
					 count(1)                                total,
					 '6-' + cast(item.ItemID AS VARCHAR(10)) ItemID
				 FROM tbItem item
					 INNER JOIN tbAdditionalCorresponding ding ON ding.MainID = item.ItemID AND AppType = '6'
					 INNER JOIN tbItem additem ON additem.ItemID = ding.AppID
				 WHERE item.IdleFlag = '0' AND additem.IdleFlag = 0
				 GROUP BY '6-' + cast(item.ItemID AS VARCHAR(10))) t
	 WHERE t.ItemID = '6-' + cast(item.ItemID AS VARCHAR(10))) addtotal,
	 '6-' + cast(item.ItemID AS VARCHAR(10)) YB_ID,
	ItemNo                                                     ContainerNo,
	Description                                                Description,
	UnitPrice,Unit,
	SpellCode,
	WBCode,
	AddProportion,
	--小孩加收比例
	SDProportion,
	--门诊特诊加收
	null DisPubPatientSelfPayFlag,
	--材料项目拥有的字段,区公医先自费类型
	null PreSelfPayFlag,
	--材料项目拥有的字段,先自费类型
	NewCaseChargeTypeFlag
	--病案分类
FROM tbItem item
	--INNER JOIN tbAdditionalCorresponding ding on ding.
where item.IdleFlag = 0
UNION ALL
--材料
SELECT
	NULL         addtotal,
	rtrim('5-' + cast(material.MaterialID as VARCHAR(10))) YB_ID,
	MaterialNo   ContainerNo,
	MaterialName Description,
	UnitPrice,Unit,
	SpellCode,
	WBCode,
	null AddProportion,
	--小孩加收比例
	null SDProportion,
	DisPubPatientSelfPayFlag,
	--材料项目拥有的字段,区公医先自费类型
	PreSelfPayFlag,
--材料项目拥有的字段,先自费类型
	'22' NewCaseChargeTypeFlag
	--病案分类,材料默认的病案分类为22,该值对应新系统码表的old_id
FROM tbMaterial material
	LEFT JOIN tbChargeItemFeeKindAndPayproportion pay
		ON SourceID = material.MaterialID AND SourceType = 5 AND PatientChargeTypeID = '95'
	--tbchargeitemfeekindandpayproportion='95' 是旧系统中患者记账类型:材料自费类
	inner join tbMaterialDetail detail on material.MaterialID = detail.MaterialID
WHERE material.IdleFlag = 0
UNION ALL
--容器
SELECT
	NULL         addtotal,
	rtrim('9-' + cast(containerid as VARCHAR(10))) YB_ID,
	containerno                             containerno,
	description                             description,
	unitprice,Unit,
	NULL                                    spellcode,
	NULL                                    wbcode,
	null AddProportion,
	--小孩加收比例
	null SDProportion,
	null DisPubPatientSelfPayFlag,
	--材料项目拥有的字段,区公医先自费类型
	null PreSelfPayFlag,
	--材料项目拥有的字段,先自费类型
	'22' NewCaseChargeTypeFlag
	--病案分类,材料默认的病案分类为22,该值对应新系统码表的old_id
FROM tbcontainer con
	LEFT JOIN tbchargeitemfeekindandpayproportion pay
		ON sourceid = con.containerid AND sourcetype = 9 AND patientchargetypeid = '102'
--tbchargeitemfeekindandpayproportion='102' 是旧系统中患者记账类型:标本自费类
WHERE idleflag = 0



--收费项目的对照关系
------------------------------------------------------------
--------------旧系统医嘱对应的收费项目
--在对比前一定要保证医嘱的YB_ID与旧系统的一致
SELECT
	ORD_ID,
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
	IsMergeReceiptFlag
	--是否合并标志,部分检查项目存在该字段,例如:开立两个相同的检查项目,项目中可能包含着相同的收费项目,只需要收一次
FROM
	(
		--如果项目本身有价格,那么该关系也需要在系统中进行维护
		SELECT
			'6-' + cast(item.ItemID AS VARCHAR(10)) ORD_ID,
			item.ItemNo                             OrdNo,
			item.Description,
			'6-' + cast(ItemID AS VARCHAR(10))      YB_ID,
			ItemNo,
			Description                             addname,
			ItemID,
			'6'                                     AppType,
			'1'                                     QUAN,
			'0'                                     IsMergeReceiptFlag
		FROM tbItem item
		WHERE IdleFlag = 0 AND UnitPrice > 0
		UNION ALL
		--医嘱项目与收费项目的对照关系
		SELECT
			'6-' + cast(item.ItemID AS VARCHAR(10))    ORD_ID,
			item.ItemNo                                OrdNo,
			item.Description,
			'6-' + cast(additem.ItemID AS VARCHAR(10)) YB_ID,
			additem.ItemNo,
			additem.Description                        addname,
			AppID,
			AppType,
			Quantity                                   QUAN,
			IsMergeReceiptFlag                         flag_union
		FROM tbItem item
			INNER JOIN tbAdditionalCorresponding ding ON ding.MainID = item.ItemID AND AppType = '6'
			INNER JOIN tbItem additem ON additem.ItemID = ding.AppID
		WHERE item.IdleFlag = '0' AND additem.IdleFlag = 0
		UNION ALL
		--医嘱关联材料项目,
		SELECT
			'6-' + cast(item.ItemID AS VARCHAR(10))        ORD_ID,
			item.ItemNo                                    OrdNo,
			item.Description,
			'5-' + cast(additem.MaterialID AS VARCHAR(10)) YB_ID,
			additem.MaterialNo,
			additem.MaterialName                           addname,
			AppID,
			AppType,
			Quantity                                       QUAN,
			IsMergeReceiptFlag                             flag_union
		FROM tbItem item
			INNER JOIN tbAdditionalCorresponding ding ON ding.MainID = item.ItemID AND AppType = '5'
			INNER JOIN tbMaterial additem ON additem.MaterialID = ding.AppID
		WHERE item.IdleFlag = '0' AND additem.IdleFlag = 0
		UNION ALL
		--医嘱关联药品字典,这里使用到的药品都需要维护诊断标志flag_gmp,该标志维护后,医技才能开出该药品
		SELECT
			'6-' + cast(item.ItemID AS VARCHAR(10))  ORD_ID,
			item.ItemNo                              OrdNo,
			item.Description,
			'1-' + cast(additem.WMID AS VARCHAR(10)) YB_ID,
			additem.WMNo,
			additem.WMName,
			AppID,
			AppType,
			Quantity                                 QUAN,
			IsMergeReceiptFlag                       flag_union
		FROM tbItem item
			INNER JOIN tbAdditionalCorresponding ding ON ding.MainID = item.ItemID AND AppType = '1'
			INNER JOIN tbWM additem ON additem.WMID = ding.AppID
		WHERE item.IdleFlag = '0' AND additem.IdleFlag = 0
		UNION ALL
		--材料对应的收费项目,旧系统没有材料没有附加项目.   新系统中材料也是存在收费项目中
		SELECT
			'5-' + cast(item.MaterialID AS VARCHAR(10)) ORD_ID,
			item.MaterialNo                             OrdNo,
			item.MaterialName,
			'5-' + cast(item.MaterialID AS VARCHAR(10)) YB_ID,
			MaterialNo                                  WMNo,
			MaterialName,
			MaterialID,
			'5'                                         AppType,
			'1'                                         QUAN,
			'0'                                         flag_union
		FROM tbMaterial item
		WHERE item.IdleFlag = '0'
		UNION ALL
		--检验项目对应的收费项目,只会关联收费项目,不关联材料,药品等
		SELECT
			'1-' + cast(ItemSetID AS VARCHAR(10))   ORD_ID,
			ItemSetNo                               ORD_CODE,
			--医嘱编码
			itemset.Description                     ORD_NAME,
			'6-' + cast(item.ItemID AS VARCHAR(10)) YB_ID,
			--旧系统检验项目只会关联收费项目,不关联材料,药品等,所以写6
			ItemNo                                  WMNo,
			item.Description                        ITEM_NAME,
			ItemID,
			'6'                                     AppType,
			match.Quantity                          QUAN,
			'0'                                     flag_union
		FROM tbItemSet itemset
			INNER JOIN tbItemMatch match ON match.ParentSourceID = itemset.ItemSetID
			INNER JOIN tbItem item ON item.ItemID = match.SourceID
		WHERE item.IdleFlag = 0 AND itemset.IdleFlag = 0
	) t
