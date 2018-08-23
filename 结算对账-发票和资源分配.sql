select * from ap_invoices_interface t where t.invoice_num = '04276687';
select * from ap_invoice_lines_interface t where t.invoice_id = 302899;
select *
  from ap_interface_rejections t
 where t.creation_date > sysdate - 2;

select t.enabled_flag, t.start_date_active, t.end_date_active, t.*
  from gl_code_combinations t
 where t.code_combination_id in (331600, 188589);

cux_org_po_pkg;

select *
  from Cux.Cux_Pr_Blanket_t t
 where t.vendor_id =
   and t.vendor_site_id =
   and t.inventory_item_id =
   and t.FREGION =
   and t.BLOCK_DIVISION =
   and t.po_header_id =11021
   and t.po_line_id =
