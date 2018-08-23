--修改送货通知单状态
--DRAFT草稿  APPROVING审批中   APPROVED审批通过   REJECTED审批驳回
select cdh.approve_code from cux_delivery_headers_info cdh where cdh.deliver_code='D2017030002' for update;

--修改接收单状态
select cdh.approve_code from cux_po_receive_headers cdh where cdh.receipt_num='';

---到货接收接口推送错误查询
select * from(
select rt.transaction_id,rt.attribute1 kk,cprh.* from cux_po_receive_headers cprh,rcv_transactions rt where cprh.receipt_num=rt.attribute1(+) and cprh.approve_code='APPROVED'  
) a where a.kk is null
;

---送货通知行是否重复查询数据，并匹配到货单
select pha.segment1,pha.creation_date,pha.po_header_id,plla.quantity,plla.quantity_cancelled,plla.quantity_received,cdl.po_header_id,cdl.po_location_id,cdl.nums,cprh.receipt_num
 from po_headers_all pha,po_line_locations_all plla,(
select cdli.po_header_id,cdli.po_location_id,sum(cdli.delivery_count) nums from cux_delivery_lines_info cdli, cux_delivery_headers_info cdhi  where cdhi.del_header_id=cdli.delivery_header_id and cdhi.approve_code='APPROVED' group by cdli.po_header_id,cdli.po_location_id
 ) cdl,cux_po_receive_headers cprh
  where pha.po_header_id=plla.po_header_id
  and plla.line_location_id=cdl.po_location_id
  and pha.authorization_status='APPROVED'
  and pha.TYPE_LOOKUP_CODE='STANDARD'
  and cdl.nums>plla.quantity
  and plla.quantity !=plla.quantity_received
  and pha.po_header_id=cprh.po_header_id(+)
  

select * from CUX_PAYMENT_PROTAL_APPLY_V t;

select * from cux_payment_apply_line cpal where cpal.payment_header_id=602;

select * from cux_check_vendor_account_temp ccva where ccva.vendor_account_id=101;

select * from cux_check_account_line_temp ccal where ccal.vendor_account_id=101 ;

select * from cux_po_receive_headers cprh where cprh.receipt_num='R2017030059';

select * from cux_po_receive_lines cprl where cprl.shipment_line_id=10001

select *　from rcv_transactions rt where rt.transaction_id=12002;



SELECT pha.segment1 "订单号",
       cpha.project_name "项目名称",
       pv.VENDOR_NAME "供应商名称",
       cdh.deliver_code "送货通知单号",
       cdh.creation_date "送货通知单发起时间",
       cdh.expect_arr_date "送货时间",
       cdl.po_order_code "物料编码",
       (select msi.LONG_DESCRIPTION
          from mtl_system_items_fvl msi
         where msi.INVENTORY_ITEM_ID =
               (select pol.item_id
                  from po_lines_all pol
                 where pol.po_line_id =
                       (select polla.po_line_id
                          from po_line_locations_all polla
                         where polla.line_location_id = cdl.po_location_id))
           and rownum = 1) "物料描述",
       cdl.delivery_count "本次送货数量",
       cdl.delivery_count *
       (select pol.unit_price
          from po_lines_all pol
         where pol.po_line_id =
               (select polla.po_line_id
                  from po_line_locations_all polla
                 where polla.line_location_id = cdl.po_location_id)) "送货金额",
       
       (select polla.need_by_date
          from po_line_locations_all polla
         where polla.line_location_id = cdl.po_location_id) "订单需求时间"
  FROM po_headers_all     pha,
       hr_operating_units hou,
       -- hr_operating_units   pro_org,
       hr_employees               he,
       hr_locations_all           hla,
       fnd_lookup_values_vl       plc,
       po_vendors                 pv,
       fnd_lookup_values_vl       flv,
       CUX_PO_HEADERS_ALL         cpha,
       cux_po_confirm_headers_all cpcha,
       cux_delivery_headers_info  cdh,
       cux_delivery_lines_info    cdl
 WHERE hou.organization_id = pha.org_id
   AND he.employee_id = pha.agent_id
   AND flv.lookup_type = 'CUX_PO_DOCUMENTS_TYPE'
   AND flv.lookup_code = pha.type_lookup_code
      -- AND to_char(pro_org.organization_id(+)) = pha.attribute1
   AND hla.location_id = pha.ship_to_location_id
   AND plc.lookup_type = 'CUX_DOCUMENTS_STATUS'
   AND plc.lookup_code = (CASE
         WHEN pha.authorization_status IN
              ('APPROVING', 'APPROVED', 'REJECTED') THEN
          pha.authorization_status
         ELSE
          'DRAFT'
       END)
   AND pha.authorization_status = 'APPROVED'
      /*AND    nvl(pha.closed_code, 'OPEN') = 'OPEN'*/
   AND nvl(pha.cancel_flag, 'N') = 'N'
   AND pv.vendor_id = pha.vendor_id
   AND pha.type_lookup_code = 'STANDARD'
   and cpha.po_header_id(+) = pha.po_header_id
   and pha.po_header_id = cpcha.po_header_id(+)
   and pha.revision_num = cpcha.attribute1(+)
   and pha.authorization_status = 'APPROVED'
   and cdh.po_header_id = pha.po_header_id
   and cdh.del_header_id = cdl.delivery_header_id