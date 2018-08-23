-- 

select pha.approved_flag flag,pha.authorization_status status,pha.start_date,pha.end_date end_d,decode(sign(sysdate - pha.end_date),1,'',-1,''),pla.expiration_date,pv.VENDOR_NAME,pv.VENDOR_ID,pha.SEGMENT1,pha.PO_HEADER_ID,pla.ITEM_ID,msib.segment1,msib.inventory_item_status_code,pla.unit_meas_lookup_code unit,pla.ITEM_DESCRIPTION,pla.QUANTITY,pla.UNIT_PRICE,pla.ATTRIBUTE10,pla.ATTRIBUTE11
from PO.PO_HEADERS_ALL pha,PO.PO_LINES_ALL  pla ,PO_VENDORS pv,mtl_system_items_b msib 
where pla.PO_HEADER_ID=pha.PO_HEADER_ID
and pha.TYPE_LOOKUP_CODE='BLANKET'
and  msib.inventory_item_id = pla.ITEM_ID
and msib.ORGANIZATION_ID=460
and pv.VENDOR_ID=pha.VENDOR_ID
--and msib.segment1='3009020030000002'
and pha.SEGMENT1='2016000379'
--and pla.item_description like '%%'
--and pv.VENDOR_NAME like '%%%'
;

-- unit_price 

select cpph.plan_number,cpph.org_id,hou.name,cpph.version_num,cpph.plan_status,cpph.plan_type,cpph.plan_name
,cpph.last_update_date,cpph.operator_id,fu.user_name,pha.last_update_date,pha.SEGMENT1,pha.authorization_status
,pha.cancel_flag,cppl.ag_header_id ,pha2.segment1 ,cppl.ag_line_id,pla.attribute9,pv.VENDOR_NAME,pv.VENDOR_ID
,pha.PO_HEADER_ID,pla.ITEM_ID,msib.segment1,pla.ITEM_DESCRIPTION,cppl.quantity ,cppl.unit_price ,pla.QUANTITY 
,pla.UNIT_PRICE , pla.ATTRIBUTE11 
from PO.PO_HEADERS_ALL pha,PO.PO_LINES_ALL  pla,fnd_user fu ,PO_VENDORS pv,apps.mtl_system_items_b msib ,
cux.cux_pr_plan_headers cpph,cux.CUX_PR_PLAN_LINES cppl,PO.PO_HEADERS_ALL pha2,hr_organization_units hou
where pla.PO_HEADER_ID=pha.PO_HEADER_ID and  cpph.HEADER_ID=cppl.HEADER_ID and pla.attribute5=cppl.line_id
and pha.TYPE_LOOKUP_CODE='STANDARD'
and pha2.po_header_id=cppl.ag_header_id
and  msib.inventory_item_id = pla.ITEM_ID
and cpph.operator_id=fu.user_id(+)
and cpph.org_id=hou.organization_id(+)
and msib.ORGANIZATION_ID=460
and pv.VENDOR_ID=pha.VENDOR_ID
and msib.segment1='3010020070000022'
--and pha.SEGMENT1='3019120010000002' --PO
--and pha2.segment1='2017000893'      ----bpa
--and cpph.plan_number='S201710246'
--and pla.item_description like '%%'
--and cpph.org_id=2153
 ;
 
 ---sql
select cpph.plan_number,
       cpph.plan_name,
       cpph.plan_status,
       cppl.item_id,
       cppl.quantity,
       cppl.unit_price     tax_price,
       cppl.description,
       po.unit_price       untax_price,
       po.item_description,
       po.segment1
  from CUX_PR_PLAN_HEADERS cpph,
       cux_pr_plan_lines cppl,
       (select pla.item_id,
               pla.quantity,
               pla.unit_price,
               pla.item_description,
               pha.segment1
          from po.po_lines_all pla, po.po_headers_all pha
         where pla.po_header_id = pha.po_header_id
           and pha.segment1 = '2017000846'
          ) po
 where cpph.header_id = cppl.header_id
   and cppl.item_id (+)= po.item_id
   and cppl.quantity (+)= po.quantity
