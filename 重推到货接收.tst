PL/SQL Developer Test script 3.0
25



--调用测试脚本自动推送。
DECLARE

  RECEPT_ID NUMBER;
   x_return_code  VARCHAR2(2000);
    x_return_msg   VARCHAR2(2000);
BEGIN
 for receipt_group in (
   select shipment_header_id,receipt_num,order_number,po_header_id  from(
select rt.transaction_id,rt.attribute1 kk,cux_rcv.* from (select distinct cprh.receipt_num,cprh.shipment_header_id,cprh.approve_code,cprh.order_number,cprh.po_header_id from cux_po_receive_headers cprh ,cux_po_receive_lines cprl 
where cprl.shipment_header_id=cprh.shipment_header_id 
and cprl.quantity_receiving<>0) cux_rcv,rcv_transactions rt where cux_rcv.receipt_num=rt.attribute1(+) and cux_rcv.approve_code='APPROVED' 

) a where a.kk is null ) loop
  


 CUX_RECEIVE_IMPORT_PKG.approve_main(receipt_group.shipment_header_id,x_return_code,x_return_msg);
 
 dbms_output.put_line(receipt_group.shipment_header_id||'-'||receipt_group.receipt_num||'-'||receipt_group.order_number||'-'||receipt_group.po_header_id ||'-'||x_return_code||'-'|| x_return_msg);
 end loop;
END;
0
0
