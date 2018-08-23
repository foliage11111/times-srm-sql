select pol.unit_price from po_lines_all pol
 WHERE 1 = 1
 AND EXISTS (SELECT 1
          from po_headers_all poh
         WHERE poh.po_header_id=pol.po_header_id
           AND poh.segment1='')
   and exists(select 1 from mtl_system_items_b msib where
              msib.inventory_item_id = pol.item_id
          and msib.segment1 = '')
   for update 
