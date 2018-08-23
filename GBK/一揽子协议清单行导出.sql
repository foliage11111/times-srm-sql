select (select msib.segment1
          from mtl_system_items_fvl msib
         where 1 = 1
           and msib.inventory_item_id = pol.item_id
           and rownum = 1) ���ϱ���,
       (select msib.LONG_DESCRIPTION
          from mtl_system_items_fvl msib
         where 1 = 1
           and msib.inventory_item_id = pol.item_id
           and rownum = 1) ����,
       pol.unit_meas_lookup_code ��λ,
       pol.unit_price ����,
       pol.attribute10 ����
  from po_lines_all pol, po_headers_all poh
 where 1 = 1
   and pol.po_header_id = poh.po_header_id
   and pol.po_header_id =
       (select poh.po_header_id
          from po_headers_all poh
         where poh.segment1 = '2016000046')
 order by pol.line_num desc
