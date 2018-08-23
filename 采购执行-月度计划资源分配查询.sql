--查询月度计划的物料 id
select cppl.LINE_ID,cppl.ITEM_ID,msib.SEGMENT1,cppl.UNIT_PRICE,cppl.PLAN_QUANTITY,cpph.PLAN_NUMBER,cpph.CONTRACT_ID ,
cppl.AG_HEADER_ID,cppl.AG_LINE_ID
from cux_pr_plan_headers cpph,CUX.CUX_PR_PLAN_LINES cppl,mtl_system_items_b msib 
where cpph.HEADER_ID=cppl.HEADER_ID and  msib.inventory_item_id = cppl.item_id 
and msib.ORGANIZATION_ID=460
and cpph.PLAN_NUMBER='S201706009';


--查询这个物料 id 是否有一揽子协议
select pv.VENDOR_NAME,pv.VENDOR_ID,pha.SEGMENT1,pha.PO_HEADER_ID,pla.ITEM_ID,pla.ITEM_DESCRIPTION,pla.QUANTITY,pla.UNIT_PRICE,pla.ATTRIBUTE10
from PO.PO_HEADERS_ALL pha,PO.PO_LINES_ALL  pla ,PO_VENDORS pv
where pla.PO_HEADER_ID=pha.PO_HEADER_ID
and pha.TYPE_LOOKUP_CODE='BLANKET'
and pv.VENDOR_ID=pha.VENDOR_ID
and pla.ITEM_DESCRIPTION like '%疏散%'
and pla.ITEM_ID=75079;



--查询物料编码是否有一揽子协议
select pv.VENDOR_NAME,pv.VENDOR_ID,pha.SEGMENT1,pha.PO_HEADER_ID,pla.ITEM_ID,msib.segment1,pla.ITEM_DESCRIPTION,pla.QUANTITY,pla.UNIT_PRICE,pla.ATTRIBUTE10,pla.ATTRIBUTE11
from PO.PO_HEADERS_ALL pha,PO.PO_LINES_ALL  pla ,PO_VENDORS pv,mtl_system_items_b msib 
where pla.PO_HEADER_ID=pha.PO_HEADER_ID
and pha.TYPE_LOOKUP_CODE='BLANKET'
and  msib.inventory_item_id = pla.ITEM_ID
and msib.ORGANIZATION_ID=460
and pv.VENDOR_ID=pha.VENDOR_ID
and msib.segment1='3002010040000001'
;


---查询一揽子的内容
select pv.VENDOR_NAME,pv.VENDOR_ID,pha.SEGMENT1,pha.PO_HEADER_ID,pla.ITEM_ID,msib.segment1,pla.ITEM_DESCRIPTION,pla.QUANTITY,pla.UNIT_PRICE,pla.ATTRIBUTE10,pla.ATTRIBUTE11
from PO.PO_HEADERS_ALL pha,PO.PO_LINES_ALL  pla ,PO_VENDORS pv,mtl_system_items_b msib 
where pla.PO_HEADER_ID=pha.PO_HEADER_ID
and pha.TYPE_LOOKUP_CODE='BLANKET'
and  msib.inventory_item_id = pla.ITEM_ID
and msib.ORGANIZATION_ID=460
and pv.VENDOR_ID=pha.VENDOR_ID
and pha.segment1='2016000106'
;