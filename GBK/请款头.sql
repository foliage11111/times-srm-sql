SELECT t.protal_apply_id
      ,t.vendor_name
      ,t.buyer_name
      ,t.payment_type
      ,t.payment_type_name
      ,t.protal_apply_code
      ,decode(t.is_or_no, 'Y', 'ÊÇ', '·ñ') is_or_no
      ,t.approve_state_name
      ,t.payment_amount pay_amount
      ,t.dedu_amount dedu_amount_tax
      ,t.sum_amount sum_amount_tax
      ,to_char(t.settlement_date, 'YYYY-MM-DD') settlement_date
      ,to_char(t.quality_date, 'YYYY-MM-DD') quality_date
      ,to_char(t.apply_date, 'YYYY-MM-DD') apply_date
      ,t.operator_name
      ,t.operator_dept_name
      ,t.operator_job_name
      ,t.protal_desc payment_desc
      ,cf.file_name
      ,to_char(cf.creation_date, 'YYYY-MM-DD') upload_date
      ,(SELECT COUNT(1)
        FROM   cux.cux_reduce_account_temp cal
        WHERE  cal.protal_apply_id = t.protal_apply_id) reduce_count
      ,(SELECT COUNT(1)
        FROM   cux.cux_payment_apply_line cl
        WHERE  cl.payment_header_id = t.protal_apply_id) line_count
FROM   cux_payment_protal_apply_v t
      ,cux_fnd_common_files       cf
WHERE  1 = 1
AND    cf.file_id(+) = t.file_uuid
AND    t.protal_apply_id = 10104
