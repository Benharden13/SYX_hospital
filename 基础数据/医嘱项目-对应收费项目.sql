--收费项目的对照关系




----------------------------------------------------------------------
--新增的医嘱-收费项目对照关系
--insert into BD_ORD_ITEM
select
	replace(sys_guid(), '-', '') PK_ORDITEM,
	'a41476368e2943f48c32d0cb1179dab8' PK_ORG,
	PK_ORD,
	--bd_ord的主键
	PK_ITEM,
	--bd_item,bd_pd的主键
	QUAN,
	'0' SORTNO,
	--序号,没有要求需要正确
	'ben0404' CREATOR,
	--创建者,建议每次导入使用该字段进行区分
	sysdate CREATE_TIME,
	null MODIFIER,
	'0' DEL_FLAG,
	null TS,
	null FLAG_OPT,
	FLAG_PD,
	--药品标志,0为收费项目,1为药品,----旧系统TYPE1,2,3为药品,
	FLAG_UNION,
	--合并标志
	null OLD_ID
from (
--收费项目的对照关系
--新增数据
SELECT ORDNO,DESCRIPTION,ITEMNO,ADDNAME,new.QUAN, case when  APPTYPE = 1 then '1' ELSE '0' end FLAG_PD,ISMERGERECEIPTFLAG FLAG_UNION,PK_ORD,PK_ITEM,ordname,new.itemname  from
(SELECT
  ord.YB_ID ORD_ID,
  item.YB_ID,
  QUAN,
  PK_ORDITEM,ord.NAME,item.NAME itemname,FLAG_UNION
FROM BD_ORD_ITEM orditem
  INNER JOIN BD_ORD ord ON ord.PK_ORD = orditem.PK_ORD
  INNER JOIN BD_ITEM item ON item.PK_ITEM = orditem.PK_ITEM AND orditem.FLAG_PD = 0 --药品标志,决定着使用什么表进行关联
                             and ord.DEL_FLAG = 0 and item.DEL_FLAG = 0
UNION ALL
SELECT
  ord.YB_ID ORD_ID,
  OLD_YB_ID  YB_ID,
  QUAN,
  PK_ORDITEM,ord.NAME,item.NAME,FLAG_UNION
FROM BD_ORD_ITEM orditem
  INNER JOIN BD_ORD ord ON ord.PK_ORD = orditem.PK_ORD
  INNER JOIN BD_PD item ON item.PK_PD = orditem.PK_ITEM AND orditem.FLAG_PD = 1 and ord.DEL_FLAG = 0 and item.DEL_FLAG = 0) old
--新系统的数据,需要进行对比更新
RIGHT JOIN (SELECT aitem.*,ord.DEL_FLAG,PK_ORD,PK_ITEM,ord.NAME ordname,item.NAME itemname from A_BD_ORD_ITEM aitem
  INNER JOIN BD_ORD ord on ord.YB_ID = ORD_ID
  INNER JOIN BD_ITEM item on item.YB_ID = aitem.YB_ID and APPTYPE <> 1
  UNION ALL
  SELECT aitem.*,ord.DEL_FLAG,PK_ORD,PK_PD, ord.NAME ordname,item.NAME itemname from A_BD_ORD_ITEM aitem
  INNER JOIN BD_ORD ord on ord.YB_ID = ORD_ID
  INNER JOIN BD_PD item on item.OLD_YB_ID = aitem.YB_ID and APPTYPE =1
           ) new on new.ORD_ID = old.ORD_ID and new.YB_ID = old.YB_ID and new.QUAN = old.QUAN and ISMERGERECEIPTFLAG = FLAG_UNION
where NAME is null and DEL_FLAG = 0
      and new.QUAN <> 0 --旧系统有数据维护错误,数量为0,需要过滤;
);



--------------------

--删除医嘱-收费项目对照关系
--UPDATE BD_ORD_ITEM
--SET DEL_FLAG = '1',
MODIFIER = 'ben0404'  --创建者,建议每次导入使用该字段进行区分
--where PK_ORDITEM in (
SELECT PK_ORDITEM
  FROM
    (SELECT
       ord.YB_ID ORD_ID,
       item.YB_ID,
       QUAN,
       PK_ORDITEM,
       ord.NAME,
       item.NAME itemname,
       FLAG_UNION
     FROM BD_ORD_ITEM orditem
       INNER JOIN BD_ORD ord ON ord.PK_ORD = orditem.PK_ORD
       INNER JOIN BD_ITEM item ON item.PK_ITEM = orditem.PK_ITEM AND orditem.FLAG_PD = 0 --药品标志,决定着使用什么表进行关联
                                  AND ord.DEL_FLAG = 0 AND item.DEL_FLAG = 0 and orditem.DEL_FLAG = 0
     UNION ALL
     SELECT
       ord.YB_ID ORD_ID,
       OLD_YB_ID YB_ID,
       QUAN,
       PK_ORDITEM,
       ord.NAME,
       item.NAME,
       FLAG_UNION
     FROM BD_ORD_ITEM orditem
       INNER JOIN BD_ORD ord ON ord.PK_ORD = orditem.PK_ORD
       INNER JOIN BD_PD item
         ON item.PK_PD = orditem.PK_ITEM AND orditem.FLAG_PD = 1 AND ord.DEL_FLAG = 0 AND item.DEL_FLAG = 0 and orditem.DEL_FLAG = 0) old
    --新系统的数据,需要进行对比更新
    LEFT JOIN (SELECT
                 aitem.*,
                 DEL_FLAG
               FROM A_BD_ORD_ITEM aitem
                 INNER JOIN BD_ORD ord ON ord.YB_ID = ORD_ID) new
      ON new.ORD_ID = old.ORD_ID AND new.YB_ID = old.YB_ID AND new.QUAN = old.QUAN AND ISMERGERECEIPTFLAG = FLAG_UNION
  WHERE DESCRIPTION IS NULL
);



------------------------------------------------------------
--------------旧系统医嘱对应的收费项目
--在对比前一定要保证医嘱的YB_ID与旧系统的一致
SELECT
	ORD_ID,
	--bd_ord表的旧ID
	OrdNo,
	--医嘱编码
	Description,
	--医嘱名称
	YB_ID,
	--医嘱关联的收费项目旧ID
	ItemNo,
	--收费项目的编码
	addname,
	--收费项目的名称
	ItemID,
	--收费项目的id,不建议使用,请用YB_id关联
	AppType,
	--项目类型,1-西药,2-成药,3-草药,5-材料,6-收费项目,9-容器,唯一标志YB_ID就是使用AppType-ItemID组成
	QUAN,
	--数量
	IsMergeReceiptFlag
	--是否合并
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
