
--escape '!';
SELECT * from BD_ORD_ALIAS where ALIAS = '孕酮（非月经期_北院）';

UPDATE BD_ORD_ALIAS
SET SPCODE = replace(SPCODE,'_',''),D_CODE = replace(D_CODE,'_','')
where SPCODE like '%!_%' escape '!'

UPDATE BD_ORD_ALIAS
SET SPCODE = replace(SPCODE,'[',''),D_CODE = replace(D_CODE,'[','')
where SPCODE like '%[%' --escape '!'

UPDATE BD_ORD_ALIAS
SET SPCODE = replace(SPCODE,']',''),D_CODE = replace(D_CODE,']','')
where SPCODE like '%]%' --escape '!'

UPDATE BD_ORD_ALIAS
SET SPCODE = replace(SPCODE,'#',''),D_CODE = replace(D_CODE,'#','')
where SPCODE like '%#%' --escape '!'

UPDATE BD_ORD_ALIAS
SET SPCODE = replace(SPCODE,'{',''),D_CODE = replace(D_CODE,'{','')
where SPCODE like '%{%' --escape '!'

UPDATE BD_ORD_ALIAS
SET SPCODE = replace(SPCODE,'&',''),D_CODE = replace(D_CODE,'&','')
where SPCODE like '%&%' --escape '!'

UPDATE BD_ORD_ALIAS
SET SPCODE = replace(SPCODE,'\',''),D_CODE = replace(D_CODE,'\','')
where SPCODE like '%\%' --escape '!'

UPDATE BD_ORD_ALIAS
SET SPCODE = replace(SPCODE,'|',''),D_CODE = replace(D_CODE,'|','')
where SPCODE like '%|%' --escape '!'

UPDATE BD_ORD_ALIAS
SET SPCODE = replace(SPCODE,':',''),D_CODE = replace(D_CODE,':','')
where SPCODE like '%:%' --escape '!';

UPDATE BD_ORD_ALIAS
SET SPCODE = replace(SPCODE,'.',''),D_CODE = replace(D_CODE,'.','')
where SPCODE like '%.%' --escape '!';

UPDATE BD_ORD_ALIAS
SET SPCODE = replace(SPCODE,' ',''),D_CODE = replace(D_CODE,' ','')
where SPCODE like '% %' --escape '!';

UPDATE BD_ORD_ALIAS
SET SPCODE = replace(SPCODE,'/',''),D_CODE = replace(D_CODE,'/','')
where SPCODE like '%/%'


--------------------------
SELECT NAME,SPCODE,D_CODE from BD_ITEM  where SPCODE like '%[%'
   or SPCODE like '%]%'  or SPCODE like '%{%'  or SPCODE like '%}%'  or SPCODE like '%#%'
    or SPCODE like '%&%' or SPCODE like '%\%' or SPCODE like '%|%' or SPCODE like '%:%' or SPCODE like '%.%'
    or SPCODE like '% %' or SPCODE like '%/%';

SELECT SPCODE from BD_ITEM

UPDATE BD_ITEM
SET SPCODE = replace(SPCODE,'_',''),D_CODE = replace(D_CODE,'_','')
where SPCODE like '%!_%' escape '!'

UPDATE BD_ITEM
SET SPCODE = replace(SPCODE,'[',''),D_CODE = replace(D_CODE,'[','')
where SPCODE like '%[%' --escape '!'

UPDATE BD_ITEM
SET SPCODE = replace(SPCODE,']',''),D_CODE = replace(D_CODE,']','')
where SPCODE like '%]%' --escape '!'

UPDATE BD_ITEM
SET SPCODE = replace(SPCODE,'#',''),D_CODE = replace(D_CODE,'#','')
where SPCODE like '%#%' --escape '!'

UPDATE BD_ITEM
SET SPCODE = replace(SPCODE,'{',''),D_CODE = replace(D_CODE,'{','')
where SPCODE like '%{%' --escape '!'

UPDATE BD_ITEM
SET SPCODE = replace(SPCODE,'}',''),D_CODE = replace(D_CODE,'}','')
where SPCODE like '%}%' --escape '!'

UPDATE BD_ITEM
SET SPCODE = replace(SPCODE,'&',''),D_CODE = replace(D_CODE,'&','')
where SPCODE like '%&%' --escape '!'

UPDATE BD_ITEM
SET SPCODE = replace(SPCODE,'\',''),D_CODE = replace(D_CODE,'\','')
where SPCODE like '%\%' --escape '!'

UPDATE BD_ITEM
SET SPCODE = replace(SPCODE,'|',''),D_CODE = replace(D_CODE,'|','')
where SPCODE like '%|%' --escape '!'

UPDATE BD_ITEM
SET SPCODE = replace(SPCODE,':',''),D_CODE = replace(D_CODE,':','')
where SPCODE like '%:%' --escape '!';

UPDATE BD_ITEM
SET SPCODE = replace(SPCODE,'.',''),D_CODE = replace(D_CODE,'.','')
where SPCODE like '%.%' --escape '!';

UPDATE BD_ITEM
SET SPCODE = replace(SPCODE,' ',''),D_CODE = replace(D_CODE,' ','')
where SPCODE like '% %' --escape '!';

UPDATE BD_ITEM
SET SPCODE = replace(SPCODE,'/',''),D_CODE = replace(D_CODE,'/','')
where SPCODE like '%/%'

-------------------------
SELECT NAME,SPCODE from BD_PD  where SPCODE like '%[%'
   or SPCODE like '%]%'  or SPCODE like '%{%'  or SPCODE like '%}%'  or SPCODE like '%#%'
    or SPCODE like '%&%' or SPCODE like '%\%' or SPCODE like '%|%' or SPCODE like '%:%' or SPCODE like '%.%'
    or SPCODE like '% %' or SPCODE like '%/%';

 -------------------------
 SELECT ALIAS,SPCODE,D_CODE from BD_PD_AS  where SPCODE like '%[%'
   or SPCODE like '%]%'  or SPCODE like '%{%'  or SPCODE like '%}%'  or SPCODE like '%#%'
    or SPCODE like '%&%' or SPCODE like '%\%' or SPCODE like '%|%' or SPCODE like '%:%' or SPCODE like '%.%'
    or SPCODE like '% %' or SPCODE like '%/%';