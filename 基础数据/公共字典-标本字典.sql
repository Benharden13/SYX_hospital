--------------------------
--旧系统的数据,标本数据
/*tbExamineExemplar：检验标本
tbAdditionalCorresponding：附加对应关系
tbMaterial：材料 因为标本有附加材料项目*/

--该sql关联了附加收费项目,所以如果要获取标本字典,使用DISTINCT ExamineExemplarID,ExemplarNo,exemplar.Description 即可
SELECT ExamineExemplarID,ExemplarNo,exemplar.Description,exemplar.MnemonicCode,'6-'+cast(item.ItemID as varchar(10)) YB_ID,item.UnitPrice '1' quan from tbExamineExemplar exemplar
  LEFT JOIN tbItem item on item.ItemID = exemplar.ItemID
where exemplar.IdleFlag = 0 and ExamineExemplarID <> '-1'
-- -1是根目录主键,不用
UNION ALL
SELECT ExamineExemplarID,ExemplarNo,exemplar.Description,exemplar.MnemonicCode,'5-'+cast(item.MaterialID as varchar(10)),item.UnitPrice,Quantity quan from tbExamineExemplar exemplar
  INNER JOIN tbAdditionalCorresponding ding on ding.MainID = exemplar.ExamineExemplarID and MainType = '8'
  INNER JOIN tbMaterial item on item.MaterialID = ding.AppID
where exemplar.IdleFlag = 0 and ExamineExemplarID <> '-1'

--------------------------------------------------
--新系统增加标本

--增加标本,可以复用与其他的码表
--INSERT INTO BD_DEFDOC
SELECT
  replace(sys_guid(), '-', '') PK_DEFDOC,
  '~                               '                           PK_ORG,
  '030200' CODE_DEFDOCLIST,
  ExamineExemplarID CODE,
  null BA_CODE,
  Description NAME,
  Description SHORTNAME,
  MnemonicCode PY_CODE,
  null D_CODE,
  null MEMO,
  'ben0404' CREATOR,
  sysdate CREATE_TIME,
  '0' DEL_FLAG,
  '0' FLAG_DEF,
  null TS,
  null CODE_PARENT,
  null PK_DEFDOCLIST,
  null SPCODE,
  null MODIFIER,
  null MODITY_TIME,
  null EU_TYPE,
  ExemplarNo CODE_STD,
  ExamineExemplarID OLD_ID,
  null NAME_STD
FROM (SELECT DISTINCT ExamineExemplarID,ExemplarNo,Description,MnemonicCode from A_BD_DEFDOC_EXEMPLAR e
     where NOT exists(SELECT * from BD_DEFDOC doc where CODE_DEFDOCLIST = '030200' and e.EXAMINEEXEMPLARID = OLD_ID)
     ) t

--码表里的项目,关联的收费项目,新增
SELECT EXAMINEEXEMPLARID,QUAN,PK_ITEM from A_BD_DEFDOC_EXEMPLAR ex
  LEFT JOIN BD_ITEM item on item.YB_ID = ex.YB_ID
where ex.YB_ID <> '6--1' and NOT exists(
  SELECT CODE_DEFDOC,PK_ITEM,QUAN from BD_ITEM_DEFDOC doc
where CODE_DEFDOCLIST = '030200' AND
  EU_PVTYPE = '3' and DEL_FLAG = 0 and
  ---
  doc.QUAN = ex.QUAN and CODE_DEFDOC = EXAMINEEXEMPLARID and doc.PK_ITEM = item.PK_ITEM
);
--码表里的项目,关联的收费项目,删除
SELECT CODE_DEFDOC,PK_ITEM,QUAN from BD_ITEM_DEFDOC doc
where CODE_DEFDOCLIST = '030200' AND
  EU_PVTYPE = '3' and DEL_FLAG = 0 and not exists(SELECT EXAMINEEXEMPLARID,QUAN,PK_ITEM from A_BD_DEFDOC_EXEMPLAR ex
  LEFT JOIN BD_ITEM item on item.YB_ID = ex.YB_ID
where ex.YB_ID <> '6--1' and
--------------------------