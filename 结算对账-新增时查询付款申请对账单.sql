select t.checkAccountNum,
          t.vendor_account_id,
          nvl(t.sumApplyAmount, 0) sumApplyAmount,
          round((nvl(t.checkTaxAmount, 0) * (nvl(t.paymentRatio, 0) / 100) -
                nvl(t.sumApplyAmount, 0)),
                2) canApplyTax,
          null paymentId,
          t.vendorId,
          t.checkAccountDate,
          nvl(t.checkAmount, 0) checkAmount,
          nvl(t.checkTaxAmount, 0) checkTaxAmount,
          t.paymentRatio || '%' paymentRatio,
          t.creationDate,
          t.vendorName,
          t.vendorAccountId proOrderId,
          t.reduceTaxAmount,
          case
            when nvl(t.checkTaxAmount, 0) > nvl(t.invoice_tax_total_amount, 0) then
             '�ö��˵�δ��Ʊ'
            else
             null
          end invoice_msg,
          pv.VENDOR_NAME
     from (SELECT distinct (SELECT SUM(cpal.can_apply_for_tax)
                              FROM cux_payment_protal_apply      cppa,
                                   cux_payment_apply_line        cpal,
                                   cux_check_vendor_account_temp ccvt
                             WHERE cppa.approve_state <> 'ABORT'
                               AND cppa.protal_apply_id = cpal.payment_header_id
                               AND ccvt.vendor_account_id = cpal.pro_order_id
                               AND ccvt.vendor_account_id =
                                   paymentlineeo.pro_order_id
                               AND cppa.payment_type = 'PJDK') sumApplyAmount, --�ۼ���������           
                           cvat.check_account_num checkAccountNum, /*���˵���*/
                           cvat.vendor_id vendorId, /*��Ӧ��id*/
                           to_char(cvat.check_account_date, 'YYYY-MM-DD') checkAccountDate, /*��������*/
                           cvat.vendor_account_id,
                           cvat.check_amount checkAmount, /*���˽���˰*/
                           cvat.check_tax_amount checkTaxAmount, /*���˽�˰*/
                           (select cih.invoice_tax_total_amount
                              from cux_invoice_headers_all cih
                             where cih.vendor_account_id =
                                   cvat.vendor_account_id
                               and rownum = 1) invoice_tax_total_amount, --��Ʊ���   
                           nvl((select poh.attribute3 
                                 from po_headers_all poh
                                where poh.segment1 = account1.contract_num),
                               0) paymentRatio, /*��ͬԼ���������*/
                           TO_CHAR(cvat.creation_date, 'YYYY-MM-DD') creationDate, /*����ʱ��*/
                           cvat.vendor_name vendorName, /*��Ӧ������*/
                           cvat.vendor_account_id vendorAccountId,
                           (select sum(crat.reduce_tax_amount)
                              from CUX_REDUCE_ACCOUNT_TEMP crat
                             where 1 = 1
                               and crat.vendor_account_id =
                                   cvat.vendor_account_id) reduceTaxAmount
             FROM cux_payment_apply_line paymentlineeo,
                  cux_payment_protal_apply cppa,
                  fnd_lookup_values flv,
                  cux_check_vendor_account_temp cvat,
                  (select (select poh2.segment1
                             from po_headers_all poh2
                            where poh2.po_header_id =
                                  (select pol2.po_header_id
                                     from po_lines_all pol2
                                    where 1 = 1
                                      and pol2.po_line_id = pol.attribute9)) contract_num, --Э����               
                          ccva.vendor_account_id
                     from cux_check_vendor_account_temp ccva,
                          CUX_CHECK_ACCOUNT_LINE_TEMP   cal,
                          rcv_shipment_headers          rsh,
                          rcv_shipment_lines            rsl,
                          po_headers_all                poh,
                          po_lines_all                  pol,
                          rcv_transactions              rt
                    where 1 = 1
                      and ccva.vendor_account_id = cal.vendor_account_id
                      and cal.receipt_id = rsh.shipment_header_id
                      and rsh.shipment_header_id = rsl.shipment_header_id
                      and cal.receipt_line_id = rsl.shipment_line_id
                      and rt.shipment_header_id = rsh.shipment_header_id
                      and rt.shipment_line_id = rsl.shipment_line_id
                      and rt.transaction_type = 'RECEIVE'
                      and poh.po_header_id = pol.po_header_id
                      and rt.po_header_id = poh.po_header_id
                      and rt.po_line_id = pol.po_line_id
                      and ccva.approve_code = 'APPROVED') account1
            WHERE 1 = 1
              and paymentlineeo.payment_header_id = cppa.protal_apply_id(+)
              AND flv.lookup_code(+) = cppa.payment_type
              and cvat.vendor_account_id = account1.vendor_account_id
              AND cvat.vendor_account_id = paymentlineeo.pro_order_id(+)
              and cvat.approve_code = 'APPROVED'
              AND flv.lookup_type(+) = 'CUX_PROTAL_PAYMENT_TYPE'
              AND flv.language(+) = userenv('LANG')
                 --�ų��������˽���Ķ��˵�
              and not exists
            (select 1
                     from cux_account_payment_headers caph,
                          cux_account_payment_lines   capl
                    where caph.header_id = capl.header_id
                      and capl.vendor_account_id = cvat.vendor_account_id)
                 --�ų����������Ķ��˵�     
              and not exists
            (select 1
                     from cux_payment_apply_line      paymentlineeo1,
                          cux_payment_protal_apply    cppa1,
                          cux_account_payment_headers caph,
                          cux_account_payment_lines   capl
                    where 1 = 1
                      and paymentlineeo1.payment_header_id =
                          cppa1.protal_apply_id
                      and caph.header_id = capl.header_id
                      and paymentlineeo1.attribute1 = caph.header_id
                      and capl.vendor_account_id = cvat.vendor_account_id
                      and cppa1.payment_type = 'PJSK')) t,po_vendors pv
    where 1 = 1
         --�ɸ���>0�Ķ��˵�            
    /*  and round((nvl(t.checkTaxAmount, 0) * (nvl(t.paymentRatio, 0) / 100) -
                nvl(t.sumApplyAmount, 0)),
                2) > 0*/
                and t.vendorId=pv.VENDOR_ID
                and t.vendorId=193131
��


select t.checkAccountNum,  
                             nvl(t.sumApplyAmount, 0) sumApplyAmount,  
                             round((nvl(t.checkTaxAmount, 0) * (nvl(t.paymentRatio, 0) / 100) -  
                             nvl(t.sumApplyAmount, 0)),2) canApplyTax,  
                             t.vendorId,  
                             t.checkAccountDate,  
                             nvl(t.checkAmount, 0) checkAmount,  
                             nvl(t.checkTaxAmount, 0) checkTaxAmount,  
                             t.paymentRatio || '%' paymentRatio,  
                             nvl(t.paymentRatio,0)/100 tratio, 
                             t.creationDate,  
                             t.vendorName,  
                             t.vendorAccountId proOrderId,  
                             t.reduceTaxAmount,  
                             t.paymentHeaderId,  
                             t.paymentLineId,  
                             t.can_apply_for_tax canApplyForTax ,
                             t.contract_num 
                        from (SELECT distinct (SELECT SUM(cpal.can_apply_for_tax)  
                                                 FROM cux_payment_protal_apply      cppa,  
                                                      cux_payment_apply_line        cpal,  
                                                      cux_check_vendor_account_temp ccvt  
                                                WHERE cppa.approve_state <> 'ABORT'  
                                                  AND cppa.protal_apply_id = cpal.payment_header_id  
                                                  AND ccvt.vendor_account_id = cpal.pro_order_id  
                                                  AND ccvt.vendor_account_id =  
                                                      paymentlineeo.pro_order_id  
                                                  AND cppa.payment_type = 'PJDK') sumApplyAmount, --�ۼ���������      
                                              cppa.protal_apply_id paymentHeaderId,  
                                              paymentlineeo.payment_line_id paymentLineId,  
                                              cvat.check_account_num checkAccountNum, /*���˵���*/  
                                              cvat.vendor_id vendorId, /*��Ӧ��id*/  
                                              to_char(cvat.check_account_date, 'YYYY-MM-DD') checkAccountDate, /*��������*/  
                                              cvat.check_amount checkAmount, /*���˽���˰*/  
                                              cvat.check_tax_amount checkTaxAmount, /*���˽�˰*/  
                                              nvl((select poh.attribute3  
                                                    from po_headers_all poh  
                                                   where poh.segment1 = account1.contract_num),  
                                                  100) paymentRatio, /*��ͬԼ���������*/  
                                              TO_CHAR(cvat.creation_date, 'YYYY-MM-DD') creationDate, /*����ʱ��*/  
                                              cvat.vendor_name vendorName, /*��Ӧ������*/  
                                              cvat.vendor_account_id vendorAccountId,  
                                              paymentlineeo.can_apply_for_tax,  
                                              (select sum(crat.reduce_tax_amount)  
                                                 from CUX_REDUCE_ACCOUNT_TEMP crat  
                                                where 1 = 1  
                                                  and crat.vendor_account_id =  
                                                      cvat.vendor_account_id) reduceTaxAmount ,
                                                      account1. contract_num
                                FROM cux_payment_apply_line paymentlineeo,  
                                     cux_payment_protal_apply cppa,  
                                     fnd_lookup_values flv,  
                                     cux_check_vendor_account_temp cvat,  
                                     (select (select poh2.segment1  
                                                from po_headers_all poh2  
                                               where poh2.po_header_id =  
                                                     (select pol2.po_header_id  
                                                        from po_lines_all pol2  
                                                       where 1 = 1  
                                                         and pol2.po_line_id = pol.attribute9)) contract_num, --Э����          
                                             ccva.vendor_account_id  
                                        from cux_check_vendor_account_temp ccva,  
                                             CUX_CHECK_ACCOUNT_LINE_TEMP   cal,  
                                             rcv_shipment_headers          rsh,  
                                             rcv_shipment_lines            rsl,  
                                             po_headers_all                poh,  
                                             po_lines_all                  pol,  
                                             rcv_transactions              rt  
                                       where 1 = 1  
                                         and ccva.vendor_account_id = cal.vendor_account_id  
                                         and cal.receipt_id = rsh.shipment_header_id  
                                         and rsh.shipment_header_id = rsl.shipment_header_id  
                                         and cal.receipt_line_id = rsl.shipment_line_id  
                                         and rt.shipment_header_id = rsh.shipment_header_id  
                                         and rt.shipment_line_id = rsl.shipment_line_id  
                                         and rt.transaction_type = 'RECEIVE'  
                                         and poh.po_header_id = pol.po_header_id  
                                         and rt.po_header_id = poh.po_header_id  
                                         and rt.po_line_id = pol.po_line_id  
                                         and ccva.approve_code = 'APPROVED') account1  
                               WHERE 1 = 1  
                                 and paymentlineeo.payment_header_id = cppa.protal_apply_id(+)  
                                 AND flv.lookup_code(+) = cppa.payment_type  
                                 and cvat.vendor_account_id = account1.vendor_account_id(+)  
                                 AND cvat.vendor_account_id(+) = paymentlineeo.pro_order_id  
                                 and cvat.approve_code(+) = 'APPROVED'  
                                 AND flv.lookup_type(+) = 'CUX_PROTAL_PAYMENT_TYPE'  
                                 AND flv.language(+) = userenv('LANG')) t  
                       where 1 = 1
                     and t.paymentHeaderId=602��

