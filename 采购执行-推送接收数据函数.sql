DECLARE

  RECEPT_ID NUMBER;
   x_return_code  VARCHAR2(2000);
    x_return_msg   VARCHAR2(2000);
BEGIN
 for receipt_group in (
   select shipment_header_id,receipt_num,order_number,po_header_id  from(
select rt.transaction_id,rt.attribute1 kk,cprh.* from cux_po_receive_headers cprh,rcv_transactions rt where cprh.receipt_num=rt.attribute1(+) and cprh.approve_code='APPROVED'  
) a where a.kk is null ) loop  ---查询所有不正确的数据
  


 CUX_RECEIVE_IMPORT_PKG.approve_main(receipt_group.shipment_header_id,x_return_code,x_return_msg);---调用推送程序
 
 dbms_output.put_line(receipt_group.shipment_header_id||'-'||receipt_group.receipt_num||'-'||receipt_group.order_number||'-'||receipt_group.po_header_id ||'-'||x_return_code||'-'|| x_return_msg);
 end loop;
END;
