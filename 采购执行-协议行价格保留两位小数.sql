declare
  cursor csr_po is
    select round(pol.unit_price, 2) unit_price, pol.po_line_id
      from po_lines_all pol
     where 1 = 1
       and pol.po_header_id = (select poh.po_header_id
                                 from po_headers_all poh
                                where poh.po_header_id = pol.po_header_id
                                  and poh.segment1 = '2017010601');
begin
  for rec_po in csr_po loop
    update po_lines_all pol
       set pol.unit_price = rec_po.unit_price
     where pol.po_line_id = rec_po.po_line_id;
    commit;
  
  end loop;

end;
