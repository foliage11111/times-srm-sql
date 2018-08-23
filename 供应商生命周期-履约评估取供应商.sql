--题头
SELECT DISTINCT cdhv.vendor_id
               ,pv.vendor_name vendor_name
               ,pv.segment1 vendor_code
               ,pv.attribute3
               ,(SELECT flv.meaning
                 FROM   fnd_lookup_values flv
                 WHERE  flv.lookup_type(+) = 'CUX_VENDOR_STATUS'
                 AND    flv.language(+) = userenv('LANG')
                 AND    flv.enabled_flag(+) = 'Y'
                 AND    flv.lookup_code(+) = pv.attribute3) vendor_state
               ,cspq.vendor_category_dsp
FROM   cux_po_headers_v cdhv
      ,wbd.wbd_projectblock_t wpt
      ,wbd.wbd_project_t wpb
      ,po_vendors pv
      ,(SELECT cpsqi.vendor_id
              ,cpsqi.vendor_type vendor_category
              ,flv1.meaning      vendor_category_dsp
        FROM   cux_pos_sup_qualif_info cpsqi
              ,ap_suppliers            affiliate
              ,fnd_lookup_values_vl    flv1
        WHERE  affiliate.vendor_id(+) = cpsqi.affiliated_vendor_id
        AND    flv1.lookup_type(+) = 'CUX_FILE_SUPPLIER_TYPE'
        AND    flv1.lookup_code(+) = cpsqi.vendor_type) cspq
WHERE  1 = 1
AND    cdhv.org_id = 2253
      /*AND    cprh.approve_code = 'APPROVED'*/
AND    wpt.fpbno = cdhv.project_block_id
AND    wpt.fprjid = wpb.fprjid
AND    wpb.fiseffective = '1'
AND    cdhv.vendor_id = pv.vendor_id
AND    to_char(cdhv.last_delivery_date, 'yyyy-mm') >= to_char('2018-01')
AND    to_char(cdhv.last_delivery_date, 'yyyy-mm') <= to_char('2018-03')
AND    cspq.vendor_id(+) = cdhv.vendor_id
AND    cspq. vendor_category = 2
;



--行信息--这个供应商供货过的项目。
SELECT DISTINCT cdhv.project_block_id attribute2
               ,wpt.fname
               ,wpt.fnumber
               ,cdhv.vendor_id
FROM   cux_po_headers_v       cdhv
      ,wbd.wbd_projectblock_t wpt
      ,wbd.wbd_project_t      wpb
WHERE  1 = 1
AND    cdhv.org_id = 2253
/*AND    cdhv.applyment_status = 'APPROVED'*/
AND    wpt.fpbno = cdhv.project_block_id
AND    wpt.fprjid = wpb.fprjid
AND    wpb.fiseffective = '1'
AND    to_char(cdhv.last_delivery_date, 'yyyy-mm') >= '2018-01'
AND    to_char(cdhv.last_delivery_date, 'yyyy-mm') <= '2018-03'
AND    EXISTS
 (SELECT 1
        FROM   (SELECT cpsqi.vendor_id
                      ,cpsqi.vendor_type vendor_category
                      ,flv1.meaning      vendor_category_dsp
                FROM   cux_pos_sup_qualif_info cpsqi
                      ,ap_suppliers            affiliate
                      ,fnd_lookup_values_vl    flv1
                WHERE  affiliate.vendor_id(+) = cpsqi.affiliated_vendor_id
                AND    flv1.lookup_type(+) = 'CUX_FILE_SUPPLIER_TYPE'
                AND    flv1.lookup_code(+) = cpsqi.vendor_type)
        WHERE  vendor_id = cdhv.vendor_id
       -- AND    vendor_category = :3
				)
				;