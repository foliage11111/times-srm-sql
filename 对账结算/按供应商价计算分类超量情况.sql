select usemoney.*,planmoney.*,usemoney.实际金额-planmoney.规划金额 超额
 
  from (
select used.category_code ,sum(used.cha) 实际金额
--select sum(used.cha) *1.265
from (
 SELECT wctt.*,cpp.*,itemcate.category_code,(CASE
                 WHEN cpp.plan_quantity > wctt.sumq THEN
                  trunc(cpp.plan_price 
                       ,4) * (cpp.plan_quantity - wctt.sumq)
                 ELSE
                  0
               END) cha
      
      FROM (SELECT wc.fconid
                  ,t.inventory_item_id
                  ,SUM(nvl(wbt.fquantity
                          ,0)) sumq
              FROM wpc_contract_t wc
                  ,(SELECT a.fbomlistid
                          ,a.fbomid
                          ,a.fquantity
                          ,b.inventory_item_id
                      FROM wpc_bomlist_t  a
                          ,wbd_material_t b
                     WHERE a.fprdid = b.fprdid
                       AND a.ftype = '0') t
                  ,wpc.wpc_bomorderlist_t wbt
             WHERE (wc.fbomid = t.fbomid OR EXISTS
                    (SELECT wcct.fconid
                           ,wcct.fbomid
                       FROM wpc.wpc_changevisa_t wct
                           ,wpc_changecontract_t wcct
                      WHERE wcct.fcvid = wct.fcvid
                        AND wct.fchangetype IN ('10'
                                               ,'20')
                        AND wct.fwflowstate = '20'
                        AND wcct.fconid = wc.fconid
                        AND wcct.fbomid = t.fbomid) OR EXISTS
                    (SELECT 1
                       FROM wpc.wpc_contract_t wc1
                      WHERE wc1.fmainconid = wc.fconid
                        AND wc1.fwflowstate = '20'
                        AND wc1.fbomid = t.fbomid))
               AND t.fbomid = wbt.fbomid(+)
               AND t.fbomlistid = wbt.fbomlistid(+)
               AND nvl(wc.fcontractproperty
                      ,'1') <> '2'
             GROUP BY wc.fconid
                     ,t.inventory_item_id) wctt
          ,(SELECT cph.contract_id
                  ,cpl.item_id
                  ,SUM(cpl.quantity) plan_quantity
                  ,MAX(cpl.unit_price) plan_price
              FROM cux_pr_plan_lines   cpl
                  ,cux_pr_plan_headers cph
             WHERE 1 = 1
               AND cpl.header_id = cph.header_id
               AND cph.last_update_date =
                   (SELECT MAX(cphh.last_update_date)
                      FROM cux_pr_plan_headers cphh
                     WHERE cphh.plan_number = cph.plan_number
                       AND cphh.plan_status IN
                           ('APPROVING'
                           ,'APPROVED'
                           ,'ORDERED'))
             GROUP BY cph.contract_id
                     ,cpl.item_id) cpp
                     ,(SELECT mtl.category_id,
       mtl.description              cate_desc,
       mtl.concatenated_segments,
       mtl.segment1,
       mtl.segment2,
       mtl.segment3,
       mtl.segment4,
       msib.inventory_item_id,
       msib.segment1                item_num,
       msib.description             item_desc,
       msib.long_description,
       msib.primary_uom_code,
       msib.primary_unit_of_measure unit_name,
       mtl.category_code
  FROM mtl_item_categories t,
       mtl_system_items_vl msib,
       (SELECT mc.category_id,
               mc.segment1,
               mc.segment2,
               mc.segment3,
               mc.segment4,
               fnd_flex_ext.get_segs('INV',
                                     'MCAT',
                                     mc.structure_id,
                                     mc.category_id) concatenated_segments,
               mc.description,
               mc.segment1 || '.' || mc.segment2 || '.' || mc.segment3 category_code
          FROM mtl_categories mc
         WHERE mc.structure_id = 101
           AND (mc.disable_date IS NULL OR mc.disable_date >= SYSDATE)
           AND mc.enabled_flag = 'Y') mtl
 WHERE t.inventory_item_id = msib.inventory_item_id
   AND t.organization_id = msib.organization_id
   AND t.category_id = mtl.category_id  
   AND msib.organization_id = 460
   AND t.category_set_id = 1
   AND msib.inventory_item_status_code <> 'Inactive')itemcate
     WHERE cpp.contract_id(+) = wctt.fconid
       AND cpp.item_id(+) = wctt.inventory_item_id
       and itemcate.inventory_item_id(+)=wctt.inventory_item_id
       AND wctt.fconid = 179104
    ) used
    where used.category_code is not null
        group by used.category_code
        ) usemoney,
        
        (      SELECT wc.fconid
                  ,t.fnumber
                   ,SUM(nvl(wbt.fquantity
                          ,0)) 规划金额
              FROM wpc_contract_t wc
                  ,( SELECT a.fbomlistid
                          ,a.fbomid
                          ,a.fquantity
                          ,b.fnumber
                          ,b.fname
                          ,b.segment1
                          ,b.segment2
                          ,b.segment3
                          ,b.segment4
                      
                      FROM wpc_bomlist_t  a
                          ,wbd_material_t b
                     WHERE a.fprdid = b.fprdid
                       AND a.ftype = '2') t
                  ,wpc.wpc_bomorderlist_t wbt
             WHERE (wc.fbomid = t.fbomid OR EXISTS
                    (SELECT wcct.fconid
                           ,wcct.fbomid
                       FROM wpc.wpc_changevisa_t wct
                           ,wpc_changecontract_t wcct
                      WHERE wcct.fcvid = wct.fcvid
                        AND wct.fchangetype IN ('10'
                                               ,'20')
                        AND wct.fwflowstate = '20'
                        AND wcct.fconid = wc.fconid
                        AND wcct.fbomid = t.fbomid) OR EXISTS
                    (SELECT 1
                       FROM wpc.wpc_contract_t wc1
                      WHERE wc1.fmainconid = wc.fconid
                        AND wc1.fwflowstate = '20'
                        AND wc1.fbomid = t.fbomid))
               AND t.fbomid = wbt.fbomid(+)
               AND t.fbomlistid = wbt.fbomlistid(+)
               AND nvl(wc.fcontractproperty
                      ,'1') <> '2'
                     and wc.fconid = 179104
             GROUP BY wc.fconid
                     ,t.fnumber
                     )planmoney
                     where usemoney.category_code=planmoney.fnumber(+)
          ;
