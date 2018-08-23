SELECT * FROM CUX_TEN_DIS_RESOURCES_TMP ctd;      ----line
SELECT * FROM CUX.CUX_RESOURCE_ALLOCATION_TMP cra ;---header

SELECT cra.RESOURCE_DIS_ID,cra.RESOURCE_NUMBER,cra.STATUS,cra.PROJECT_ID,cra.PROJECT_NAME,cra.PROJECT_BLOCK_ID,ctd.PROJECT_BLOCK_ID,ctd.PROJECT_BLOCK_NAME,ctd.PROJECT_PEROID,cra.PROJECT_BLOCK_NAME,ctd.VENDOR_NAME,ctd.BLOCK_DIVISION,ctd.AGREEMENT_NUMBER,ctd.EFFECTIVE_TIME
FROM CUX.CUX_RESOURCE_ALLOCATION_TMP cra ,
  CUX_TEN_DIS_RESOURCES_TMP ctd
WHERE ctd.RESOURCE_DIS_ID=cra.RESOURCE_DIS_ID 
and cra.PROJECT_NAME like '%��خ��Ϫ����Ŀ%'
;
 

SELECT *
FROM CUX.CUX_PR_PLAN_HEADERS crph ,
  CUX.CUX_PR_PLAN_LINES crpl
WHERE crph.HEADER_ID=crpl.HEADER_ID
AND crph.PLAN_NUMBER='S201706027' ;
 

 
select pv.VENDOR_NAME,pv.VENDOR_ID,pha.SEGMENT1,pha.PO_HEADER_ID,pla.ITEM_ID,msib.segment1,pla.ITEM_DESCRIPTION,pla.QUANTITY,pla.UNIT_PRICE,pla.ATTRIBUTE10,pla.ATTRIBUTE11
from PO.PO_HEADERS_ALL pha,PO.PO_LINES_ALL  pla ,PO_VENDORS pv,mtl_system_items_b msib 
where pla.PO_HEADER_ID=pha.PO_HEADER_ID
and pha.TYPE_LOOKUP_CODE='BLANKET'
and  msib.inventory_item_id = pla.ITEM_ID
and msib.ORGANIZATION_ID=460
and pv.VENDOR_ID=pha.VENDOR_ID
--and msib.segment1='3401070010000006'
and pha.SEGMENT1='2016000179'
and pla.item_description like '%50*%'