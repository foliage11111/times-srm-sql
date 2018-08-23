SELECT account1.vendor_account_id
      ,account1.vendor_name
      ,account1.org_name
      ,(CASE
         WHEN account1.count1 = 0
              AND account1.count2 > 0
              AND account1.approvestate = '审批通过' THEN
         
          '已开票'
         ELSE
          '未开票'
       END) flag
      ,account1.check_account_num
      ,account1.receive_tax_amount
      ,account1.check_tax_amount
      ,nvl((account1.check_tax_amount - account1.receive_tax_amount), 0) reduce_tax_amount
      ,account1.phone_number
      ,account1.check_account_date
      ,account1.person_name
      ,account1.department_name
      ,account1.job_name
      ,account1.message
      ,account1.attachment
      , --文件ID 
       account1.file_name
      ,account1.upload_date
      ,account1.approve_code
      ,account1.approvestate
      ,(SELECT COUNT(1)
        FROM   cux.cux_reduce_account_temp cal
        WHERE  cal.vendor_account_id = account1.vendor_account_id) reduce_count
      ,(SELECT COUNT(1)
        FROM   cux.cux_check_account_line_temp cal
        WHERE  cal.vendor_account_id = account1.vendor_account_id) line_count
FROM   (SELECT ccva.vendor_account_id
              ,ccva.check_account_num
              ,ccva.vendor_id
              ,ccva.vendor_name
              ,ccva.org_id
              ,ccva.org_name
              ,ccva.check_amount
              ,ccva.check_tax_amount
              ,ccva.receive_amount
              ,ccva.receive_tax_amount
              ,ccva.reduce_amount reduceamount2
              ,to_char(ccva.check_account_date, 'yyyy-MM-dd') check_account_date
              ,ccva.person_id
              ,ccva.person_name
              ,ccva.department_name
              ,ccva.job_name
              ,ccva.phone_number
              ,ccva.message
              ,ccva.attachment
              , --文件ID 
               cf.file_name
              ,to_char(cf.creation_date, 'yyyy-MM-dd') upload_date
              ,ccva.approve_code
              ,flv.meaning approvestate
              ,(SELECT COUNT(1)
                FROM   cux_invoice_lines_all         cill
                      ,cux_invoice_headers_all       ciha
                      ,cux_check_vendor_account_temp ccva2
                WHERE  cill.approve_code <> 'APPROVED'
                AND    cill.invoice_header_id = ciha.invoice_header_id
                AND    ccva2.vendor_account_id = ccva.vendor_account_id
                AND    ciha.vendor_account_id = ccva.vendor_account_id) count1
              , --发票行未审批数
               (SELECT COUNT(1)
                FROM   cux_invoice_lines_all         cill
                      ,cux_invoice_headers_all       ciha
                      ,cux_check_vendor_account_temp ccva2
                WHERE  1 = 1
                AND    cill.invoice_header_id = ciha.invoice_header_id
                AND    ccva2.vendor_account_id = ccva.vendor_account_id
                AND    ciha.vendor_account_id = ccva.vendor_account_id) count2 --发票行数
        FROM   cux_check_vendor_account_temp ccva
              ,fnd_lookup_values             flv
              ,cux.cux_fnd_common_files      cf
        WHERE  1 = 1
        AND    flv.lookup_type(+) = 'CUX_DOCUMENTS_STATUS'
        AND    flv.language(+) = userenv('LANG')
        AND    flv.lookup_code(+) = ccva.approve_code
        AND    ccva.attachment = cf.file_id(+)) account1
WHERE  1 = 1
AND    account1.vendor_account_id = 1521
