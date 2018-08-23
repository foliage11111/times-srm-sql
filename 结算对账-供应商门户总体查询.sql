--到货通知单头表
select cdhi.DEL_HEADER_ID,cdhi.PO_ORDER_NUM,cdhi.DELIVER_CODE,cdhi.APPROVE_CODE,cdli.* from CUX.CUX_DELIVERY_HEADERS_INFO cdhi ,CUX_DELIVERY_LINES_INFO cdli
where 
cdhi.DEL_HEADER_ID=cdli.DELIVERY_HEADER_ID 



--and cdhi.PO_ORDER_NUM='2017000123'
and cdhi.DELIVER_CODE='D2017040130'
; 

select * from CUX.CUX_DELIVERY_LINES_INFO cdli
where
cdli.DELIVERY_HEADER_ID=2079

;

--修改送货通知单状态
--DRAFT草稿  APPROVING审批中   APPROVED审批通过   REJECTED审批驳回
select cdh.approve_code from cux_delivery_headers_info cdh where cdh.deliver_code='D2017040061' for update;

update cux_delivery_headers_info cdh set cdh.approve_code='DRAFT' where cdh.deliver_code='D2017040061';



---标准接收头
select * from rcv_shipment_headers rsh where rsh.RECEIPT_NUM='R2017030003';

select * from PO.RCV_SHIPMENT_LINES rsl where rsl.SHIPMENT_HEADER_ID=15053;


---客制化接收表
select * from CUX_PO_RECEIVE_HEADERS cprh where cprh.APPROVE_CODE='APPROVED' and cprh.SHIPMENT_HEADER_ID =276;

select * from CUX_PO_RECEIVE_LINES cprl where cprl.SHIPMENT_HEADER_ID=276;

--修改接收单状态
select cdh.approve_code from cux_po_receive_headers cdh where cdh.receipt_num='';


---匹配客制已审批,但是标准推送失败的数据:


select *  from CUX_PO_RECEIVE_HEADERS cprh where cprh.APPROVE_CODE='APPROVED' and cprh.RECEIPT_NUM not in (
select rsh.RECEIPT_NUM  from rcv_shipment_headers rsh );



select * from(
select rt.transaction_id,rt.attribute1 kk,cprh.* from cux_po_receive_headers cprh,rcv_transactions rt where cprh.receipt_num=rt.attribute1(+) and cprh.approve_code='APPROVED'  
) a where a.kk is null
;


----调用 plsql 的 package。不知道这样是不是就 ok 了
----重新推送已经在客制化系统审批通过,但是 erp 系统没有入系统的。
begin
  CUX_RECEIVE_IMPORT_PKG.APPROVE_MAIN(x=>:p_receive_id,y=>:x_return_code,z=>:x_return_msg);
  end;



 
		 select * from cux_check_vendor_account_temp t1 where t1.Approve_Code='APPROVED';
		
		select * from cux_check_account_line_temp ccal where ccal.vendor_account_id=2168;
    
    select * from cux_payment_protal_apply cppa where cppa.protal_apply_code='P2017110064';
    
    select * from cux_payment_apply_line cpal where cpal.payment_header_id=5217;
    
 
 select * from cux.cux_check_vendor_account_temp t where t.check_account_num = 'C2017120167';
 
 select * from cux.cux_payment_apply_line t where t.pro_order_id = 1908;--对账单头id，这里在付款行居然有两个
 
SELECT * FROM CUX.cux_payment_protal_apply t where t.protal_apply_code='P2017080003' ;

 select * from cux.cux_invoice_headers_all cih;
 
 
 select * from cux.cux_invoice_lines_all cil;
 

 select cil.invoice_line_id,cil.invoice_num,cil.invoice_type,cil.invoice_amount,cil.tax_amount,cil.invoice_tax_total_l_amount,
 cih.vendor_name,cih.org_name,cih.approve_code,cih.check_account_num,cih.invoice_total_amount,
 cih.invoice_tax_total_amount,cih.tax_total_amount,cih.*,cil.* 
 from cux.cux_invoice_headers_all cih,cux.cux_invoice_lines_all cil 
 where cih.invoice_header_id=cil.invoice_header_id
 and cil.invoice_num like '2004%'
 ;
 
 
  create table cux_invoice_lines_all_20180408 as select  cil.* 
 from cux.cux_invoice_headers_all cih,cux.cux_invoice_lines_all cil 
 where cih.invoice_header_id=cil.invoice_header_id
 and cil.invoice_num like '2004%'
;
select *from cux_invoice_lines_all_20180408;
 
 
-- update cux.cux_invoice_lines_all cil  set cil.tax_amount=4198.49 ,cil.invoice_amount=24696.94  where cil.invoice_line_id=3666;
 
-- update cux.cux_invoice_lines_all cil  set cil.tax_amount=3316.55 ,cil.invoice_amount=19509.15  where cil.invoice_line_id=3146; --20045403
 
-- update cux.cux_invoice_lines_all cil  set cil.tax_amount=16970.94 ,cil.invoice_amount=99829.06  where cil.invoice_line_id=3144;--20045400
 
-- update cux.cux_invoice_lines_all cil  set cil.tax_amount=16970.94 ,cil.invoice_amount=99829.06  where cil.invoice_line_id=3143; --20045399
 
--发票主表
SELECT * FROM AP_INVOICES_ALL Aih WHERE Aih.INVOICE_NUM = '20045399';

SELECT ail.amount,ail.* FROM AP_INVOICE_lines_all ail where ail.INVOICE_ID = 158379 for update; --update amount 字段
--发票分配表
SELECT aidl.amount,aidl.* FROM AP_INVOICE_DISTRIBUTIONS_ALL aidl WHERE aidl.INVOICE_ID = 158379 for update; --update amount 字段19509.15
