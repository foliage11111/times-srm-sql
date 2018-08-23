 select * from cux.cux_check_vendor_account_temp t where t.check_account_num = 'C2017120167';
 
 select * from cux.cux_payment_apply_line t where t.pro_order_id = 1908;--对账单头id，这里在付款行居然有两个
 
SELECT * FROM CUX.cux_payment_protal_apply t where t.protal_apply_id in (5443,5758);

--有可能因为不对的关联，导致付款申请的前台显示有问题