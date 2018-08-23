SELECT l.rowno line_num
      ,l.check_account_num
      ,l.check_account_date
      ,l.check_amount
      ,l.check_tax_amount
      ,l.payment_ratio
      ,(l.sum_apply_amount - l.can_apply_for_tax) sum_apply_amount
      ,l.can_apply_tax
      ,l.can_apply_for_tax
FROM   (SELECT t.check_account_num
              ,t.check_account_date
              ,nvl(t.check_amount, 0) check_amount
              ,nvl(t.check_tax_amount, 0) check_tax_amount
              ,t.payment_ratio || '%' payment_ratio
              ,nvl(t.sum_apply_amount, 0) sum_apply_amount
              ,round((nvl(t.check_tax_amount, 0) *
                     (nvl(t.payment_ratio, 0) / 100) -
                     nvl(t.sum_apply_amount, 0)),
                     2) can_apply_tax
              ,t.can_apply_for_tax
              ,nvl(t.payment_ratio, 0) / 100 tratio
              ,dense_rank() over(PARTITION BY t.payment_header_id ORDER BY t.payment_line_id) rowno
        FROM   (SELECT DISTINCT (SELECT SUM(cpal.can_apply_for_tax)
                                 FROM   cux_payment_protal_apply      cppa
                                       ,cux_payment_apply_line        cpal
                                       ,cux_check_vendor_account_temp ccvt
                                 WHERE  cppa.approve_state <> 'ABORT'
                                 AND    cppa.protal_apply_id =
                                        cpal.payment_header_id
                                 AND    ccvt.vendor_account_id =
                                        cpal.pro_order_id
                                 AND    ccvt.vendor_account_id =
                                        paymentlineeo.pro_order_id
                                 AND    cppa.payment_type = 'PJDK') sum_apply_amount
                               ,cppa.protal_apply_id payment_header_id
                               ,paymentlineeo.payment_line_id payment_line_id
                               ,cvat.check_account_num
                               ,to_char(cvat.check_account_date,
                                        'YYYY-MM-DD') check_account_date
                               ,cvat.check_amount
                               ,cvat.check_tax_amount
                               ,nvl((SELECT poh.attribute2
                                    FROM   po_headers_all poh
                                    WHERE  poh.segment1 =
                                           account1.contract_num),
                                    100) payment_ratio
                               ,paymentlineeo.can_apply_for_tax
                               ,(SELECT SUM(crat.reduce_tax_amount)
                                 FROM   cux_reduce_account_temp crat
                                 WHERE  1 = 1
                                 AND    crat.vendor_account_id =
                                        cvat.vendor_account_id) reducetaxamount
                FROM   cux_payment_apply_line paymentlineeo
                      ,cux_payment_protal_apply cppa
                      ,cux_check_vendor_account_temp cvat
                      ,(SELECT (SELECT poh2.segment1
                                FROM   po_headers_all poh2
                                WHERE  poh2.po_header_id =
                                       (SELECT pol2.po_header_id
                                        FROM   po_lines_all pol2
                                        WHERE  1 = 1
                                        AND    pol2.po_line_id = pol.attribute9)) contract_num
                              , --协议编号          
                               ccva.vendor_account_id
                        FROM   cux_check_vendor_account_temp ccva
                              ,cux_check_account_line_temp   cal
                              ,rcv_shipment_headers          rsh
                              ,rcv_shipment_lines            rsl
                              ,po_headers_all                poh
                              ,po_lines_all                  pol
                              ,rcv_transactions              rt
                        WHERE  1 = 1
                        AND    ccva.vendor_account_id = cal.vendor_account_id
                        AND    cal.receipt_id = rsh.shipment_header_id
                        AND    rsh.shipment_header_id =
                               rsl.shipment_header_id
                        AND    cal.receipt_line_id = rsl.shipment_line_id
                        AND    rt.shipment_header_id = rsh.shipment_header_id
                        AND    rt.shipment_line_id = rsl.shipment_line_id
                        AND    rt.transaction_type = 'RECEIVE'
                        AND    poh.po_header_id = pol.po_header_id
                        AND    rt.po_header_id = poh.po_header_id
                        AND    rt.po_line_id = pol.po_line_id
                        AND    ccva.approve_code = 'APPROVED') account1
                WHERE  1 = 1
                AND    paymentlineeo.payment_header_id =
                       cppa.protal_apply_id(+)
                AND    cvat.vendor_account_id = account1.vendor_account_id(+)
                AND    cvat.vendor_account_id(+) = paymentlineeo.pro_order_id
                AND    cvat.approve_code(+) = 'APPROVED') t
        WHERE  1 = 1
        AND    t.payment_header_id = 9301) l
WHERE  l.rowno > 0
AND    l.rowno <= 5



SELECT aa.rowno line_num
      ,aa.protal_apply_code check_account_num
      ,aa.payment_type_name check_account_date
      ,nvl(aa.check_amount, 0) check_amount
      ,nvl(aa.check_tax_amount, 0) check_tax_amount
      ,aa.payment_ratio
      ,nvl(aa.sum_apply_amount, 0) sum_apply_amount
      ,round((nvl(aa.check_tax_amount, 0) - nvl(aa.sum_apply_amount, 0)),
             2) can_apply_tax
      ,nvl(aa.can_apply_for_tax, 0) can_apply_for_tax
FROM   (SELECT t.protal_apply_code
              ,t.protal_apply_id
              ,to_char(t.apply_date, 'YYYY-MM-DD') applydate
              ,t.apply_type applytype
              ,t.pay_amount
              ,to_char(t.pay_date, 'YYYY-MM-DD') paydate
              ,t.pay_state paystate
              ,t.pay_status_name paystatusname
              ,t.payment_amount
              ,'PJSK' payment_type
              ,'结算款' payment_type_name
              ,t.sum_amount
              ,t.sum_amount_tax
              ,saaf_generate_tender_code.getzbjaccountnoamount(paymentlineeo.payment_id) check_amount
              ,saaf_generate_tender_code.getzbjaccountamount(paymentlineeo.payment_id) check_tax_amount
              ,saaf_generate_tender_code.getzbjamount(paymentlineeo.payment_id) sum_apply_amount
              ,100 || '%' payment_ratio
              ,paymentlineeo.payment_line_id
              ,paymentlineeo.can_apply_for_tax
              ,paymentlineeo.pro_order_id
              ,dense_rank() over(PARTITION BY t.protal_apply_id ORDER BY paymentlineeo.payment_line_id) rowno
        FROM   cux_payment_protal_apply_v t
              ,cux_payment_apply_line     paymentlineeo
        WHERE  1 = 1
        AND    t.protal_apply_id = paymentlineeo.payment_header_id
        AND    t.payment_type = 'PZBJ'
        AND    t.protal_apply_id = 9101) aa
WHERE  aa.rowno > 0
AND    aa.rowno <= 5

