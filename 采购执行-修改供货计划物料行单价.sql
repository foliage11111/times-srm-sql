select cppl.ITEM_ID,msib.SEGMENT1,cppl.UNIT_PRICE,cppl.PLAN_QUANTITY,cpph.PLAN_NUMBER,cpph.CONTRACT_ID ,
cppl.AG_HEADER_ID,cppl.AG_LINE_ID
from cux_pr_plan_headers cpph,CUX.CUX_PR_PLAN_LINES cppl,mtl_system_items_b msib 
where cpph.HEADER_ID=cppl.HEADER_ID and  msib.inventory_item_id = cppl.item_id 
and msib.ORGANIZATION_ID=460
and cpph.PLAN_NUMBER='S201706028';




SELECT cpl.unit_price,
       cpl.l_contract_num,
       cpl.l_vendor_id,
       cpl.l_vendor_name
  FROM cux_pr_plan_lines cpl
 WHERE 1 = 1
   AND EXISTS (SELECT 1
          from cux_pr_plan_headers cpr
         WHERE cpr.header_id = cpl.header_id
           AND cpr.plan_number = 'S201706028')
   and exists (select 1
          from mtl_system_items_b msib
         where msib.inventory_item_id = cpl.item_id
           and msib.segment1 = '3010020010000015')
      ;
   

 

select cpph.* from cux_pr_plan_headers cpph where cpph.PLAN_NUMBER='S201703128' ;
select * from   cux_pr_plan_headers cpph where cpph.CONTRACT_ID=186945  ;
select * from   cux_pr_plan_headers cpph where cpph.HEADER_ID=6727  ;


select * from  CUX.CUX_PR_PLAN_LINES cppl where cppl.L_CONTRACT_NUM=2017000072 ;

--update cux_pr_plan_headers cpph set cpph.PLAN_NUMBER='S201704172' where cpph.HEADER_ID=6758;


select pla.ATTRIBUTE5,pla.* from PO.PO_LINES_ALL pla
where  pla.ATTRIBUTE5 is not null 
and pla.CREATION_DATE > to_date('2017-03-20','yyyy-mm-dd')  
and pla.ATTRIBUTE5 not in (select cppl.LINE_ID from  CUX.CUX_PR_PLAN_LINES cppl)
;

select * from cux_pr_plan_headers cpph where cpph.PLAN_STATUS='ORDERED'   and cpph.HEADER_ID not in (select cppl.header_id from CUX.CUX_PR_PLAN_LINES cppl)  ;


select * from po_headers_all pha where pha.segment1 in ('2016000049','2017000151');
select * from po_headers_all pha where pha.PO_HEADER_ID in (21026,21027);

select * from po_lines_all pla where pla.PO_HEADER_ID in (21026,21027);

select * from po_lines_all pla where pla.PO_LINE_ID in (53289,53286,53285,48650);--ATTRIBUTE9

select cpph.SPOT_PRICES,cpph.SPOT_PRICES_DATE,cpph.* from cux_pr_plan_headers cpph  order by cpph.PLAN_NUMBER desc;

select cpph.SPOT_PRICES,cpph.SPOT_PRICES_DATE,cpph.* from cux_pr_plan_headers cpph where cpph.CONTRACT_ID=183641 order by cpph.PLAN_NUMBER desc;

--铜价为空的REQUIRES_REAPPROVAL
select cpph.SPOT_PRICES,cpph.SPOT_PRICES_DATE,cpph.* from cux_pr_plan_headers cpph where cpph.SPOT_PRICES_DATE is not null;
--更新铜价
update cux_pr_plan_headers cpph set cpph.SPOT_PRICES=47430,cpph.SPOT_PRICES_DATE=to_date('17-04-01','yyyy-mm-dd');