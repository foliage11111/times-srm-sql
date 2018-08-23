select rsh.receipt_num receipt_num, --接收单号  
              rsh.shipment_header_id shipment_header_id,
              rsl.shipment_line_id shipment_line_id,
              rsl.line_num as line_num, --行号  
              (case
                when rt.attribute2 is not null then
                 to_char(to_date(rt.attribute2, 'yyyy-MM-dd'),
                         'yyyy-MM-dd')
                else
                 to_char(rt.transaction_date, 'yyyy-MM-dd')
              end) receiveDate, --接收日期  
              (select msib.segment1
                 from mtl_system_items_b msib
                where msib.inventory_item_id = pol.item_id
                  and rownum = 1) item_code, --物料编码  
              (select msib.LONG_DESCRIPTION
                 from MTL_SYSTEM_ITEMS_FVL msib
                where msib.inventory_item_id = pol.item_id
                  and rownum = 1) item_description, --物料描述  
              pol.unit_meas_lookup_code unit_meas_lookup_code, --单位  
              pol.quantity order_quantity, --订购数量  
              rt.quantity receive_quantity, --接收数量  
              pol.unit_price unit_price, --单价  
              cit.tax_classification_code tax_code, --税率  
              round(rt.quantity * pol.unit_price, 2) receive_amount, --接收金额(不含税)   
              pol.attribute6 attribute6,
              round((rt.quantity * pol.unit_price +
                    rt.quantity * pol.unit_price *
                    (regexp_substr(cit.tax_classification_code, '[0-9]+') / 100)),
                    2) receive_tax_amount, --接收金额(含税)  
              poh.segment1 order_number, --采购订单编号  
              (select poh2.segment1
                 from po_headers_all poh2
                where poh2.po_header_id =
                      (select pol2.po_header_id
                         from po_lines_all pol2
                        where 1=1              
                          and pol2.po_line_id = pol.attribute9)) contract_num, --协议编号   
              --pol.contract_num, --协议编号   
              wc.project_name       project_name, --项目名称  
              wc.project_block_name project_block_name, --项目分期  
              wc.contract_name      contract_name --施工合同  
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
             --排除已经对账的 
          and not exists
        (select 1
                 from CUX_CHECK_ACCOUNT_LINE_TEMP   ccal,
                      cux_check_vendor_account_temp ccv
                where 1 = 1
                  and ccal.receipt_id = rsh.shipment_header_id
                  and ccal.receipt_line_id = rsl.shipment_line_id
                  and ccal.vendor_account_id = ccv.vendor_account_id
               --and ccv.approve_code='APPROVED' 
               )