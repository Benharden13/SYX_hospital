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

