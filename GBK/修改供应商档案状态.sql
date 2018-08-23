--修改供应商档案状态
--'0','未审批','1','审批中','2','审批通过','3','审批驳回'

select cpb.approve_status from cux_ap_base_info cpb  where cpb.company_name='东莞光然光电有限公司' for update
