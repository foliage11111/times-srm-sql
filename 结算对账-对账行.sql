SELECT rsh.receipt_num receipt_num
      , --接收单号    
       rsh.shipment_header_id shipment_header_id
      ,rsl.shipment_line_id shipment_line_id
      ,rsl.line_num line_num
      , --行号    
       to_char(rt.transaction_date, 'yyyy-MM-dd') receivedate
      , --接收日期    
       (SELECT msib.segment1
        FROM   mtl_system_items_b msib
        WHERE  msib.inventory_item_id = pol.item_id
        AND    rownum = 1) item_code
      , --物料编码    
       (SELECT msib.description
        FROM   mtl_system_items_b msib
        WHERE  msib.inventory_item_id = pol.item_id
        AND    rownum = 1) item_description
      , --物料描述    
       pol.unit_meas_lookup_code unit_meas_lookup_code
      , --单位    
       pol.quantity order_quantity
      , --订购数量    
       rt.quantity receive_quantity
      , --接收数量    
       pol.unit_price unit_price
      , --单价    
       cit.tax_classification_code tax_code
      , --税率    
       round(rt.quantity * pol.unit_price, 2) receive_amount
      , --接收金额(不含税)     
       pol.attribute6 attribute6
      ,round((rt.quantity * pol.unit_price +
             rt.quantity * pol.unit_price *
             (regexp_substr(cit.tax_classification_code, '[0-9]+') / 100)),
             2) receive_tax_amount
      , --接收金额(含税)    
       poh.segment1 order_number
      , --采购订单编号    
       (SELECT poh2.segment1
        FROM   po_headers_all poh2
        WHERE  poh2.po_header_id =
               (SELECT pol2.po_header_id
                FROM   po_lines_all pol2
                WHERE  1 = 1
                AND    pol2.po_line_id = pol.attribute9)) contract_num
      , --协议编号       
       wc.project_name project_name
      , --项目名称    
       wc.project_block_name project_block_name
      , --项目分期    
       wc.contract_name contract_name --施工合同    
FROM   cux_check_vendor_account_temp ccva
      ,fnd_lookup_values flv
      ,cux_check_account_line_temp cal
      ,rcv_shipment_headers rsh
      ,rcv_shipment_lines rsl
      ,po_headers_all poh
      ,po_lines_all pol
      ,rcv_transactions rt
      ,(SELECT pla.po_header_id
              ,pla.attribute1 project_id
              ,wpt.fname project_name
              ,pla.attribute2 project_block_id
              ,wpb.fname project_block_name
              ,pla.attribute3 contract_id
              ,wct.fname contract_name
              ,row_number() over(PARTITION BY pla.po_header_id ORDER BY pla.po_header_id, pla.attribute3 NULLS LAST) row_num
              ,wpt.faddress
              ,pla.po_line_id
              ,wct.fsecondparty
        FROM   po_lines_all pla
              ,wbd.wbd_project_t wpt
              ,(SELECT wpbt.fpbno
                      ,wpbt.fname
                FROM   wbd.wbd_project_t  wpt
                      ,wbd_projectblock_t wpbt
                WHERE  wpt.fiseffective = '1'
                AND    wpt.fprjid = wpbt.fprjid) wpb
              ,wpc.wpc_contract_t wct
        WHERE  wpt.fiseffective(+) = '1'
        AND    wpt.fprjno(+) = pla.attribute1
        AND    wpb.fpbno(+) = pla.attribute2
        AND    wct.fconid(+) = pla.attribute3
        AND    nvl(pla.closed_code, 'OPEN') = 'OPEN'
        AND    nvl(pla.cancel_flag, 'N') = 'N') wc
      ,zx_id_tcc_mapping_all cit
WHERE  1 = 1
AND    flv.lookup_type(+) = 'CUX_DOCUMENTS_STATUS'
AND    flv.language(+) = userenv('LANG')
AND    flv.lookup_code(+) = ccva.approve_code
AND    ccva.vendor_account_id = cal.vendor_account_id
AND    cal.receipt_id = rsh.shipment_header_id
AND    rsh.shipment_header_id = rsl.shipment_header_id
AND    cal.receipt_line_id = rsl.shipment_line_id
AND    rt.shipment_header_id = rsh.shipment_header_id
AND    rt.shipment_line_id = rsl.shipment_line_id
AND    rt.transaction_type = 'RECEIVE'
AND    poh.po_header_id = pol.po_header_id
AND    rt.po_header_id = poh.po_header_id
AND    rt.po_line_id = pol.po_line_id
AND    wc.po_header_id(+) = poh.po_header_id
AND    wc.row_num(+) = 1
AND    cit.tax_rate_code_id(+) = pol.attribute6
and   receipt_num='R2017030021'
--AND    ccva.vendor_account_id = 1521
;