declare
  --行数据
  cursor csr_lines is
    select pla.po_line_id,
           pla.item_id,
           pla.unit_meas_lookup_code,
           pla.unit_price
      from po_lines_all pla
     where 1 = 1
       and pla.po_header_id =
           (select poh.po_header_id
              from po_headers_all poh
             where poh.segment1 = '2016000418');
  l_org_id         NUMBER;
  l_vendor_id      NUMBER;
  l_vendor_site_id NUMBER;
  l_agent_id       NUMBER;
  l_person_id      NUMBER;

  l_item_id NUMBER;

  l_iface_rec        po.po_headers_interface%ROWTYPE;
  l_iface_lines_rec  po.po_lines_interface%ROWTYPE;
  l_line_number      NUMBER;
  v_request_id       NUMBER;
  l_return_msg       varchar2(240);
  l_Primary_Uom_Code varchar2(240);
  v_count            number;
  l_po_count         NUMBER;
  l_description      varchar2(240);
  l_count            NUMBER;
begin

  for rec_lines in csr_lines loop
    --获取物料长描述
    begin
      select msib.LONG_DESCRIPTION
        into l_description
        from mtl_system_items_fvl msib
       where msib.inventory_item_id = rec_lines.item_id
         and rownum = 1;
    exception
      when others then
        l_description := null;
    end;
  
    update po_lines_all pol
       set pol.item_description = l_description
     where pol.po_line_id = rec_lines.po_line_id;
    commit;
  end loop;

END;
