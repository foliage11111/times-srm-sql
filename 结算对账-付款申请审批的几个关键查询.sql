-- 累计产值、累计应付款都会包含此到货接收（根据协议找的），因此这两个值也是对的。
--    累计已付款和累计已请款则会与此上次的问题一样比正常金额更大，因为这个错误的对账单和付款申请两边都能被找到。
 
  /*1  v_received_amount number;/*累计产值*/
    BEGIN

      SELECT SUM(trunc((trunc((nvl(pla.attribute11,pla.unit_price * (1 + v_tax_rate))),4) *
                       rsl.quantity_received),2))
    --  INTO   v_received_amount
      FROM   po_lines_all       pla
            ,rcv_shipment_lines rsl
      WHERE  rsl.po_header_id = pla.po_header_id
      AND    rsl.po_line_id = pla.po_line_id
      AND    EXISTS (SELECT 1
              FROM   po_lines_all al
              WHERE  al.po_line_id = pla.attribute9
              AND    al.po_header_id = v_ag_header_id);


    --
    --21v_payable_amount number;/*累计应付款*/

SELECT trunc(SUM(trunc((trunc((nvl(pla.attribute11,pla.unit_price * (1 + 0.17))),4) *
                       rsl.quantity_received),2)) *0.92,2)
 
      FROM   po_lines_all       pla
            ,rcv_shipment_lines rsl
      WHERE  rsl.po_header_id = pla.po_header_id
      AND    rsl.po_line_id = pla.po_line_id
      AND    EXISTS (SELECT 1
              FROM   po_lines_all al
              WHERE  al.po_line_id = pla.attribute9
              AND    al.po_header_id =&v_ag_header_id);
              
              
 		--3
 		 
    /*v_paid_amount number;/*累计已付款*/
    BEGIN
    
     SELECT nvl(SUM(wp.fpay_amount)
               ,0)
       INTO v_paid_amount
       FROM cux_payment_protal_apply  cppa
           ,wpc_paymentcheck_t        wp
           ,wpc_paymentcheck_apply_t1 wt
      WHERE wt.fapply_id = cppa.protal_apply_id
        AND wp.fcheck_id = wt.fcheck_id
        AND wp.fwflowstate = '20'
        AND EXISTS
      (SELECT 1
               FROM po_lines_all                pla
                   ,rcv_shipment_lines          rsl
                   ,cux_check_account_line_temp ccal
                   ,cux_payment_apply_line      cpal
              WHERE rsl.po_header_id = pla.po_header_id
                AND rsl.po_line_id = pla.po_line_id
                AND ccal.receipt_id = rsl.shipment_header_id
                AND ccal.receipt_line_id = rsl.shipment_line_id
                AND cpal.pro_order_id = ccal.vendor_account_id
                AND cppa.protal_apply_id = cpal.payment_header_id
                AND EXISTS
              (SELECT 1
                       FROM po_lines_all agl
                      WHERE agl.po_line_id = to_number(pla.attribute9)
                        AND agl.po_header_id = v_ag_header_id))
        AND cppa.protal_apply_id <> p_source_header_id
        AND cppa.approve_state IN ('APPROVING'
                                  ,'APPROVED');
    
    EXCEPTION
      WHEN OTHERS THEN
        v_paid_amount := NULL;
    END;
    
    --
select * from cux_payment_protal_apply cppa where cppa.protal_apply_code='P2017090057'; ---3104
    
    ---
    --4  v_apply_amount number;/*累计已请款*/
    /**/
    BEGIN
    
      SELECT nvl(SUM(cppa.payment_amount),0)
      INTO   v_apply_amount
      FROM   cux.cux_payment_protal_apply cppa
      WHERE  EXISTS (SELECT 1
              FROM   po_lines_all                pla
                    ,rcv_shipment_lines          rsl
                    ,cux_check_account_line_temp ccal
                    ,cux_payment_apply_line      cpal
                    ,po_lines_all                agl
              WHERE  rsl.po_header_id = pla.po_header_id
              AND    rsl.po_line_id = pla.po_line_id
              AND    ccal.receipt_line_id = rsl.shipment_line_id
              AND    ccal.receipt_id = rsl.shipment_header_id
              AND    cpal.pro_order_id = ccal.vendor_account_id
              AND    cppa.protal_apply_id = cpal.payment_header_id
              AND    to_char(agl.po_line_id) = pla.attribute9
              AND    agl.po_header_id = v_ag_header_id)
      AND    cppa.protal_apply_id <> p_source_header_id
      AND    cppa.approve_state IN ('APPROVING', 'APPROVED')
      AND    cppa.last_update_date <= v_last_update_date;
    
    EXCEPTION
      WHEN OTHERS THEN
        v_apply_amount := NULL;
    END; 

---
SELECT nvl(SUM(cppa.payment_amount),0)
     
      FROM   cux.cux_payment_protal_apply cppa
      WHERE  EXISTS (SELECT 1
              FROM   po_lines_all                pla
                    ,rcv_shipment_lines          rsl
                    ,cux_check_account_line_temp ccal
                    ,cux_payment_apply_line      cpal
                    ,po_lines_all                agl
              WHERE  rsl.po_header_id = pla.po_header_id
              AND    rsl.po_line_id = pla.po_line_id
              AND    ccal.receipt_line_id = rsl.shipment_line_id
              AND    ccal.receipt_id = rsl.shipment_header_id
              AND    cpal.pro_order_id = ccal.vendor_account_id
              AND    cppa.protal_apply_id = cpal.payment_header_id
              AND    to_char(agl.po_line_id) = pla.attribute9
              AND    agl.po_header_id = &v_ag_header_id
              )
       AND    cppa.approve_state IN ('APPROVING', 'APPROVED')
      AND    cppa.protal_apply_id <> &p_source_header_id----
      AND    cppa.last_update_date <= (select cppa1.last_update_date from cux_payment_protal_apply cppa1 where cppa1.protal_apply_id=&p_source_header_id)
      ;
      
      ---
      select sum(payment_amount) from (
      SELECT distinct cppa.protal_apply_id,cppa.protal_apply_code,cppa.payment_amount,cppa.approve_state
              FROM   po_lines_all                pla
                    ,rcv_shipment_lines          rsl
                    ,cux_check_account_line_temp ccal
                    ,cux_payment_apply_line      cpal
                    ,po_lines_all                agl
                    ,cux.cux_payment_protal_apply cppa
              WHERE  rsl.po_header_id = pla.po_header_id
              AND    rsl.po_line_id = pla.po_line_id
              AND    ccal.receipt_line_id = rsl.shipment_line_id
              AND    ccal.receipt_id = rsl.shipment_header_id
              AND    cpal.pro_order_id = ccal.vendor_account_id
              AND    cppa.protal_apply_id = cpal.payment_header_id
              AND    to_char(agl.po_line_id) = pla.attribute9
              AND    cppa.approve_state IN ('APPROVING', 'APPROVED')
              AND    agl.po_header_id = &v_ag_header_id
              
              )
      
      ---1
      select cppa.protal_apply_code,cppa.payment_amount,a.* from cux_payment_protal_apply cppa ,
( select t.payment_header_id,t.check_account_num,t.check_amount,sum(t.untax_amount),sum(t.untax_amount)*1.17 taxed_am
    from (select rsl.shipment_header_id,cvac.check_account_num,cvac.check_amount,cpal.payment_header_id ,pla.quantity,pla.unit_price,agl.unit_price,agl.attribute10,rsl.quantity_received
    ,rsl.quantity_received*agl.unit_price untax_amount
            FROM   po_lines_all                pla
                    ,rcv_shipment_lines          rsl
                    ,cux_check_account_line_temp ccal
                    ,cux_check_vendor_account_temp cvac
                    ,cux_payment_apply_line      cpal
                    ,po_lines_all                agl
              WHERE  rsl.po_header_id = pla.po_header_id
              and ccal.vendor_account_id=cvac.vendor_account_id
              AND    rsl.po_line_id = pla.po_line_id
              AND    ccal.receipt_line_id = rsl.shipment_line_id
              AND    ccal.receipt_id = rsl.shipment_header_id
              AND    cpal.pro_order_id = ccal.vendor_account_id
              AND    to_char(agl.po_line_id) = pla.attribute9
              and cvac.approve_code='APPROVED'
             AND    agl.po_header_id = &v_ag_header_id
             ) t---
                  group by t.payment_header_id,t.check_account_num,t.check_amount
                  ) a---
                  where cppa.protal_apply_id=a.payment_header_id
                  ---
                  
                   
 
    /**/
    BEGIN
    
      SELECT nvl(SUM(cra.reduce_tax_amount),0)
      INTO   v_deduct_amount
      FROM   cux.cux_payment_protal_apply cppa
            ,cux.cux_reduce_account_temp  cra
      WHERE  EXISTS (SELECT 1
              FROM   po_lines_all                pla
                    ,rcv_shipment_lines          rsl
                    ,cux_check_account_line_temp ccal
                    ,cux_payment_apply_line      cpal
                    ,po_lines_all                agl
              WHERE  rsl.po_header_id = pla.po_header_id
              AND    rsl.po_line_id = pla.po_line_id
              AND    ccal.receipt_id = rsl.shipment_header_id
              AND    cpal.pro_order_id = ccal.vendor_account_id
              AND    cppa.protal_apply_id = cpal.payment_header_id
              AND    to_char(agl.po_line_id) = pla.attribute9
              AND    agl.po_header_id = v_ag_header_id)
      AND    cppa.protal_apply_id <> p_source_header_id
      AND    cppa.approve_state IN ('APPROVING', 'APPROVED')
      AND    cra.vendor_account_id = cppa.protal_apply_id;
    
    EXCEPTION
      WHEN OTHERS THEN
        v_deduct_amount := NULL;
    END;
    
  
    
--  v_received_proportion varchar2(150);/**/
 
 -- v_payable_proportion varchar2(150);/**/
 
 -- v_paid_proportion varchar2(150);/**/
 
 -- v_apply_proportion varchar2(150);/**/
   
 -- v_reconciliation_amount number;/**/
    
    
       v_received_proportion := to_char(trunc((v_received_amount/v_blanket_tax_total)*100,2),'FM990D00')||'%';
       v_payable_proportion := to_char(trunc((v_payable_amount/v_blanket_tax_total)*100,2),'FM990D00')||'%';
       v_paid_proportion := to_char(trunc((v_paid_amount/v_blanket_tax_total)*100,2),'FM990D00')||'%';
       v_apply_proportion := to_char(trunc((v_apply_amount/v_blanket_tax_total)*100,2),'FM990D00')||'%';
       
       
       
       
       	/*排除 rsl 表用的问题,退货是会返回到这个表里面去。	
					select * from 	rcv_shipment_lines rsl where rsl.po_line_id=280334;
						
						select * from rcv_transactions rt where rt.po_line_id=280334 and rt.transaction_type in ('DELIVER','RETURN TO VENDOR');*/
    --
    --21v_payable_amount number;/*累计应付款*/
 SELECT SUM(trunc((trunc((nvl(pla.attribute11,pla.unit_price * 1.17)),4) *
                       rsl.quantity_received),2))
    --  INTO   v_received_amount
	
      FROM   po_lines_all       pla
            , rcv_transactions rt
      WHERE  rt.po_header_id = pla.po_header_id
      AND    rt.po_line_id = pla.po_line_id
			and 
      AND    EXISTS (SELECT 1
              FROM   po_lines_all al
              WHERE  al.po_line_id = pla.attribute9
              AND    al.po_header_id = 57068);
						--	280334
				