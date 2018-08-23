SELECT cra.reduce_account_id
      ,cra.reduce_number
      ,to_char(cra.reduce_date, 'yyyy-MM-dd') reduce_date
      ,cra.rate
      ,cra.reduce_amount
      ,cra.reduce_rate_amount
      ,cra.reduce_tax_amount
      ,rownum reduce_line_num
FROM   cux_reduce_account_temp cra
WHERE  1 = 1
AND    cra.vendor_account_id = 1521
