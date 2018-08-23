select * from cux_pr_plan_headers cpph where cpph.header_id =6727;


select * from cux_pr_plan_lines cppl where cppl.ag_header_id=36049;

select (select msib.segment1
          from mtl_system_items_fvl msib
         where 1 = 1
           and msib.inventory_item_id = pol.item_id
           and rownum = 1) 物料编码,
       (select msib.LONG_DESCRIPTION
          from mtl_system_items_fvl msib
         where 1 = 1
           and msib.inventory_item_id = pol.item_id
           and rownum = 1) 描述,
       pol.unit_meas_lookup_code 单位,
       pol.unit_price 单价,
       pol.attribute10 区域
  from po_lines_all pol, po_headers_all poh
 where 1 = 1
   and pol.po_header_id = poh.po_header_id
   and pol.po_header_id =
       (select poh.po_header_id
          from po_headers_all poh
         where poh.segment1 = '2016000117')
 order by pol.line_num desc



select qur1.unit_price as bpa_price
,qur2.unrated_price as po_price
,qur2.rated17_price as po_price_rated
,qur2.rated_price as pr_price_rated
,qur1.po_line_id  
,qur2.ag_line_id
,qur1.po_header_id
,qur2.ag_header_id
,qur1.segment1
,qur1.*, qur2.*
  from (select pha2.po_header_id,
               pha2.segment1,
               pla2.po_line_id,
               pla2.unit_price,
               pla2.item_id
          from po_headers_all pha2, po_lines_all pla2
         where pha2.po_header_id = pla2.po_header_id
           and pha2.type_lookup_code='BLANKET') qur1,--->bpa
       
       (select pha.segment1,
               pha.po_header_id,
               pha.vendor_id,
               pha.type_lookup_code,
               pla.po_line_id,
               pla.item_id poitem,
               pla.quantity,
               pla.attribute2,
               pla.attribute5,
               pla.attribute9,
               pla.unit_price unrated_price,
               pla.unit_price * 1.17 rated17_price,
               cpph.plan_number,
               cpph.plan_name,
               
               cppl.item_id,
               cppl.line_id,
               
               cppl.header_id,
               cppl.rate_id,
               cppl.unit_price     rated_price,
               cppl.plan_quantity,
               cppl.ag_header_id,
               cppl.ag_line_id,
               cppl.l_contract_num,
               
               cppl.l_vendor_name
          from po_headers_all      pha,
               po_lines_all        pla,
               cux_pr_plan_lines   cppl,
               cux_pr_plan_headers cpph
         where pla.attribute5 = cppl.line_id
           and pha.po_header_id = pla.po_header_id
           and cppl.header_id = cpph.header_id
           and pha.segment1 = '2017000168') qur2 --->po
 where qur2.attribute9=qur1.po_line_id
   ;
   

select pla.po_header_id,
        pla.po_line_id,
       pla.item_id poitem,
       pla.quantity,
       pla.attribute2,--- 月度计划头id
       pla.attribute5,--- 月度计划行id
       pla.attribute9 --- 协议行id
       from po_lines_all pla where pla.po_header_id=22023;


--- qur1 qur2 
--
select qur1.*, qur2.*
  from (select pha2.po_header_id,
               pha2.segment1,
               pla2.po_line_id,
               pla2.unit_price,
               pla2.item_id
          from po_headers_all pha2, po_lines_all pla2
         where pha2.po_header_id = pla2.po_header_id
           and pha2.segment1 = '2016000084') qur1, ---
       
       (select pha.segment1,
               pha.po_header_id,
               pha.vendor_id,
               pha.type_lookup_code,
               pla.po_line_id,
               pla.item_id poitem,
               pla.quantity,
               pla.attribute2,
               pla.attribute5,
               pla.attribute9,
               pla.unit_price unrated_price,
               pla.unit_price * 1.17 rated17_price,
               cpph.plan_number,
               cpph.plan_name,
               
               cppl.item_id,
               cppl.line_id,
               
               cppl.header_id,
               cppl.rate_id,
               cppl.unit_price     rated_price,
               cppl.plan_quantity,
               cppl.ag_header_id,
               cppl.ag_line_id,
               cppl.l_contract_num,
               
               cppl.l_vendor_name
          from po_headers_all      pha,
               po_lines_all        pla,
               cux_pr_plan_lines   cppl,
               cux_pr_plan_headers cpph
         where pla.attribute5 = cppl.line_id
           and pha.po_header_id = pla.po_header_id
           and cppl.header_id = cpph.header_id
           and pha.segment1 = '2016000059') qur2 ----
 where qur1.item_id(+) = qur2.poitem
   ;
   
   


select * from hr_operating_units t where t.organization_id = 2473;


select * from cux_po_headers_v’ car where car.agreement_header_id=36049




select 'update po_lines_all pla set pla.attribute9='||qur1.target_bpa_line_id||' where pla.po_line_id='||qur2.po_line_id ||' ;',
'update cux_pr_plan_lines cppl set cppl.ag_header_id='||qur1.bpa_header_id||' ,cppl.ag_line_id='|| qur1.target_bpa_line_id||' ,cppl.l_contract_num=''' || qur1.target_pba_code||''' '||' where cppl.line_id='||qur2.line_id||' ;',
qur1.*, qur2.*
  from (select pha2.po_header_id bpa_header_id,
               pha2.segment1 target_pba_code,
               pha2.type_lookup_code,
               pla2.po_line_id target_bpa_line_id,
               pla2.unit_price target_bpa_unit_price,
               pla2.item_id
              
          from po_headers_all pha2, po_lines_all pla2
         where pha2.po_header_id = pla2.po_header_id
           and pha2.segment1 ='2016000084') qur1,
       
       (select pha.segment1 po_segement1,
               pha.po_header_id,
               pha.vendor_id,
               pha.type_lookup_code,
               pla.po_line_id  po_line_id,
               pla.item_id poitem,
               pla.quantity,
               pla.attribute2,
               pla.attribute5,
               pla.attribute9 source_bpa_line_id,
               pla.unit_price unrated_price,
               pla.unit_price * 1.17 source_rated17_price,
               cpph.plan_number,
               cpph.plan_name,
               cppl.item_id,
               cppl.line_id,
               cppl.header_id,
               cppl.rate_id,
               cppl.unit_price     rated_price,
               cppl.plan_quantity,
               cppl.ag_header_id,
               cppl.ag_line_id,
               cppl.l_contract_num,
               cppl.l_vendor_name
               
          from po_headers_all      pha,
               po_lines_all        pla,
               cux_pr_plan_lines   cppl,
               cux_pr_plan_headers cpph
         where pla.attribute5 = cppl.line_id
           and pha.po_header_id = pla.po_header_id
           and cppl.header_id = cpph.header_id
           and pha.segment1 = '2016000059') qur2
 where qur1.item_id(+) = qur2.poitem
   ;
