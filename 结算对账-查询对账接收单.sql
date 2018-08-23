select rsh.receipt_num receipt_num, --���յ���  
              rsh.shipment_header_id shipment_header_id,
              rsl.shipment_line_id shipment_line_id,
              rsl.line_num as line_num, --�к�  
              (case
                when rt.attribute2 is not null then
                 to_char(to_date(rt.attribute2, 'yyyy-MM-dd'),
                         'yyyy-MM-dd')
                else
                 to_char(rt.transaction_date, 'yyyy-MM-dd')
              end) receiveDate, --��������  
              (select msib.segment1
                 from mtl_system_items_b msib
                where msib.inventory_item_id = pol.item_id
                  and rownum = 1) item_code, --���ϱ���  
              (select msib.LONG_DESCRIPTION
                 from MTL_SYSTEM_ITEMS_FVL msib
                where msib.inventory_item_id = pol.item_id
                  and rownum = 1) item_description, --��������  
              pol.unit_meas_lookup_code unit_meas_lookup_code, --��λ  
              pol.quantity order_quantity, --��������  
              rt.quantity receive_quantity, --��������  
              pol.unit_price unit_price, --����  
              cit.tax_classification_code tax_code, --˰��  
              round(rt.quantity * pol.unit_price, 2) receive_amount, --���ս��(����˰)   
              pol.attribute6 attribute6,
              round((rt.quantity * pol.unit_price +
                    rt.quantity * pol.unit_price *
                    (regexp_substr(cit.tax_classification_code, '[0-9]+') / 100)),
                    2) receive_tax_amount, --���ս��(��˰)  
              poh.segment1 order_number, --�ɹ��������  
              (select poh2.segment1
                 from po_headers_all poh2
                where poh2.po_header_id =
                      (select pol2.po_header_id
                         from po_lines_all pol2
                        where 1=1              
                          and pol2.po_line_id = pol.attribute9)) contract_num, --Э����   
              --pol.contract_num, --Э����   
              wc.project_name       project_name, --��Ŀ����  
              wc.project_block_name project_block_name, --��Ŀ����  
              wc.contract_name      contract_name --ʩ����ͬ  
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
             --�ų��Ѿ����˵� 
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