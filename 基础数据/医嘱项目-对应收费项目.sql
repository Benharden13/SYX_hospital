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



--------------------------------------------------------------
---------------------------------------------------------------------
/*
	新增医嘱与收费项目对照关系
*/

--insert into BD_ORD_ITEM
select
	replace(sys_guid(), '-', '') PK_ORDITEM,
	'a41476368e2943f48c32d0cb1179dab8' PK_ORG,
	PK_ORD,
	PK_ITEM,
	QUAN,
	'0' SORTNO,
	'ben04231717' CREATOR,
	sysdate CREATE_TIME,
	null MODIFIER,
	'0' DEL_FLAG,
	null TS,
	null FLAG_OPT,
	FLAG_PD,
	FLAG_UNION,  --默认不合并
	null OLD_ID
from (SELECT old.*
      FROM
      --旧系统的数据表
        (SELECT *
         FROM
           (SELECT
              PK_ORD,
              PK_ITEM,
              QUAN,
              '0'                FLAG_PD,
              ISMERGERECEIPTFLAG FLAG_UNION,
              ORD_ID,
              DESCRIPTION,
              aitem.YB_ID,
              ITEMNO,
              ADDNAME
            FROM A_BD_ORD_ITEM aitem
              INNER JOIN BD_ORD ord ON ord.YB_ID = aitem.ORD_ID
              INNER JOIN BD_ITEM item ON item.YB_ID = aitem.YB_ID and APPTYPE != '1'
            UNION ALL
            SELECT
              PK_ORD,
              PK_PD,
              QUAN,
              '1'                FLAG_PD,
              ISMERGERECEIPTFLAG FLAG_UNION,
              ORD_ID,
              DESCRIPTION,
              aitem.YB_ID,
              ITEMNO,
              ADDNAME
            FROM A_BD_ORD_ITEM aitem
              INNER JOIN BD_ORD ord ON ord.YB_ID = aitem.ORD_ID
              INNER JOIN BD_PD item ON item.OLD_YB_ID = aitem.YB_ID and APPTYPE = '1')
         ORDER BY PK_ORD, PK_ITEM ASC) old
        --新系统的数据表,由收费项目与药品组成
        LEFT JOIN (SELECT *
                   FROM
                     (SELECT
                        AITEM.PK_ORD,
                        AITEM.PK_ITEM,
                        ORD.CODE  ORDCODE,
                        ORD.NAME  ORDNAME,
                        ITEM.CODE ITEMCODE,
                        ITEM.NAME ITEMNAME,
                        AITEM.QUAN,
                        AITEM.FLAG_PD,
                        FLAG_UNION
                      FROM BD_ORD_ITEM AITEM
                        INNER JOIN BD_ORD ORD ON ORD.PK_ORD = AITEM.PK_ORD
                        --AND ORD.DEL_FLAG = 0
                        INNER JOIN BD_ITEM ITEM
                          ON ITEM.PK_ITEM = AITEM.PK_ITEM AND AITEM.FLAG_PD = 0  --and AITEM.DEL_FLAG = 0
                      --FLAG_PD=0  表示为收费项目
                      UNION ALL
                      SELECT
                        AITEM.PK_ORD,
                        AITEM.PK_ITEM,
                        ORD.CODE  ORDCODE,
                        ORD.NAME  ORDNAME,
                        ITEM.CODE ITEMCODE,
                        ITEM.NAME ITEMNAME,
                        QUAN,
                        AITEM.FLAG_PD,
                        FLAG_UNION
                      FROM BD_ORD_ITEM AITEM
                        INNER JOIN BD_ORD ORD ON ORD.PK_ORD = AITEM.PK_ORD
                        --AND ORD.DEL_FLAG = 0
                        INNER JOIN BD_PD ITEM
                          ON ITEM.PK_PD = AITEM.PK_ITEM AND AITEM.FLAG_PD = 1  --and AITEM.DEL_FLAG = 0
                       --FLAG_PD=0 表示为药品
                     )
                   ORDER BY PK_ORD, PK_ITEM ASC) NEW

          ON old.PK_ORD = new.PK_ORD AND old.PK_ITEM = new.PK_ITEM
             AND old.FLAG_PD = new.FLAG_PD AND old.FLAG_UNION = new.FLAG_UNION
             --AND cast(old.QUAN as VARCHAR2(10)) = cast(new.QUAN as VARCHAR2(10))
      WHERE new.QUAN IS NULL AND
            OLD.QUAN > 0
            --数量不能为0
);



--------------------

/*
	删除医嘱与收费项目对照关系
*/

--删除
SELECT *
FROM
  (
  --收费项目
  SELECT *
   FROM
     (SELECT
        PK_ORD,
        PK_ITEM,
        QUAN,
        '0' FLAG_PD,
        ISMERGERECEIPTFLAG FLAG_UNION,
        ORD_ID,
        DESCRIPTION,
        AITEM.YB_ID,
        ITEMNO,
        ADDNAME
      FROM A_BD_ORD_ITEM AITEM
        INNER JOIN BD_ORD ORD ON ORD.YB_ID = AITEM.ORD_ID
        --APPTYPE != '1' 为非药品
        INNER JOIN BD_ITEM ITEM ON ITEM.YB_ID = AITEM.YB_ID and APPTYPE != '1'
      UNION ALL
      --药品
      SELECT
        PK_ORD,
        PK_PD,
        QUAN,
        '1'                FLAG_PD,
        ISMERGERECEIPTFLAG FLAG_UNION,
        ORD_ID,
        DESCRIPTION,
        AITEM.YB_ID,
        ITEMNO,
        ADDNAME
      FROM A_BD_ORD_ITEM AITEM
        INNER JOIN BD_ORD ORD ON ORD.YB_ID = AITEM.ORD_ID
        --APPTYPE != '1' 为非药品
        INNER JOIN BD_PD ITEM ON ITEM.OLD_YB_ID = AITEM.YB_ID and APPTYPE = '1')
   ORDER BY PK_ORD, PK_ITEM ASC) OLD
  --旧系统的数据表
  RIGHT JOIN (SELECT *
              FROM
                (SELECT
                   PK_ORDITEM,
                   AITEM.PK_ORD,
                   AITEM.PK_ITEM,
                   ORD.YB_ID ordYBID,
                   ORD.CODE  ORDCODE,
                   ORD.NAME  ORDNAME,
                   ITEM.CODE ITEMCODE,
                   ITEM.NAME ITEMNAME,
                   QUAN,
                   AITEM.FLAG_PD,
                   FLAG_UNION
                 FROM BD_ORD_ITEM AITEM
                   INNER JOIN BD_ORD ORD ON ORD.PK_ORD = AITEM.PK_ORD AND ORD.DEL_FLAG = 0
                   INNER JOIN BD_ITEM ITEM ON ITEM.PK_ITEM = AITEM.PK_ITEM AND AITEM.FLAG_PD = 0 and AITEM.DEL_FLAG = 0
                 --FLAG_PD=0  表示为收费项目
                 UNION ALL
                 SELECT
                   PK_ORDITEM,
                   AITEM.PK_ORD,
                   AITEM.PK_ITEM,
                   ORD.YB_ID ordYBID,
                   ORD.CODE  ORDCODE,
                   ORD.NAME  ORDNAME,
                   ITEM.CODE ITEMCODE,
                   ITEM.NAME ITEMNAME,
                   QUAN,
                   AITEM.FLAG_PD,
                   FLAG_UNION
                 FROM BD_ORD_ITEM AITEM
                   INNER JOIN BD_ORD ORD ON ORD.PK_ORD = AITEM.PK_ORD AND ORD.DEL_FLAG = 0
                   --对应关系中的药品标志必须为1
                   INNER JOIN BD_PD ITEM ON ITEM.PK_PD = AITEM.PK_ITEM AND AITEM.FLAG_PD = 1 and AITEM.DEL_FLAG = 0

                  --FLAG_PD=0 表示为药品
                )
              ORDER BY PK_ORD, PK_ITEM ASC) NEW
  --新系统的数据表
    ON OLD.PK_ORD = NEW.PK_ORD AND OLD.PK_ITEM = NEW.PK_ITEM
       AND OLD.FLAG_PD = NEW.FLAG_PD AND OLD.FLAG_UNION = NEW.FLAG_UNION AND OLD.QUAN = NEW.QUAN
WHERE OLD.QUAN IS NULL;
