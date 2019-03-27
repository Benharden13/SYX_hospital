select '6-'+cast(item.ItemID as varchar(10)) ORD_ID,item.Description,'6-'+cast(additem.ItemID as varchar(10)) YB_ID ,additem.ItemNo,additem.Description addname,AppID,AppType,Quantity QUAN,IsMergeReceiptFlag flag_union from tbItem item
	inner join tbAdditionalCorresponding ding on ding.MainID = item.ItemID and AppType = '6'
	inner join tbItem additem on additem.ItemID = ding.AppID
 where item.IdleFlag = '0' and additem.IdleFlag = 0
union all
select '6-'+cast(item.ItemID as varchar(10)) ORD_ID,item.Description,'5-'+cast(additem.MaterialID as varchar(10)) YB_ID,additem.MaterialNo,additem.MaterialName addname,AppID,AppType,Quantity QUAN,IsMergeReceiptFlag flag_union from tbItem item
	inner join tbAdditionalCorresponding ding on ding.MainID = item.ItemID and AppType = '5'
	inner join tbMaterial additem on additem.MaterialID = ding.AppID
 where item.IdleFlag = '0' and additem.IdleFlag = 0
union all
--这里使用到的药品都需要维护诊断标志
select '6-'+cast(item.ItemID as varchar(10)) ORD_ID,item.Description,'1-'+cast(additem.WMID as varchar(10)) YB_ID,additem.WMNo,additem.WMName,AppID,AppType,Quantity QUAN,IsMergeReceiptFlag flag_union from tbItem item
	inner join tbAdditionalCorresponding ding on ding.MainID = item.ItemID and AppType = '1'
	inner join tbWM additem on additem.WMID = ding.AppID
 where item.IdleFlag = '0' and additem.IdleFlag = 0