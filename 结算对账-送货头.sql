SELECT cpb.project_name project_name,
       pha.segment1 po_order_num,
       cdhi.deliver_code,
       pha.blanket_number blanket_name,
       hou1.name organization_name,
       pha.vendor_name suply_vendor_name,
       cdhi.deliver_contact suply_contact_name,
       cdhi.phone_num suply_contact_phone,
       cpb.project_block_name,
       cpb.vendor_name user_vendor_name,
       pha.const_name user_contact_name,
       pha.const_phone_num user_contact_phone,
       pha.org_name project_org_name,
       cpb.contract_name,
       pha.full_name contact_name,
       pha.oper_phone_num contact_phone,
       cpb.faddress,
       cdhi.remark,
       to_char(pha.creation_date, 'YYYY-MM-DD') creation_date,
       to_char(nvl(cdhi.upd_revice_date, cdhi.expect_arr_date),
               'YYYY-MM-DD') expect_arr_date,
       (select count(1)
          from cux_delivery_lines_info cdli
         where cdli.delivery_header_id = cdhi.del_header_id) row_count
  FROM cux_delivery_headers_info cdhi,
       fnd_user fu,
       hr_employees he,
       hr_operating_units hou1,
       hr_operating_units hou2,
       (select ph.po_header_id,
               ph.segment1,
               ph.org_id,
               ph.attribute1,
               cph.oper_phone_num,
               cph.const_name,
               cph.const_phone_num,
               hou.name            org_name,
               he.full_name,
               pv.vendor_name,
               ph.creation_date,
               ag.segment1         blanket_number
          from po_headers_all      ph,
               cux_pr_plan_headers cph,
               hr_operating_units  hou,
               fnd_user            fu,
               hr_employees        he,
               po_vendors          pv,
               po_headers_all      ag
         where EXISTS
         (SELECT 1
                  FROM po_lines_all pla, cux_pr_plan_lines cpl
                 WHERE cpl.line_id = pla.attribute5
                   AND cpl.header_id = cph.header_id
                   AND pla.po_header_id = ph.po_header_id
                   and ag.po_header_id = cpl.ag_header_id)
           and hou.organization_id = cph.org_id
           and he.employee_id = fu.employee_id
           and fu.user_id = cph.operator_id
           and pv.vendor_id = ph.vendor_id
           AND ph.type_lookup_code = 'STANDARD'
           AND nvl(ph.closed_code, 'OPEN') = 'OPEN'
           AND nvl(ph.cancel_flag, 'N') = 'N'
           AND nvl(ph.authorization_status, 'INCOMPLETE') = 'APPROVED') pha,
       (SELECT pla.po_line_id,
               pla.po_header_id,
               pla.attribute1 project_id,
               wpt.fname project_name,
               pla.attribute2 project_block_id,
               wpb.fname project_block_name,
               pla.attribute3 contract_id,
               wct.fname contract_name,
               pv.vendor_name,
               wpt.faddress,
               row_number() over(PARTITION BY pla.po_header_id ORDER BY pla.po_header_id, pla.attribute3 NULLS LAST) row_num
          FROM po_lines_all pla,
               wbd.wbd_project_t wpt,
               (SELECT wpbt.fpbno, wpbt.fname
                  FROM wbd.wbd_project_t wpt, wbd_projectblock_t wpbt
                 WHERE wpt.fiseffective = '1'
                   AND wpt.fprjid = wpbt.fprjid) wpb,
               wpc.wpc_contract_t wct,
               po_vendors pv
         WHERE wpt.fiseffective(+) = '1'
           AND wpt.fprjno(+) = pla.attribute1
           AND wpb.fpbno(+) = pla.attribute2
           AND wct.fconid(+) = pla.attribute3
           AND wct.fsecondparty = pv.vendor_id(+)) cpb
 WHERE cdhi.po_header_id = pha.po_header_id
   AND cdhi.created_by = fu.user_id(+)
   AND fu.employee_id = he.employee_id(+)
   AND pha.org_id = hou1.organization_id(+)
   AND pha.attribute1 = hou2.organization_id(+)
   AND cpb.po_header_id = pha.po_header_id
   and cpb.row_num = 1
   and cdhi.del_header_id = 6101
