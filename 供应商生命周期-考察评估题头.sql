--考察评估题头查询
select pv.VENDOR_NAME, sih.*
  from cux.cux_slc_inspect_headers sih, po_vendors pv
 where sih.vendor_id = pv.VENDOR_ID
   and pv.VENDOR_NAME like '龙城';
   
--如果vendor_type 为空，会导致查不出来，详细见最下面的查询

   
   
--这些应该是考察评估得分查询
select * from cux_slc_score_dept_header  csd,cux_slc_score_dept_lines sc  where sc.score_header_id = csd.score_header_id 

select * from cux_slc_review_score;

select * from cux.cux_slc_score_headers_all;

---供应商类型快码查询
SELECT flv.lookup_code
FROM   apps.fnd_lookup_values flv
WHERE  flv.lookup_type = 'CUX_FILE_SUPPLIER_TYPE'
AND    flv.language = userenv('LANG')
AND    flv.enabled_flag = 'Y';

select t.LOOKUP_CODE,t.MEANING from apps.fnd_lookup_values_vl t where t.LOOKUP_TYPE = 'CUX_FILE_SUPPLIER_TYPE';

--
--4	供货安装类
--2	供货类
--3	施工类
--1	服务类


---供应商的代码
SELECT cpsi.vendor_id
      ,cpsi.vendor_type
      ,flv.lookup_code
      ,flv.meaning
FROM   cux.cux_pos_sup_qualif_info cpsi
      ,apps.fnd_lookup_values      flv
WHERE  cpsi.vendor_type = flv.lookup_code
AND    flv.lookup_type = 'CUX_FILE_SUPPLIER_TYPE'
AND    flv.language = userenv('LANG')
AND    cpsi.vendor_id = 314518;

---供应商资质表
select * from cux.cux_pos_sup_qualif_info t where t.vendor_id = 314518;




--考察评估题头界面查询 sql
SELECT cuxslcinspectheaderseo.ins_header_id
      ,cuxslcinspectheaderseo.insp_code
      ,cuxslcinspectheaderseo.business_type
      ,cuxslcinspectheaderseo.vendor_id
      ,cuxslcinspectheaderseo.vendor_type
      ,cuxslcinspectheaderseo.insp_template
      ,cuxslcinspectheaderseo.template_id
      ,cuxslcinspectheaderseo.operator_id
      ,cuxslcinspectheaderseo.operator_job
      ,cuxslcinspectheaderseo.operator_dept
      ,cuxslcinspectheaderseo.insp_status
      ,cuxslcinspectheaderseo.insp_desc
      ,cuxslcinspectheaderseo.score_desc
      ,cuxslcinspectheaderseo.score_user
      ,cuxslcinspectheaderseo.public_date
      ,cuxslcinspectheaderseo.score_date
      ,cuxslcinspectheaderseo.score_status
      ,cuxslcinspectheaderseo.total_score
      ,cuxslcinspectheaderseo.valid_date
      ,cuxslcinspectheaderseo.insp_total_score
      ,cuxslcinspectheaderseo.remark
      ,cuxslcinspectheaderseo.creation_date
      ,cuxslcinspectheaderseo.created_by
      ,cuxslcinspectheaderseo.last_updated_by
      ,cuxslcinspectheaderseo.last_update_date
      ,cuxslcinspectheaderseo.last_update_login
      ,cuxslcinspectheaderseo.attribute_category
      ,cuxslcinspectheaderseo.attribute1
      ,cuxslcinspectheaderseo.attribute2
      ,cuxslcinspectheaderseo.attribute3
      ,cuxslcinspectheaderseo.attribute4
      ,cuxslcinspectheaderseo.attribute5
      ,cuxslcinspectheaderseo.attribute6
      ,cuxslcinspectheaderseo.attribute7
      ,cuxslcinspectheaderseo.attribute8
      ,cuxslcinspectheaderseo.attribute9
      ,cuxslcinspectheaderseo.attribute10
      ,cuxslcinspectheaderseo.attribute11
      ,cuxslcinspectheaderseo.attribute12
      ,cuxslcinspectheaderseo.attribute13
      ,cuxslcinspectheaderseo.attribute14
      ,cuxslcinspectheaderseo.attribute15
    
FROM   cux.cux_slc_inspect_headers cuxslcinspectheaderseo
      ,apps.fnd_lookup_values flv
      ,apps.po_vendors pv
      ,cux.cux_slc_template_header csth
      ,(SELECT ffv.flex_value
              ,ffv.description
        FROM   apps.fnd_flex_value_sets ffvs
              ,apps.fnd_flex_values_vl  ffv
        WHERE  ffvs.flex_value_set_name = 'CUX_BUSINESS_CATEGORY'
        AND    ffvs.flex_value_set_id = ffv.flex_value_set_id
        AND    ffv.enabled_flag = 'Y') buscate
      ,(SELECT fu.user_id
              ,fu.user_name
              ,fu.employee_id
              ,he.employee_num
              ,he.full_name
        FROM  apps. fnd_user     fu
              ,apps.hr_employees he
        WHERE  fu.employee_id = he.employee_id(+)) phe
      ,apps.hr_all_organization_units haou
      ,(SELECT ap.position_id
              ,ap.name position_name
        FROM   apps.hr_all_positions_f ap
        WHERE  ap.effective_start_date <= SYSDATE
        AND    ap.effective_end_date >= SYSDATE) hpf
  /*    ,(SELECT fu.user_id
              ,fu.user_name
              ,fu.employee_id
              ,he.employee_num
              ,he.full_name
        FROM   apps.fnd_user     fu
              ,apps.hr_employees he
        WHERE  fu.employee_id = he.employee_id(+)) phe1*/
      ,(SELECT cpsi.vendor_id
              ,cpsi.vendor_type
              ,flv.lookup_code
              ,flv.meaning
        FROM   cux.cux_pos_sup_qualif_info cpsi
              ,apps.fnd_lookup_values       flv
        WHERE  cpsi.vendor_type = flv.lookup_code
        AND    flv.lookup_type = 'CUX_FILE_SUPPLIER_TYPE'
        AND    flv.language = userenv('LANG')) ventype
WHERE  nvl((nvl(nvl((SELECT cssp.submit_status
                    FROM   cux.cux_slc_score_person cssp
                          ,apps.fnd_user             fu
                    WHERE  cssp.insp_header_id =
                           cuxslcinspectheaderseo.ins_header_id
                    AND    cssp.score_user = fu.employee_id
                   /* AND    fu.user_id = fnd_global.user_id*/
                    AND    rownum = 1),
                    (SELECT cssp.submit_status
                     FROM   cux.cux_slc_score_person cssp
                           ,apps.fnd_user             fu
                     WHERE  cssp.insp_header_id =
                            cuxslcinspectheaderseo.ins_header_id
                     AND    cssp.trans_user = fu.employee_id
                    /* AND    fu.user_id = fnd_global.user_id*/
                     AND    rownum = 1)),
                nvl((SELECT cssl.submit_status
                    FROM   cux.cux_slc_score_dept_header cssh
                          ,cux.cux_slc_score_dept_lines  cssl
                          ,apps.fnd_user                  fu
                    WHERE  cssh.insp_header_id =
                           cuxslcinspectheaderseo.ins_header_id
                    AND    cssh.score_header_id = cssl.score_header_id
                    AND    cssl.score_user = fu.employee_id
                   /* AND    fu.user_id = fnd_global.user_id*/
                    AND    rownum = 1),
                    (SELECT cssl.submit_status
                     FROM   cux.cux_slc_score_dept_header cssh
                           ,cux.cux_slc_score_dept_lines  cssl
                           ,apps.fnd_user                  fu
                     WHERE  cssh.insp_header_id =
                            cuxslcinspectheaderseo.ins_header_id
                     AND    cssh.score_header_id = cssl.score_header_id
                     AND    cssl.trans_user = fu.employee_id
                     /*AND    fu.user_id = fnd_global.user_id*/
                     AND    rownum = 1)))),
           cuxslcinspectheaderseo.score_status) = flv.lookup_code
AND    flv.lookup_type = 'CUX_SLC_INS_STATUS'
AND    flv.enabled_flag = 'Y'
AND    flv.language = userenv('LANG')
AND    cuxslcinspectheaderseo.vendor_id = pv.vendor_id
AND    cuxslcinspectheaderseo.template_id = csth.temple_header_id
AND    cuxslcinspectheaderseo.business_type = buscate.flex_value
AND    pv.vendor_id = ventype.vendor_id
AND    EXISTS
 (SELECT flv.lookup_code
        FROM  apps.fnd_lookup_values flv
        WHERE  flv.lookup_type = 'CUX_FILE_SUPPLIER_TYPE'
        AND    flv.language = userenv('LANG')
        AND    flv.enabled_flag = 'Y'
        AND    flv.lookup_code = ventype.vendor_type)
      /*AND    cuxslcinspectheaderseo.vendor_type = ventype.vendor_type*/
AND    cuxslcinspectheaderseo.operator_id = phe.user_id(+)
AND    haou.organization_id = cuxslcinspectheaderseo.operator_dept
AND    hpf.position_id(+) = cuxslcinspectheaderseo.operator_job
/*AND    cuxslcinspectheaderseo.score_user = phe1.user_id(+)*/
AND    cuxslcinspectheaderseo.insp_status <> 'DRAFT'
AND    ((SELECT COUNT(1)
         FROM   cux.cux_slc_score_person scc
               ,apps.fnd_user             fu
         WHERE  scc.insp_header_id = cuxslcinspectheaderseo.ins_header_id
         AND    fu.employee_id = scc.score_user
         /*AND    fu.user_id = fnd_global.user_id*/) > 0 OR
        (SELECT COUNT(1)
         FROM   cux.cux_slc_score_person scc
               ,apps.fnd_user             fu
         WHERE  scc.insp_header_id = cuxslcinspectheaderseo.ins_header_id
         AND    fu.employee_id = scc.trans_user
         /*AND    fu.user_id = fnd_global.user_id*/) > 0 OR
        (SELECT COUNT(1)
         FROM   cux.cux_slc_score_dept_lines  sc
               ,cux.cux_slc_score_dept_header csd
               ,apps.fnd_user                  fu
         WHERE  sc.score_header_id = csd.score_header_id
         AND    csd.insp_header_id = cuxslcinspectheaderseo.ins_header_id
         AND    fu.employee_id = sc.score_user
         /*AND    fu.user_id = fnd_global.user_id*/) > 0 OR
        (SELECT COUNT(1)
         FROM   cux.cux_slc_score_dept_lines  sc
               ,cux.cux_slc_score_dept_header csd
               ,apps.fnd_user                  fu
         WHERE  sc.score_header_id = csd.score_header_id
         AND    csd.insp_header_id = cuxslcinspectheaderseo.ins_header_id
         AND    fu.employee_id = sc.trans_user
         /*AND    fu.user_id = fnd_global.user_id*/) > 0)
        -- and cuxslcinspectheaderseo.vendor_type is null
order by cuxslcinspectheaderseo.ins_header_id desc



----不要 vendor_type 的控制后的查询内容
SELECT cuxslcinspectheaderseo.ins_header_id
      ,cuxslcinspectheaderseo.insp_code
      ,cuxslcinspectheaderseo.business_type
      ,cuxslcinspectheaderseo.vendor_id
      ,cuxslcinspectheaderseo.vendor_type
      ,cuxslcinspectheaderseo.insp_template
      ,cuxslcinspectheaderseo.template_id
      ,cuxslcinspectheaderseo.operator_id
      ,cuxslcinspectheaderseo.operator_job
      ,cuxslcinspectheaderseo.operator_dept
      ,cuxslcinspectheaderseo.insp_status
      ,cuxslcinspectheaderseo.insp_desc
      ,cuxslcinspectheaderseo.score_desc
      ,cuxslcinspectheaderseo.score_user
      ,cuxslcinspectheaderseo.public_date
      ,cuxslcinspectheaderseo.score_date
      ,cuxslcinspectheaderseo.score_status
      ,cuxslcinspectheaderseo.total_score
      ,cuxslcinspectheaderseo.valid_date
      ,cuxslcinspectheaderseo.insp_total_score
      ,cuxslcinspectheaderseo.remark
      ,cuxslcinspectheaderseo.creation_date
      ,cuxslcinspectheaderseo.created_by
      ,cuxslcinspectheaderseo.last_updated_by
      ,cuxslcinspectheaderseo.last_update_date
      ,cuxslcinspectheaderseo.last_update_login
      ,cuxslcinspectheaderseo.attribute_category
      ,cuxslcinspectheaderseo.attribute1
      ,cuxslcinspectheaderseo.attribute2
      ,cuxslcinspectheaderseo.attribute3
      ,cuxslcinspectheaderseo.attribute4
      ,cuxslcinspectheaderseo.attribute5
      ,cuxslcinspectheaderseo.attribute6
      ,cuxslcinspectheaderseo.attribute7
      ,cuxslcinspectheaderseo.attribute8
      ,cuxslcinspectheaderseo.attribute9
      ,cuxslcinspectheaderseo.attribute10
      ,cuxslcinspectheaderseo.attribute11
      ,cuxslcinspectheaderseo.attribute12
      ,cuxslcinspectheaderseo.attribute13
      ,cuxslcinspectheaderseo.attribute14
      ,cuxslcinspectheaderseo.attribute15

FROM   cux.cux_slc_inspect_headers cuxslcinspectheaderseo
      ,apps.fnd_lookup_values flv
      ,apps.po_vendors pv
      ,cux.cux_slc_template_header csth
      ,(SELECT ffv.flex_value
              ,ffv.description
        FROM   apps.fnd_flex_value_sets ffvs
              ,apps.fnd_flex_values_vl  ffv
        WHERE  ffvs.flex_value_set_name = 'CUX_BUSINESS_CATEGORY'
        AND    ffvs.flex_value_set_id = ffv.flex_value_set_id
        AND    ffv.enabled_flag = 'Y') buscate
      ,(SELECT fu.user_id
              ,fu.user_name
              ,fu.employee_id
              ,he.employee_num
              ,he.full_name
        FROM   apps.             fnd_user fu
              ,apps.hr_employees he
        WHERE  fu.employee_id = he.employee_id(+)) phe
      ,apps.hr_all_organization_units haou
      ,(SELECT ap.position_id
              ,ap.name position_name
        FROM   apps.hr_all_positions_f ap
        WHERE  ap.effective_start_date <= SYSDATE
        AND    ap.effective_end_date >= SYSDATE) hpf
      ,(SELECT fu.user_id
              ,fu.user_name
              ,fu.employee_id
              ,he.employee_num
              ,he.full_name
        FROM   apps.fnd_user     fu
              ,apps.hr_employees he
        WHERE  fu.employee_id = he.employee_id(+)) phe1
/* ,(SELECT cpsi.vendor_id
      ,cpsi.vendor_type
      ,flv.lookup_code
      ,flv.meaning
FROM   cux.cux_pos_sup_qualif_info cpsi
      ,apps.fnd_lookup_values      flv
WHERE  cpsi.vendor_type = flv.lookup_code
AND    flv.lookup_type = 'CUX_FILE_SUPPLIER_TYPE'
AND    flv.language = userenv('LANG')) ventype*/
WHERE  1 = 1
AND    nvl((nvl(nvl((SELECT cssp.submit_status
                    FROM   cux.cux_slc_score_person cssp
                          ,apps.fnd_user            fu
                    WHERE  cssp.insp_header_id =
                           cuxslcinspectheaderseo.ins_header_id
                    AND    cssp.score_user = fu.employee_id
                          /* AND    fu.user_id = fnd_global.user_id*/
                    AND    rownum = 1),
                    (SELECT cssp.submit_status
                     FROM   cux.cux_slc_score_person cssp
                           ,apps.fnd_user            fu
                     WHERE  cssp.insp_header_id =
                            cuxslcinspectheaderseo.ins_header_id
                     AND    cssp.trans_user = fu.employee_id
                           /* AND    fu.user_id = fnd_global.user_id*/
                     AND    rownum = 1)),
                nvl((SELECT cssl.submit_status
                    FROM   cux.cux_slc_score_dept_header cssh
                          ,cux.cux_slc_score_dept_lines  cssl
                          ,apps.fnd_user                 fu
                    WHERE  cssh.insp_header_id =
                           cuxslcinspectheaderseo.ins_header_id
                    AND    cssh.score_header_id = cssl.score_header_id
                    AND    cssl.score_user = fu.employee_id
                          /* AND    fu.user_id = fnd_global.user_id*/
                    AND    rownum = 1),
                    (SELECT cssl.submit_status
                     FROM   cux.cux_slc_score_dept_header cssh
                           ,cux.cux_slc_score_dept_lines  cssl
                           ,apps.fnd_user                 fu
                     WHERE  cssh.insp_header_id =
                            cuxslcinspectheaderseo.ins_header_id
                     AND    cssh.score_header_id = cssl.score_header_id
                     AND    cssl.trans_user = fu.employee_id
                           /*AND    fu.user_id = fnd_global.user_id*/
                     AND    rownum = 1)))),
           cuxslcinspectheaderseo.score_status) = flv.lookup_code
AND    flv.lookup_type = 'CUX_SLC_INS_STATUS'
AND    flv.enabled_flag = 'Y'
AND    flv.language = userenv('LANG')
AND    cuxslcinspectheaderseo.vendor_id = pv.vendor_id
AND    cuxslcinspectheaderseo.template_id = csth.temple_header_id
AND    cuxslcinspectheaderseo.business_type = buscate.flex_value
/*AND    pv.vendor_id = ventype.vendor_id*/
/*AND    EXISTS
 (SELECT flv.lookup_code
        FROM   apps.fnd_lookup_values flv
        WHERE  flv.lookup_type = 'CUX_FILE_SUPPLIER_TYPE'
        AND    flv.language = userenv('LANG')
        AND    flv.enabled_flag = 'Y'
        AND    flv.lookup_code = ventype.vendor_type)*/
      /*AND    cuxslcinspectheaderseo.vendor_type = ventype.vendor_type*/
AND    cuxslcinspectheaderseo.operator_id = phe.user_id(+)
AND    haou.organization_id = cuxslcinspectheaderseo.operator_dept
AND    hpf.position_id(+) = cuxslcinspectheaderseo.operator_joba
AND    cuxslcinspectheaderseo.score_user = phe1.user_id(+)
AND    cuxslcinspectheaderseo.insp_status <> 'DRAFT'
AND    ((SELECT COUNT(1)
         FROM   cux.cux_slc_score_person scc
               ,apps.fnd_user            fu
         WHERE  scc.insp_header_id = cuxslcinspectheaderseo.ins_header_id
         AND    fu.employee_id = scc.score_user
         /*AND    fu.user_id = fnd_global.user_id*/
         ) > 0 OR
      (SELECT COUNT(1)
         FROM   cux.cux_slc_score_person scc
               ,apps.fnd_user            fu
         WHERE  scc.insp_header_id = cuxslcinspectheaderseo.ins_header_id
         AND    fu.employee_id = scc.trans_user
         /*AND    fu.user_id = fnd_global.user_id*/
         ) > 0 OR
      (SELECT COUNT(1)
         FROM   cux.cux_slc_score_dept_lines  sc
               ,cux.cux_slc_score_dept_header csd
               ,apps.fnd_user                 fu
         WHERE  sc.score_header_id = csd.score_header_id
         AND    csd.insp_header_id = cuxslcinspectheaderseo.ins_header_id
         AND    fu.employee_id = sc.score_user
         /*AND    fu.user_id = fnd_global.user_id*/
         ) > 0 OR
      (SELECT COUNT(1)
         FROM   cux.cux_slc_score_dept_lines  sc
               ,cux.cux_slc_score_dept_header csd
               ,apps.fnd_user                 fu
         WHERE  sc.score_header_id = csd.score_header_id
         AND    csd.insp_header_id = cuxslcinspectheaderseo.ins_header_id
         AND    fu.employee_id = sc.trans_user
         /*AND    fu.user_id = fnd_global.user_id*/
         ) > 0)
ORDER  BY cuxslcinspectheaderseo.ins_header_id DESC
