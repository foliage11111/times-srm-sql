select count(1) from (select rsh.receipt_num receipt_num, --????  
       (select cpr.delivery_number
          from cux_po_receive_headers cpr
         where cpr.receipt_num = rt.attribute1
           and rownum = 1) delivery_number,
       rsh.shipment_header_id shipment_header_id,
       rsl.shipment_line_id shipment_line_id,
       rsl.line_num as line_num, --??  
       (case
         when rt.attribute2 is not null then
          to_char(to_date(rt.attribute2, 'yyyy-MM-dd hh24:mi:ss'),
                  'yyyy-MM-dd')
         else
          to_char(rt.transaction_date, 'yyyy-MM-dd')
       end) receiveDate, --????  
       (select msib.segment1
          from mtl_system_items_b msib
         where msib.inventory_item_id = pol.item_id
           and rownum = 1) item_code, --????  
       (select msib.LONG_DESCRIPTION
          from MTL_SYSTEM_ITEMS_FVL msib
         where msib.inventory_item_id = pol.item_id
           and rownum = 1) item_description, --????  
       pol.unit_meas_lookup_code unit_meas_lookup_code, --??  
       pol.quantity order_quantity, --????  
       rsl.quantity_received receive_quantity, --????  
       round(pol.unit_price, 2) unit_price, --???????20180529?????????????????2?  
       round(pol.attribute11, 2) unit_tax_price, --??????20180529?????????????????2?  
       cit.tax_classification_code tax_code, --??  
       round((rsl.quantity_received * round(nvl(pol.attribute11,
                                      pol.unit_price * (1 +
                                      (regexp_substr(cit.tax_classification_code,
                                                                       '[0-9]+') / 100))),
                                  4)) /
             (1 +
             (regexp_substr(cit.tax_classification_code, '[0-9]+') / 100)),
             2) receive_amount, --????(???)20180529?????????2???   
       pol.attribute6 attribute6,
       round((rsl.quantity_received * round(nvl(pol.attribute11,
                                      pol.unit_price * (1 +
                                      (regexp_substr(cit.tax_classification_code,
                                                                       '[0-9]+') / 100))),
                                  4)),
             2) receive_tax_amount, --????(??)20180529?????????2???  
       poh.segment1 order_number, --??????  
       (select poh2.segment1
          from po_headers_all poh2
         where poh2.po_header_id =
               (select pol2.po_header_id
                  from po_lines_all pol2
                 where 1 = 1
                   and pol2.po_line_id = pol.attribute9)) contract_num, --????   
       --pol.contract_num, --????   
       wc.project_name project_name, --????  
       wc.project_block_name project_block_name, --????  
       wc.contract_name contract_name --????  
      ,(regexp_substr(cit.tax_classification_code, '[0-9]+') / 100) tax_rate
  from rcv_shipment_headers rsh,
       rcv_shipment_lines rsl,
       rcv_transactions rt,
       po_headers_all poh,
       po_lines_all pol,
       (SELECT pla.po_header_id,
               pla.attribute1 project_id,
               wpt.fname project_name,
               pla.attribute2 project_block_id,
               wpb.fname project_block_name,
               pla.attribute3 contract_id,
               wct.fname contract_name,
               row_number() over(PARTITION BY pla.po_header_id ORDER BY pla.po_header_id, pla.attribute3 NULLS LAST) row_num,
               wpt.faddress,
               pla.po_line_id,
               wct.fsecondparty
          FROM po_lines_all pla,
               wbd.wbd_project_t wpt,
               (SELECT wpbt.fpbno, wpbt.fname
                  FROM wbd.wbd_project_t wpt, wbd_projectblock_t wpbt
                 WHERE wpt.fiseffective = '1'
                   AND wpt.fprjid = wpbt.fprjid) wpb,
               wpc.wpc_contract_t wct
         WHERE wpt.fiseffective(+) = '1'
           AND wpt.fprjno(+) = pla.attribute1
           AND wpb.fpbno(+) = pla.attribute2
           AND wct.fconid(+) = pla.attribute3
           AND nvl(pla.closed_code, 'OPEN') = 'OPEN'
           AND nvl(pla.cancel_flag, 'N') = 'N') wc,
       ZX_ID_TCC_MAPPING_ALL cit
 where 1 = 1
   and rsh.shipment_header_id = rsl.shipment_header_id
   and rt.shipment_header_id = rsh.shipment_header_id
   and rt.shipment_line_id = rsl.shipment_line_id
   and rt.transaction_type = 'RECEIVE'
   and poh.po_header_id = pol.po_header_id
   and rt.po_header_id = poh.po_header_id
   and rt.po_line_id = pol.po_line_id
   AND wc.po_header_id(+) = poh.po_header_id
   AND wc.row_num(+) = 1
   and cit.tax_rate_code_id(+) = pol.attribute6
   and rt.attribute2 is not null
      --??????? 
   and not exists
 (select 1
          from CUX_CHECK_ACCOUNT_LINE_TEMP   ccal,
               cux_check_vendor_account_temp ccv
         where 1 = 1
           and ccal.receipt_id = rsh.shipment_header_id
           and ccal.receipt_line_id = rsl.shipment_line_id
           and ccal.vendor_account_id = ccv.vendor_account_id
           and ccv.vendor_account_id <> ?
        --and ccv.approve_code='APPROVED' 
        )
 and poh.vendor_id=? and poh.org_id=? order by rt.attribute2 asc, rsh.receipt_num asc, rsl.line_num asc ) 
 ;


select * from ( select rsh.receipt_num receipt_num, --????  
       (select cpr.delivery_number
          from cux_po_receive_headers cpr
         where cpr.receipt_num = rt.attribute1
           and rownum = 1) delivery_number,
       rsh.shipment_header_id shipment_header_id,
       rsl.shipment_line_id shipment_line_id,
       rsl.line_num as line_num, --??  
       (case
         when rt.attribute2 is not null then
          to_char(to_date(rt.attribute2, 'yyyy-MM-dd hh24:mi:ss'),
                  'yyyy-MM-dd')
         else
          to_char(rt.transaction_date, 'yyyy-MM-dd')
       end) receiveDate, --????  
       (select msib.segment1
          from mtl_system_items_b msib
         where msib.inventory_item_id = pol.item_id
           and rownum = 1) item_code, --????  
       (select msib.LONG_DESCRIPTION
          from MTL_SYSTEM_ITEMS_FVL msib
         where msib.inventory_item_id = pol.item_id
           and rownum = 1) item_description, --????  
       pol.unit_meas_lookup_code unit_meas_lookup_code, --??  
       pol.quantity order_quantity, --????  
       rsl.quantity_received receive_quantity, --????  
       round(pol.unit_price, 2) unit_price, --???????20180529?????????????????2?  
       round(pol.attribute11, 2) unit_tax_price, --??????20180529?????????????????2?  
       cit.tax_classification_code tax_code, --??  
       round((rsl.quantity_received * round(nvl(pol.attribute11,
                                      pol.unit_price * (1 +
                                      (regexp_substr(cit.tax_classification_code,
                                                                       '[0-9]+') / 100))),
                                  4)) /
             (1 +
             (regexp_substr(cit.tax_classification_code, '[0-9]+') / 100)),
             2) receive_amount, --????(???)20180529?????????2???   
       pol.attribute6 attribute6,
       round((rsl.quantity_received * round(nvl(pol.attribute11,
                                      pol.unit_price * (1 +
                                      (regexp_substr(cit.tax_classification_code,
                                                                       '[0-9]+') / 100))),
                                  4)),
             2) receive_tax_amount, --????(??)20180529?????????2???  
       poh.segment1 order_number, --??????  
       (select poh2.segment1
          from po_headers_all poh2
         where poh2.po_header_id =
               (select pol2.po_header_id
                  from po_lines_all pol2
                 where 1 = 1
                   and pol2.po_line_id = pol.attribute9)) contract_num, --????   
       --pol.contract_num, --????   
       wc.project_name project_name, --????  
       wc.project_block_name project_block_name, --????  
       wc.contract_name contract_name --????  
      ,(regexp_substr(cit.tax_classification_code, '[0-9]+') / 100) tax_rate
  from rcv_shipment_headers rsh,
       rcv_shipment_lines rsl,
       rcv_transactions rt,
       po_headers_all poh,
       po_lines_all pol,
       (SELECT pla.po_header_id,
               pla.attribute1 project_id,
               wpt.fname project_name,
               pla.attribute2 project_block_id,
               wpb.fname project_block_name,
               pla.attribute3 contract_id,
               wct.fname contract_name,
               row_number() over(PARTITION BY pla.po_header_id ORDER BY pla.po_header_id, pla.attribute3 NULLS LAST) row_num,
               wpt.faddress,
               pla.po_line_id,
               wct.fsecondparty
          FROM po_lines_all pla,
               wbd.wbd_project_t wpt,
               (SELECT wpbt.fpbno, wpbt.fname
                  FROM wbd.wbd_project_t wpt, wbd_projectblock_t wpbt
                 WHERE wpt.fiseffective = '1'
                   AND wpt.fprjid = wpbt.fprjid) wpb,
               wpc.wpc_contract_t wct
         WHERE wpt.fiseffective(+) = '1'
           AND wpt.fprjno(+) = pla.attribute1
           AND wpb.fpbno(+) = pla.attribute2
           AND wct.fconid(+) = pla.attribute3
           AND nvl(pla.closed_code, 'OPEN') = 'OPEN'
           AND nvl(pla.cancel_flag, 'N') = 'N') wc,
       ZX_ID_TCC_MAPPING_ALL cit
 where 1 = 1
   and rsh.shipment_header_id = rsl.shipment_header_id
   and rt.shipment_header_id = rsh.shipment_header_id
   and rt.shipment_line_id = rsl.shipment_line_id
   and rt.transaction_type = 'RECEIVE'
   and poh.po_header_id = pol.po_header_id
   and rt.po_header_id = poh.po_header_id
   and rt.po_line_id = pol.po_line_id
   AND wc.po_header_id(+) = poh.po_header_id
   AND wc.row_num(+) = 1
   and cit.tax_rate_code_id(+) = pol.attribute6
   and rt.attribute2 is not null
      --??????? 
   and not exists
 (select 1
          from CUX_CHECK_ACCOUNT_LINE_TEMP   ccal,
               cux_check_vendor_account_temp ccv
         where 1 = 1
           and ccal.receipt_id = rsh.shipment_header_id
           and ccal.receipt_line_id = rsl.shipment_line_id
           and ccal.vendor_account_id = ccv.vendor_account_id
        --   and ccv.vendor_account_id <> ?
        --and ccv.approve_code='APPROVED' 
        )
 and poh.vendor_id=5342
 -- and poh.org_id=?
  order by rt.attribute2 asc, rsh.receipt_num asc, rsl.line_num asc ) where rownum <= 30
 
 ;
 
 select * from ap_vendors_v av where av.vendor_number='107825'
