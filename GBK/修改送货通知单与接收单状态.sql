--�޸��ͻ�֪ͨ��״̬
--DRAFT�ݸ�  APPROVING������   APPROVED����ͨ��   REJECTED��������
select cdh.approve_code from cux_delivery_headers_info cdh where cdh.deliver_code='D2017030002' for update

--�޸Ľ��յ�״̬
select cdh.approve_code from cux_po_receive_headers cdh where cdh.receipt_num=''
