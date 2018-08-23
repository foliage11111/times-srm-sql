SELECT cpl.unit_price,
       cpl.l_contract_num,
       cpl.l_vendor_id,
       cpl.l_vendor_name
  FROM cux_pr_plan_lines cpl
 WHERE 1 = 1
   AND EXISTS (SELECT 1
          from cux_pr_plan_headers cpr
         WHERE cpr.header_id = cpl.header_id
           AND cpr.plan_number = 'S201704009')
   and exists (select 1
          from mtl_system_items_b msib
         where msib.inventory_item_id = cpl.item_id
           and msib.segment1 = '3401010010000001')
   for update
