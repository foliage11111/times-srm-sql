--修改送货通知单状态
--DRAFT草稿  APPROVING审批中   APPROVED审批通过   REJECTED审批驳回
select cdh.approve_code from cux_delivery_headers_info cdh where cdh.deliver_code='D2017030002' for update

--修改接收单状态
select cdh.approve_code from cux_po_receive_headers cdh where cdh.receipt_num=''
