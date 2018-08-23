SELECT  hou.name org_name
              ,wc.fnumber
              ,wc.fname
              ,wc.fblocknumber
              ,wc.fblockname
              ,wc.fprojectnumber
              ,wc.fprojectname
              ,person.person_name
              ,houv.name depart_name
              ,hap.position_name
              ,cuxprplanheaderseo.header_id
            --  ,cuxprplanheaderseo.org_id
            --  ,cuxprplanheaderseo.contract_id
              ,cuxprplanheaderseo.plan_number
              ,cuxprplanheaderseo.plan_name
              ,decode(cuxprplanheaderseo.plan_type,'ADD_ORDERS',','SPOT_CHECK_ORDERS',','')
              ,cuxprplanheaderseo.plan_category
              ,cuxprplanheaderseo.plan_year
              ,cuxprplanheaderseo.plan_month
              ,cuxprplanheaderseo.plan_status
              ,cuxprplanheaderseo.operator_id
              ,cuxprplanheaderseo.operator_department
              ,cuxprplanheaderseo.operator_position
     
              ,cuxprplanheaderseo.version_num
              ,cuxprplanheaderseo.created_by
              ,cuxprplanheaderseo.creation_date
              ,cuxprplanheaderseo.last_update_login
              ,cuxprplanheaderseo.last_update_by
              ,cuxprplanheaderseo.last_update_date
              ,cuxprplanheaderseo.attribute_category
              ,cuxprplanheaderseo.attribute1
              ,cuxprplanheaderseo.attribute2
           
              ,cuxprplanheaderseo.add_order_date
              ,to_char(cuxprplanheaderseo.creation_date, 'yyyy-mm-dd') create_dates
             
              ,plantype.meaning plan_type_name
              ,plancate.meaning plan_cate_name
              ,planstatus.meaning plan_status_name
              ,round(sm.sum_money, 2) sum_money
              ,(SELECT pv.vendor_name
                FROM  po_vendors pv
                WHERE  pv.vendor_id = wc.fsecondparty) const_vendor_name
              ,(CASE
                 WHEN cuxprplanheaderseo.plan_status IN ('DRAFT', 'REJECT')
                      AND fnd_global.org_id= cuxprplanheaderseo.attribute1 THEN
                  'OK_UPDATE'
                 ELSE
                  'NO_UPDATE'
               END) update_flag
              ,(CASE
                 WHEN cuxprplanheaderseo.plan_status IN ('DRAFT', 'REJECT')
                      AND fnd_global.org_id= cuxprplanheaderseo.attribute1 THEN
                  'OK_DELETE'
                 ELSE
                  'NO_DELETE'
               END) delete_flag
              ,(CASE
                 WHEN cuxprplanheaderseo.plan_status IN ('DRAFT', 'REJECT')
                      AND fnd_global.org_id= cuxprplanheaderseo.attribute1 THEN
                  'OK_SUBMIT'
                 ELSE
                  'NO_SUBMIT'
               END) submit_flag /*,(CASE WHEN cuxprplanheaderseo.plan_status IN ('APPROVED', 'PARTORDER') THEN 'OK_ORDER' ELSE 'NO_ORDER' END) order_flag*/
              ,decode((SELECT t.attribute13
                      FROM  hr_all_organization_units t
                      WHEREt.organization_id= 2253),
                      NULL,
                      'true',
                      'N',
                      'true',
                      'false') org_rendered
              ,decode((SELECT t.attribute13
                      FROM  hr_all_organization_units t
                      WHEREt.organization_id= 2253),
                      NULL,
                      'false',
                      'N',
                      'false',
                      'true') org_rendered2
              ,(CASE
                 WHEN cuxprplanheaderseo.plan_status = 'DRAFT' THEN
                  'NO_HISTORY'
                 ELSE
                  'OK_HISTORY'
               END) history_flag
              ,(CASE
                 WHEN cuxprplanheaderseo.plan_status = 'APPROVING'
                      AND fnd_global.org_id= cuxprplanheaderseo.attribute1 THEN
                  'OK_ABORT'
                 ELSE
                  'NO_ABORT'
               END) abort_flag
              ,(CASE
                 WHEN cuxprplanheaderseo.version_num =
                      (SELECT MAX(cph.version_num)
                       FROM  cux_pr_plan_headers cph
                       WHERE  cph.plan_number = cuxprplanheaderseo.plan_number) THEN
                  CASE
                    WHEN cuxprplanheaderseo.plan_status IN
                         ('APPROVED', 'ORDERED') THEN
                     'OK_CHANGE'
                    ELSE
                     'NO_CHANGE'
                  END
                 ELSE
                  'NO_CHANGE'
               END) init_change_flag
              ,(CASE
                 WHEN ((SELECT COUNT(1)
                        FROM  cux_pr_plan_headers cphc
                        WHERE  cphc.plan_number =
                               cuxprplanheaderseo.plan_number
                        AND    cphc.plan_status = 'ORDERED') > 0 AND
                      cuxprplanheaderseo.plan_status IN ('APPROVED')) THEN
                  'OK_CHANGE_ORDER'
                 ELSE
                  'NO_CHANGE_ORDER'
               END) change_order_flag
              ,(CASE
                 WHEN (cuxprplanheaderseo.plan_status IN
                      ('APPROVED', 'PARTORDER') AND
                      (SELECT COUNT(1)
                        FROM  cux_pr_plan_headers cphc
                        WHERE  cphc.plan_number =
                               cuxprplanheaderseo.plan_number
                        AND    cphc.plan_status IN ('ORDERED', 'APPROVING')) = 0) THEN
                  'OK_ORDER'
                 ELSE
                  'NO_ORDER'
               END) order_flag
        FROM  cux_pr_plan_headers cuxprplanheaderseo
              ,hr_operating_units hou
              ,(SELECT wct.fconid
                      ,wct.fnumber
                      ,wct.fname
                      ,a.fprjno
                      ,b.fpbno
                      ,b.fnumber        fblocknumber
                      ,b.fname          fblockname
                      ,a.fnumber        fprojectnumber
                      ,a.fname          fprojectname
                      ,wct.fsecondparty
                FROM  wbd.wbd_project_t      a
                      ,wbd.wbd_projectblock_t b
                      ,wpc.wpc_contract_t     wct
                WHERE  wct.fpbno = b.fpbno
                AND    wct.fprjno = a.fprjno
                AND    a.fprjid = b.fprjid
                AND    a.fiseffective = '1') wc
              ,hr_organization_units_v houv
              ,(SELECT ap.position_id
                      ,ap.name position_name
                FROM  hr_all_positions_f ap
                WHERE  ap.effective_start_date <= SYSDATE
                AND    ap.effective_end_date >= SYSDATE) hap
              ,(SELECT hr.last_name person_name
                      ,fu.user_id
                FROM  hr_employees hr
                      ,fnd_user     fu
                WHERE  hr.employee_id = fu.employee_id) person
              ,(SELECT t.lookup_code
                      ,t.meaning
                FROM  fnd_lookup_values_vl t
                WHERE  t.lookup_type = 'CUX_PR_PLAN_TYPE'
                AND    t.enabled_flag = 'Y'
                AND    SYSDATE BETWEEN t.start_date_active AND
                       nvl(t.end_date_active, SYSDATE)) plantype
              ,(SELECT t.lookup_code
                      ,t.meaning
                FROM  fnd_lookup_values_vl t
                WHERE  t.lookup_type = 'CUX_PR_PLAN_CATEGORY'
                AND    t.enabled_flag = 'Y'
                AND    SYSDATE BETWEEN t.start_date_active AND
                       nvl(t.end_date_active, SYSDATE)) plancate
              ,(SELECT t.lookup_code
                      ,t.meaning
                FROM  fnd_lookup_values_vl t
                WHERE  t.lookup_type = 'CUX_PR_PLAN_STATUS'
                AND    t.enabled_flag = 'Y'
                AND    SYSDATE BETWEEN t.start_date_active AND
                       nvl(t.end_date_active, SYSDATE)) planstatus
              ,(SELECT SUM(t1.unit_price * t1.quantity) sum_money
                      ,t1.header_id
                FROM  cux_pr_plan_lines t1
                GROUP  BY t1.header_id) sm
        WHEREcuxprplanheaderseo.org_id=hou.organization_id(+)
        AND    cuxprplanheaderseo.contract_id = wc.fconid(+)
        AND    cuxprplanheaderseo.operator_id = person.user_id(+)
        AND    cuxprplanheaderseo.operator_department =
houv.organization_id(+)
        AND    cuxprplanheaderseo.operator_position = hap.position_id(+)
        AND    cuxprplanheaderseo.plan_type = plantype.lookup_code(+)
        AND    cuxprplanheaderseo.plan_category = plancate.lookup_code(+)
        AND    cuxprplanheaderseo.plan_status = planstatus.lookup_code(+)
        AND    cuxprplanheaderseo.header_id = sm.header_id(+)
        and cuxprplanheaderseo.last_update_date < to_Date('2018/5/10 1:49:50','YYYY-MM-dd HH24:mi:ss')