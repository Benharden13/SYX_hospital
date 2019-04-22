--旧系统的材料项目查找
SELECT
  material.MaterialID                              OLD_ID,
  MaterialNo                                       CODE,
  MaterialName                                     NAME,
  SpellCode                                        SPCODE,
  WBCode                                           D_CODE,
  Unit,
  UnitPrice                                        PRICE,
  DisPubPatientSelfPayFlag,
  --区公医先自费类型
  PreSelfPayFlag,
  --先自费类型
  '5-' + convert(VARCHAR(20), material.MaterialID) YB_ID
FROM tbMaterial material
  INNER JOIN tbMaterialDetail detail ON material.MaterialID = detail.MaterialID
WHERE IdleFlag = 0


insert into BD_ITEM
select
	PK_ITEM,
	itemnew.CODE,
	itemnew.NAME,
	itemnew.NAME NAME_PRT,
	itemnew.SPCODE,
	itemnew.D_CODE,
	PK_UNIT,
	null SPEC,
	PRICE,
	FLAG_SET,
	FLAG_PD,
	FLAG_ACTIVE,
	EU_PRICEMODE,
	PK_ITEMCATE,
	DT_CHCATE,
	null NOTE,
	'ben0308' CREATOR,
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
from 


