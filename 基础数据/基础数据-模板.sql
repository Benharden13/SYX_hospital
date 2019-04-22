------------模板
select * from tbDepartment where  DepartmentName like '%中医科%'
select * from tbDTModel where OwnerType =1 and OwnerID ='2361'
select pcatalog.DTModelCatalogID,pcatalog.DTModelCatalogName,catalog.* from tbDTModelCatalog catalog
 inner join tbDTModelCatalog pcatalog on pcatalog.DTModelCatalogID = catalog.ParentDTModelCatalogID
 --inner join tbDTModelDAList list on catalog.DTModelCatalogID = list.DTModelCatalogID
where catalog.RootDTModelCatalogID ='103081';

select * from tbDTModelDTItemList list where DTModelCatalogID ='103201'
select pcatalog.DTModelCatalogID,pcatalog.DTModelCatalogName,catalog.DTModelCatalogID,catalog.DTModelCatalogName, catalog.ModelFlag,item.* from tbDTModelCatalog catalog
 inner join tbDTModelCatalog pcatalog on pcatalog.DTModelCatalogID = catalog.ParentDTModelCatalogID
 inner join
(select DTModelCatalogID,GroupNo,'6-'+cast(SourceID as varchar(10)) SourceID,SourceType,ItemID,ItemNo,item.Description,DosagePerTime,TakingMedicineTimeID,MedicineUsingMethodID,list.Description lDescription,Times,DATypeFlag,FlowSpeed from tbDTModelDAList list
  inner join tbItem item on item.ItemID = list.SourceID and IdleFlag = 0 and SourceType = 6
union all
select DTModelCatalogID,GroupNo,'5-'+cast(SourceID as varchar(10)) SourceID,SourceType,MaterialID,MaterialNo,MaterialName,DosagePerTime,TakingMedicineTimeID,MedicineUsingMethodID,Description lDescription,Times,DATypeFlag,FlowSpeed from tbDTModelDAList list
  inner join tbMaterial item on item.MaterialID = list.SourceID and IdleFlag = 0 and SourceType = 5
union all
select DTModelCatalogID,GroupNo,'1-'+cast(SourceID as varchar(10)) SourceID,SourceType,WMID,WMNo,WMName,DosagePerTime,TakingMedicineTimeID,MedicineUsingMethodID,Description lDescription,Times,DATypeFlag,FlowSpeed from tbDTModelDAList list
  inner join tbWM item on item.WMID = list.SourceID and IdleFlag = 0 and SourceType = 1
union all
select DTModelCatalogID,GroupNo,'2-'+cast(SourceID as varchar(10)) SourceID,SourceType,PCMID,PCMNo,PCMName,DosagePerTime,TakingMedicineTimeID,MedicineUsingMethodID,Description lDescription,Times,DATypeFlag,FlowSpeed from tbDTModelDAList list
  inner join tbPCM item on item.PCMID = list.SourceID and IdleFlag = 0 and SourceType = 2) item on item.DTModelCatalogID = catalog.DTModelCatalogID
  where catalog.RootDTModelCatalogID ='103081';
---------------------------------
