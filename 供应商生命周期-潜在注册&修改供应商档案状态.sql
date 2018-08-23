--修改供应商档案状态
--'0','未审批','1','审批中','2','审批通过','3','审批驳回'

select cpb.approve_status from cux_ap_base_info cpb  where cpb.company_name='东莞光然光电有限公司' for update


---潜在供应商注册
SELECT r.*
      ,t.*
  FROM cux.cux_pos_supplier_registrations t
      ,cux.cux_regist_vendor_log          r
 WHERE t.supplier_name LIKE '%恒晟%'
   AND r.reg_id(+) = t.reg_id;


--潜在供应商推送 api 的事务记录
SELECT *
  FROM cux.cux_regist_vendor_log t
 WHERE t.reg_id = 4803;