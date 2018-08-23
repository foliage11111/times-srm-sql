create or replace package body CUX_QUERY_PO_HEADERS_PKG is
  -- Author  : 
  -- Created : 
  -- Purpose : 将采购订单信息插入到临时表（时刻刷新）

  g_Pkg_Name Constant Varchar2(30) := 'CUX_QUERY_PO_HEADERS_PKG';

  Procedure Log_Msg(p_Msg In Varchar2) Is
  Begin
    Fnd_File.Put_Line(Fnd_File.Log, p_Msg);
  End Log_Msg;

  Procedure Out_Msg(p_Msg In Varchar2) Is
  Begin
    Fnd_File.Put_Line(Fnd_File.Output, p_Msg);
  End Out_Msg;

  Procedure Raise_Exception(p_Return_Status Varchar2) Is
  Begin
    If (p_Return_Status = Fnd_Api.g_Ret_Sts_Unexp_Error) Then
      Raise Fnd_Api.g_Exc_Unexpected_Error;
    Elsif (p_Return_Status = Fnd_Api.g_Ret_Sts_Error) Then
      Raise Fnd_Api.g_Exc_Error;
    End If;
  End Raise_Exception;

  /* =============================================
  *   PROCEDURE
  *   NAME :MAIN
  *
  *   DESCRIPTION:主程序
  *
  *   ARGUMENT:
  *
  *   RETURN:
  *
  *   HISTORY:
  *
  * =============================================*/
  Procedure Main(Errbuf Out Varchar2, Retcode Out Varchar2) Is
    cursor csr_po is
         SELECT pha.po_header_id,
             pha.segment1 po_number,
             pha.org_id,
             hou.name org_name,
             pha.agent_id,
             he.full_name agent_name,
             pha.type_lookup_code,
             flv.meaning type_meaning,
             pha.attribute1 project_org_id,
             pro_org.name project_org_name,
             pha.currency_code,
             decode(pha.type_lookup_code,
                    'STANDARD',
                    /*po_core_s.get_total('H', pha.po_header_id)*/
                    round(line.total_tax_amount, 2),
                    NULL) total_amount,
             pll.need_by_date last_delivery_date,
             to_char(pll.need_by_date, 'YYYY-MM-DD') last_delivery_date_dsp,
             decode((SELECT COUNT(DISTINCT plla.need_by_date)
                      FROM po_line_locations_all plla
                     WHERE plla.po_header_id = pha.po_header_id),
                    0,
                    '否',
                    1,
                    '否',
                    '是') is_partial_delivery,
             pha.ship_to_location_id,
             hla.location_code ship_to_location_code, /*hr_general.hr_lookup_locations(p_location_id => pha.ship_to_location_id)*/
             wc.faddress ship_to_location_address,
             plc.lookup_code authorization_status,
             plc.meaning authorization_status_dsp,
             flv1.lookup_code delivery_status,
             flv1.meaning delivery_status_dsp,
             flv3.lookup_code applyment_status,
             flv3.meaning applyment_status_dsp,
             flv4.lookup_code invoice_status,
             flv4.meaning invoice_status_dsp,
             flv2.lookup_code receive_status,
             flv2.meaning receive_status_dsp,
             to_char(pha.start_date, 'YYYY-MM-DD') start_date,
             to_char(pha.end_date, 'YYYY-MM-DD') end_date,
             pha.vendor_id,
             pv.segment1 vendor_number,
             saaf_generate_tender_code.getVendorName(pha.po_header_id) vendor_name,
             wc.project_id,
             wc.project_name,
             wc.project_block_id,
             wc.project_block_name,
             wc.contract_id,
             wc.contract_name,
             wc.vendor_id leading_unit_id,
             wc.vendor_name leading_unit_name,
             to_char(pha.creation_date, 'YYYY-MM-DD') order_date,
             (select saaf_generate_tender_code.getOrderRate(pha.po_header_id)
                from dual) orderRate,
             (select saaf_generate_tender_code.getDeliveryRate(pha.po_header_id)
                from dual) deliveryRate,
             order1.person_name, --经办人
             order1.oper_phone_num, --经办人电话
             order1.const_name, --施工方联系人
             order1.const_phone_num, --施工方电话
             order1.spot_prices,
             order1.spot_prices_date,
             wc.vendor_name fsecondpartyname
        FROM po_headers_all pha,
             hr_operating_units hou,
             hr_operating_units pro_org,
             hr_employees he,
             hr_locations_all hla,
             fnd_lookup_values_vl plc,
             po_vendors pv,
             (SELECT pla.po_header_id,
                     pla.attribute1 project_id,
                     wpt.fname project_name,
                     pla.attribute2 project_block_id,
                     wpb.fname project_block_name,
                     pla.attribute3 contract_id,
                     wct.fname contract_name,
                     row_number() over(PARTITION BY pla.po_header_id ORDER BY pla.po_header_id, pla.attribute3 NULLS LAST) row_num,
                     wpt.faddress,
                     ass.vendor_id,
                     ass.vendor_name
                FROM po_lines_all pla,
                     wbd.wbd_project_t wpt,
                     (SELECT wpbt.fpbno, wpbt.fname
                        FROM wbd.wbd_project_t wpt, wbd_projectblock_t wpbt
                       WHERE wpt.fiseffective = '1'
                         AND wpt.fprjid = wpbt.fprjid) wpb,
                     wpc.wpc_contract_t wct,
                     ap_suppliers ass
               WHERE wpt.fiseffective(+) = '1'
                 AND wpt.fprjno(+) = pla.attribute1
                 AND wpb.fpbno(+) = pla.attribute2
                 AND wct.fconid(+) = pla.attribute3
                    /*AND    nvl(pla.closed_code, 'OPEN') = 'OPEN'*/
                 AND nvl(pla.cancel_flag, 'N') = 'N'
                 AND ass.vendor_id = wct.fsecondparty) wc,
             fnd_lookup_values_vl flv,
             fnd_lookup_values_vl flv1,
             fnd_lookup_values_vl flv2,
             fnd_lookup_values_vl flv3,
             fnd_lookup_values_vl flv4,
             (SELECT plla.po_header_id, MAX(plla.need_by_date) need_by_date
                FROM po_line_locations_all plla
               WHERE /*nvl(plla.closed_code, 'OPEN') = 'OPEN'
                                                                                                                                                                                                                                                                      AND*/
               nvl(plla.cancel_flag, 'N') = 'N'
               GROUP BY plla.po_header_id) pll
             /*,(SELECT rt.po_header_id
                   ,MAX(rt.transaction_date) transaction_date
             FROM   rcv_transactions rt
             GROUP  BY rt.po_header_id) rct*/,
             (SELECT pla.po_header_id,
                     SUM(trunc(trunc(nvl(pla.attribute11,(nvl(pla.unit_price, 0) *
             (1 + nvl(zrb.percentage_rate, 0) / 100))),
             4) * nvl(pla.quantity, 0),2)) total_tax_amount--2018头部金额与行汇总金额不一致,改成与行金额汇总一致，不进行四舍五入
                FROM po_lines_all pla, zx_rates_b zrb
               WHERE zrb.tax_rate_id(+) = pla.attribute6
                    /*AND    nvl(pla.closed_code, 'OPEN') = 'OPEN'*/
                 AND nvl(pla.cancel_flag, 'N') = 'N'
               GROUP BY pla.po_header_id) line,
             (SELECT pla.po_header_id, SUM(pla.quantity) total_quantity
                FROM po_lines_all pla
               WHERE nvl(pla.cancel_flag, 'N') = 'N'
               GROUP BY pla.po_header_id) total_line,
             (SELECT cdl.po_header_id,
                     SUM(cdl.delivery_count) total_delivery_quantity
                FROM cux_delivery_lines_info cdl
               WHERE EXISTS
               (SELECT 1
                        FROM cux_delivery_headers_info cdh
                       WHERE cdh.approve_code = 'APPROVED'
                         AND cdh.del_header_id = cdl.delivery_header_id)
               GROUP BY cdl.po_header_id) total_delivery,
             (SELECT crh.po_header_id,
                     SUM(crl.quantity_receiving) total_receive_quantity
                FROM cux.cux_po_receive_headers crh,
                     cux_po_receive_lines       crl
               WHERE crl.shipment_header_id = crh.shipment_header_id
                 AND crh.approve_code = 'APPROVED'
               GROUP BY crh.po_header_id) total_receive,
             (SELECT cpl.pro_order_id po_header_id,
                     SUM(cpl.can_apply_for_tax) total_apply_amount
                FROM cux_payment_apply_line cpl
               WHERE EXISTS
               (SELECT 1
                        FROM cux_payment_protal_apply cph
                       WHERE cph.approve_state = 'APPROVED'
                         AND cph.protal_apply_id = cpl.payment_header_id)
               GROUP BY cpl.pro_order_id) total_apply,
             (SELECT rsl.po_header_id,
                     SUM(rsl.quantity_received) total_invoice_quantity
                FROM cux_check_account_line_temp   ccal,
                     cux_check_vendor_account_temp ccv,
                     rcv_shipment_lines            rsl
               WHERE ccal.receipt_id = rsl.shipment_header_id
                 AND ccal.receipt_line_id = rsl.shipment_line_id
                 AND ccal.vendor_account_id = ccv.vendor_account_id
                 AND ccv.approve_code = 'APPROVED'
               GROUP BY rsl.po_header_id) total_invoice,
             --供货计划
             (select ppf.global_name person_name, --经办人
                  /*   (select poh.po_header_id
                        from po_headers_all poh
                       where 1 = 1
                         and poh.po_header_id =
                             (select pol.po_header_id
                                from po_lines_all pol, cux_pr_plan_lines cppl
                               where pol.attribute5 = cppl.line_id
                                 and cppl.header_id = cpph.header_id
                                 and rownum = 1)) po_header_id,*/
                     ord.po_header_id,
                     cpph.oper_phone_num, --经办人电话
                     cpph.const_name, --施工方联系人
                     cpph.const_phone_num, --施工方电话
                     T1.Fname             contract_name,
                     s_ven.VENDOR_NAME    fsecondpartyname,
                     cpph.spot_prices,
                     to_char(cpph.spot_prices_date,'yyyy-MM-dd') spot_prices_date
                from cux_pr_plan_lines cppl,
                     cux_pr_plan_headers cpph,
                     fnd_user            fu,
                     per_people_f        ppf,
                     /* (SELECT ppf.global_name person_name,
                            hou.organization_id org_id,
                            hou.name depart_name,
                            (SELECT NAME
                               FROM hr_all_positions_f ap
                              WHERE ap.position_id = paa.position_id
                                AND ap.effective_start_date <= SYSDATE
                                AND ap.effective_end_date >= SYSDATE) position_name,
                            paa.person_id,
                            paa.position_id,
                            fu.user_id
                       FROM hr_organization_units_v hou,
                            per_all_assignments_f   paa,
                            per_people_f            ppf,
                            fnd_user                fu
                      WHERE hou.organization_id = paa.organization_id(+)
                        AND paa.person_id = ppf.person_id
                        AND paa.person_id = fu.employee_id
                        AND paa.position_id IS NOT NULL
                        AND paa.effective_start_date <= SYSDATE
                        AND paa.effective_end_date >= SYSDATE
                        AND ppf.effective_start_date <= SYSDATE
                        AND ppf.effective_end_date >= SYSDATE \*AND paa.ass_attribute1 = 'HR'*\
                     ) person,*/
                           (SELECT r.segment1 order_num,
                           r.attribute5 line_attr_id,
                           'ORDER' order_flag,
                           r.po_header_id
                      FROM (SELECT row_number() over(PARTITION BY pla.attribute5 ORDER BY pha.segment1 DESC) lev,
                                   pha.segment1,
                                   pla.attribute5,
                                   pha.po_header_id
                              FROM po_headers_all pha, po_lines_all pla
                             WHERE pha.po_header_id = pla.po_header_id
                               AND EXISTS
                             (SELECT 1
                                      FROM cux_pr_plan_lines cpl
                                     WHERE cpl.line_id = pla.attribute5)) r
                     WHERE lev = 1) ord, /*获取订单*/
                     wpc_contract_t T1,
                     PO_VENDORS     s_ven
               where 1 = 1
                 and cpph.header_id = cppl.header_id
                 and cpph.plan_status = 'ORDERED'
                  and ord.po_header_id is not null
                 and ppf.person_id = fu.employee_id
                 and fu.user_id(+) = cpph.operator_id
                 and T1.FCONID(+) = cpph.contract_id
                 and t1.fsecondparty = s_ven.VENDOR_ID(+)
                 AND cppl.line_id = ord.line_attr_id(+)
              --and cpph.plan_number = 'S201611006'
              union
              --项目批量采购计划
              select ppf.global_name person_name, --经办人
                    /* (select poh.po_header_id
                        from po_headers_all poh
                       where 1 = 1
                         and poh.po_header_id =
                             (select pol.po_header_id
                                from po_lines_all               pol,
                                     cux_pr_purchase_plan_lines cpppl
                               where pol.attribute7 = cpppl.line_id
                                 and cpppl.header_id = cppph.header_id
                                 and rownum = 1)) po_header_id,*/
                     ord.po_header_id,
                     cppph.oper_phone_num, --经办人电话
                     cppph.const_name, --施工方联系人
                     cppph.const_phone_num, --施工方电话
                     T1.Fname              contract_name,
                     s_ven.VENDOR_NAME     fsecondpartyname,
                     null spot_prices,
                     null spot_prices_date
                from cux_pr_purchase_plan_lines cpppl,
                     cux_pr_purchase_plan_headers cppph,
                     fnd_user                     fu,
                     per_people_f                 ppf,
                     /*(SELECT ppf.global_name person_name,
                            hou.organization_id org_id,
                            hou.name depart_name,
                            (SELECT NAME
                               FROM hr_all_positions_f ap
                              WHERE ap.position_id = paa.position_id
                                AND ap.effective_start_date <= SYSDATE
                                AND ap.effective_end_date >= SYSDATE) position_name,
                            paa.person_id,
                            paa.position_id,
                            fu.user_id
                       FROM hr_organization_units_v hou,
                            per_all_assignments_f   paa,
                            per_people_f            ppf,
                            fnd_user                fu
                      WHERE hou.organization_id = paa.organization_id(+)
                        AND paa.person_id = ppf.person_id
                        AND paa.person_id = fu.employee_id
                        AND paa.position_id IS NOT NULL
                        AND paa.effective_start_date <= SYSDATE
                        AND paa.effective_end_date >= SYSDATE
                        AND ppf.effective_start_date <= SYSDATE
                        AND ppf.effective_end_date >= SYSDATE \*AND paa.ass_attribute1 = 'HR'*\
                     ) person,*/
                     
                            (SELECT r.segment1 order_num,
                           r.line_num,
                           r.attribute7 line_attr_id,
                           'ORDER' order_flag,
                           r.po_header_id
                      FROM (SELECT row_number() over(PARTITION BY pla.attribute7 ORDER BY pha.segment1 DESC) lev,
                                   pha.segment1,
                                   pla.attribute7,
                                   pla.line_num,
                                   pha.po_header_id
                              FROM po_headers_all pha, po_lines_all pla
                             WHERE pha.po_header_id = pla.po_header_id
                               AND EXISTS
                             (SELECT 1
                                      FROM cux_pr_purchase_plan_lines cpl
                                     WHERE cpl.line_id = pla.attribute7)) r
                     WHERE lev = 1) ord, /*获取订单*/
                     wpc_contract_t T1,
                     PO_VENDORS     s_ven
               where 1 = 1
                 and cppph.header_id = cpppl.header_id
                 and cppph.plan_status = 'ORDERED'
                 and ppf.person_id = fu.employee_id
                 and fu.user_id(+) = cppph.operator_id
                 and T1.FCONID(+) = cppph.contract_id
                 and t1.fsecondparty = s_ven.VENDOR_ID(+)
              AND cpppl.line_id = ord.line_attr_id(+)
               and ord.po_header_id is not null
              --and cppph.plan_number = 'PS201600050'
              ) order1
       WHERE hou.organization_id = pha.org_id
         AND he.employee_id = pha.agent_id
         AND flv.lookup_type = 'CUX_PO_DOCUMENTS_TYPE'
         AND flv.lookup_code = pha.type_lookup_code
         AND to_char(pro_org.organization_id(+)) = pha.attribute1
         AND hla.location_id = pha.ship_to_location_id
         AND plc.lookup_type = 'CUX_DOCUMENTS_STATUS'
         AND plc.lookup_code = (CASE
               WHEN pha.authorization_status IN
                    ('APPROVING', 'APPROVED', 'REJECTED') THEN
                pha.authorization_status
               ELSE
                'DRAFT'
             END)
         AND pha.authorization_status = 'APPROVED'
            /*AND    nvl(pha.closed_code, 'OPEN') = 'OPEN'*/
         AND nvl(pha.cancel_flag, 'N') = 'N'
         AND pv.vendor_id = pha.vendor_id
         AND wc.po_header_id(+) = pha.po_header_id
         AND wc.row_num(+) = 1
            /*AND    rct.po_header_id(+) = pha.po_header_id*/
         AND pll.po_header_id(+) = pha.po_header_id
         AND line.po_header_id(+) = pha.po_header_id
         AND total_line.po_header_id(+) = pha.po_header_id
         AND total_delivery.po_header_id(+) = pha.po_header_id
         AND total_receive.po_header_id(+) = pha.po_header_id
         AND total_apply.po_header_id(+) = pha.po_header_id
         AND total_invoice.po_header_id(+) = pha.po_header_id
         AND flv1.lookup_type = 'CUX_PO_DELIVERY_STATUS'
         AND flv1.lookup_code = (CASE
               WHEN total_delivery.total_delivery_quantity >=
                    total_line.total_quantity THEN
                'ALL_DELIVERY'
               WHEN total_delivery.total_delivery_quantity > 0 THEN
                'PARTIAL_DELIVERY'
               ELSE
                'NOT_DELIVERED'
             END)
         AND flv2.lookup_type = 'CUX_PO_RECEIVE_STATUS'
         AND flv2.lookup_code = (CASE
               WHEN total_receive.total_receive_quantity >=
                    total_line.total_quantity THEN
                'ALL_ARRIVAL'
               WHEN total_receive.total_receive_quantity > 0 THEN
                'PARTIAL_ARRIVAL'
               ELSE
                'NOT_ARRIVED'
             END)
         AND flv3.lookup_type = 'CUX_PO_APPLYMENT_STATUS'
         AND flv3.lookup_code = (CASE
               WHEN total_apply.total_apply_amount >= line.total_tax_amount THEN
                'ALL_APPLYMENT'
               WHEN total_apply.total_apply_amount > 0 THEN
                'PARTIAL_APPLYMENT'
               ELSE
                'NOT_APPLYMENT'
             END)
         AND flv4.lookup_type = 'CUX_PO_INVOICE_STATUS'
         AND flv4.lookup_code = (CASE
               WHEN total_invoice.total_invoice_quantity >=
                    total_line.total_quantity THEN
                'ALL_BILLING'
               WHEN total_invoice.total_invoice_quantity > 0 THEN
                'PARTIAL_BILLING'
               ELSE
                'NOT_BILLED'
             END)
         AND pha.type_lookup_code = 'STANDARD'
         and pha.po_header_id = order1.po_header_id(+)
      /*  --排除在临时表存在的po
        and not exists
      (select 1
               from CUX_PO_HEADERS_ALL cpha
              where 1 = 1
                and cpha.po_header_id = pha.po_header_id)*/
     /* UNION ALL
      SELECT pha.po_header_id,
             pha.segment1 po_number,
             pha.org_id,
             hou.name org_name,
             pha.agent_id,
             he.full_name agent_name,
             pha.type_lookup_code,
             flv.meaning type_meaning,
             pha.attribute1 project_org_id,
             pro_org.name project_org_name,
             pha.currency_code,
             NULL total_amount,
             NULL last_delivery_date,
             '' last_delivery_date_dsp,
             '' is_partial_delivery,
             pha.ship_to_location_id,
             hla.location_code ship_to_location_code, \*hr_general.hr_lookup_locations(p_location_id => pha.ship_to_location_id)*\
             wc.faddress ship_to_location_address,
             plc.lookup_code authorization_status,
             plc.meaning authorization_status_dsp,
             '' delivery_status,
             '' delivery_status_dsp,
             '' applyment_status,
             '' applyment_status_dsp,
             '' invoice_status,
             '' invoice_status_dsp,
             '' receive_status,
             '' receive_status_dsp,
             to_char(pha.start_date, 'YYYY-MM-DD') start_date,
             to_char(pha.end_date, 'YYYY-MM-DD') end_date,
             pha.vendor_id,
             pv.segment1 vendor_number,
             saaf_generate_tender_code.getVendorName(pha.po_header_id) vendor_name,
             wc.project_id,
             wc.project_name,
             wc.project_block_id,
             wc.project_block_name,
             wc.contract_id,
             wc.contract_name,
             wc.vendor_id leading_unit_id,
             wc.vendor_name leading_unit_name,
             to_char(pha.creation_date, 'YYYY-MM-DD') order_date,
             (select saaf_generate_tender_code.getOrderRate(pha.po_header_id)
                from dual) orderRate,
             (select saaf_generate_tender_code.getDeliveryRate(pha.po_header_id)
                from dual) deliveryRate,
             order1.person_name, --经办人
             order1.oper_phone_num, --经办人电话
             order1.const_name, --施工方联系人
             order1.const_phone_num, --施工方电话
             wc.vendor_name fsecondpartyname
        FROM po_headers_all pha,
             hr_operating_units hou,
             hr_operating_units pro_org,
             hr_employees he,
             hr_locations_all hla,
             fnd_lookup_values_vl plc,
             po_vendors pv,
             (SELECT pla.po_header_id,
                     pla.attribute1 project_id,
                     wpt.fname project_name,
                     pla.attribute2 project_block_id,
                     wpb.fname project_block_name,
                     pla.attribute3 contract_id,
                     wct.fname contract_name,
                     row_number() over(PARTITION BY pla.po_header_id ORDER BY pla.po_header_id, pla.attribute3 NULLS LAST) row_num,
                     wpt.faddress,
                     ass.vendor_id,
                     ass.vendor_name
                FROM po_lines_all pla,
                     wbd.wbd_project_t wpt,
                     (SELECT wpbt.fpbno, wpbt.fname
                        FROM wbd.wbd_project_t wpt, wbd_projectblock_t wpbt
                       WHERE wpt.fiseffective = '1'
                         AND wpt.fprjid = wpbt.fprjid) wpb,
                     wpc.wpc_contract_t wct,
                     ap_suppliers ass
               WHERE wpt.fiseffective(+) = '1'
                 AND wpt.fprjno(+) = pla.attribute1
                 AND wpb.fpbno(+) = pla.attribute2
                 AND wct.fconid(+) = pla.attribute3
                    \*AND    nvl(pla.closed_code, 'OPEN') = 'OPEN'*\
                 AND nvl(pla.cancel_flag, 'N') = 'N'
                 AND ass.vendor_id = wct.fsecondparty) wc,
             fnd_lookup_values_vl flv, --供货计划
             (select ppf.global_name person_name, --经办人
                     
                     (select poh.po_header_id
                        from po_headers_all poh
                       where 1 = 1
                         and poh.po_header_id =
                             (select pol.po_header_id
                                from po_lines_all pol, cux_pr_plan_lines cppl
                               where pol.attribute5 = cppl.line_id
                                 and cppl.header_id = cpph.header_id
                                 and rownum = 1)) po_header_id,
                     --ord.po_header_id,
                     cpph.oper_phone_num, --经办人电话
                     cpph.const_name, --施工方联系人
                     cpph.const_phone_num, --施工方电话
                     T1.Fname             contract_name,
                     s_ven.VENDOR_NAME    fsecondpartyname
                from --cux_pr_plan_lines cppl,
                     cux_pr_plan_headers cpph,
                     fnd_user            fu,
                     per_people_f        ppf,
                     \* (SELECT ppf.global_name person_name,
                            hou.organization_id org_id,
                            hou.name depart_name,
                            (SELECT NAME
                               FROM hr_all_positions_f ap
                              WHERE ap.position_id = paa.position_id
                                AND ap.effective_start_date <= SYSDATE
                                AND ap.effective_end_date >= SYSDATE) position_name,
                            paa.person_id,
                            paa.position_id,
                            fu.user_id
                       FROM hr_organization_units_v hou,
                            per_all_assignments_f   paa,
                            per_people_f            ppf,
                            fnd_user                fu
                      WHERE hou.organization_id = paa.organization_id(+)
                        AND paa.person_id = ppf.person_id
                        AND paa.person_id = fu.employee_id
                        AND paa.position_id IS NOT NULL
                        AND paa.effective_start_date <= SYSDATE
                        AND paa.effective_end_date >= SYSDATE
                        AND ppf.effective_start_date <= SYSDATE
                        AND ppf.effective_end_date >= SYSDATE \*AND paa.ass_attribute1 = 'HR'*\
                     ) person,*\
                     \*      (SELECT r.segment1 order_num,
                           r.attribute5 line_attr_id,
                           'ORDER' order_flag,
                           r.po_header_id
                      FROM (SELECT row_number() over(PARTITION BY pla.attribute5 ORDER BY pha.segment1 DESC) lev,
                                   pha.segment1,
                                   pla.attribute5,
                                   pha.po_header_id
                              FROM po_headers_all pha, po_lines_all pla
                             WHERE pha.po_header_id = pla.po_header_id
                               AND EXISTS
                             (SELECT 1
                                      FROM cux_pr_plan_lines cpl
                                     WHERE cpl.line_id = pla.attribute5)) r
                     WHERE lev = 1) ord, \*获取订单*\*\
                     wpc_contract_t T1,
                     PO_VENDORS     s_ven
               where 1 = 1
                    --and cpph.header_id = cppl.header_id
                 and cpph.plan_status = 'ORDERED'
                    -- and ord.po_header_id is not null
                 and ppf.person_id = fu.employee_id
                 and fu.user_id(+) = cpph.operator_id
                 and T1.FCONID(+) = cpph.contract_id
                 and t1.fsecondparty = s_ven.VENDOR_ID(+)
              --AND cppl.line_id = ord.line_attr_id(+)
              --and cpph.plan_number = 'S201611006'
              union
              --项目批量采购计划
              select ppf.global_name person_name, --经办人
                     (select poh.po_header_id
                        from po_headers_all poh
                       where 1 = 1
                         and poh.po_header_id =
                             (select pol.po_header_id
                                from po_lines_all               pol,
                                     cux_pr_purchase_plan_lines cpppl
                               where pol.attribute7 = cpppl.line_id
                                 and cpppl.header_id = cppph.header_id
                                 and rownum = 1)) po_header_id,
                     --ord.po_header_id,
                     cppph.oper_phone_num, --经办人电话
                     cppph.const_name, --施工方联系人
                     cppph.const_phone_num, --施工方电话
                     T1.Fname              contract_name,
                     s_ven.VENDOR_NAME     fsecondpartyname
                from -- cux_pr_purchase_plan_lines cpppl,
                     cux_pr_purchase_plan_headers cppph,
                     fnd_user                     fu,
                     per_people_f                 ppf,
                     \*(SELECT ppf.global_name person_name,
                            hou.organization_id org_id,
                            hou.name depart_name,
                            (SELECT NAME
                               FROM hr_all_positions_f ap
                              WHERE ap.position_id = paa.position_id
                                AND ap.effective_start_date <= SYSDATE
                                AND ap.effective_end_date >= SYSDATE) position_name,
                            paa.person_id,
                            paa.position_id,
                            fu.user_id
                       FROM hr_organization_units_v hou,
                            per_all_assignments_f   paa,
                            per_people_f            ppf,
                            fnd_user                fu
                      WHERE hou.organization_id = paa.organization_id(+)
                        AND paa.person_id = ppf.person_id
                        AND paa.person_id = fu.employee_id
                        AND paa.position_id IS NOT NULL
                        AND paa.effective_start_date <= SYSDATE
                        AND paa.effective_end_date >= SYSDATE
                        AND ppf.effective_start_date <= SYSDATE
                        AND ppf.effective_end_date >= SYSDATE \*AND paa.ass_attribute1 = 'HR'*\
                     ) person,*\
                     
                     \*       (SELECT r.segment1 order_num,
                           r.line_num,
                           r.attribute7 line_attr_id,
                           'ORDER' order_flag,
                           r.po_header_id
                      FROM (SELECT row_number() over(PARTITION BY pla.attribute7 ORDER BY pha.segment1 DESC) lev,
                                   pha.segment1,
                                   pla.attribute7,
                                   pla.line_num,
                                   pha.po_header_id
                              FROM po_headers_all pha, po_lines_all pla
                             WHERE pha.po_header_id = pla.po_header_id
                               AND EXISTS
                             (SELECT 1
                                      FROM cux_pr_purchase_plan_lines cpl
                                     WHERE cpl.line_id = pla.attribute7)) r
                     WHERE lev = 1) ord, \*获取订单*\*\
                     wpc_contract_t T1,
                     PO_VENDORS     s_ven
               where 1 = 1
                    --and cppph.header_id = cpppl.header_id
                 and cppph.plan_status = 'ORDERED'
                 and ppf.person_id = fu.employee_id
                 and fu.user_id(+) = cppph.operator_id
                 and T1.FCONID(+) = cppph.contract_id
                 and t1.fsecondparty = s_ven.VENDOR_ID(+)
              --AND cpppl.line_id = ord.line_attr_id(+)
              -- and ord.po_header_id is not null
              --and cppph.plan_number = 'PS201600050'
              ) order1
       WHERE hou.organization_id = pha.org_id
         AND he.employee_id = pha.agent_id
         AND flv.lookup_type = 'CUX_PO_DOCUMENTS_TYPE'
         AND flv.lookup_code = pha.type_lookup_code
         AND to_char(pro_org.organization_id(+)) = pha.attribute1
         AND hla.location_id = pha.ship_to_location_id
         AND plc.lookup_type = 'CUX_DOCUMENTS_STATUS'
         AND plc.lookup_code = (CASE
               WHEN pha.authorization_status IN
                    ('APPROVING', 'APPROVED', 'REJECTED') THEN
                pha.authorization_status
               ELSE
                'DRAFT'
             END)
         AND pha.authorization_status = 'APPROVED'
            \*AND    nvl(pha.closed_code, 'OPEN') = 'OPEN'*\
         AND nvl(pha.cancel_flag, 'N') = 'N'
         AND pv.vendor_id = pha.vendor_id
         AND wc.po_header_id = pha.po_header_id
         AND wc.row_num = 1
         AND pha.type_lookup_code = 'BLANKET'
         and pha.po_header_id = order1.po_header_id(+)*/
      /*    --排除在临时表存在的po
        and not exists
      (select 1
               from CUX_PO_HEADERS_ALL cpha
              where 1 = 1
                and cpha.po_header_id = pha.po_header_id)*/
       ORDER BY po_number DESC;
   
    l_num number;
  BEGIN
  
    --先删除临时表数据
    delete from CUX_PO_HEADERS_ALL;
    commit;
  
    for rec_po in csr_po loop
      select CUX_PO_HEADERS_ALL_S.Nextval into l_num from dual;
      insert into CUX_PO_HEADERS_ALL
        (HEADER_ID,
         PO_HEADER_ID,
         project_org_name,
         TOTAL_AMOUNT,
         LAST_DELIVERY_DATE,
         IS_PARTIAL_DELIVERY,
         DELIVERY_STATUS,
         DELIVERY_STATUS_DSP,
         APPLYMENT_STATUS,
         APPLYMENT_STATUS_DSP,
         INVOICE_STATUS,
         INVOICE_STATUS_DSP,
         RECEIVE_STATUS,
         RECEIVE_STATUS_DSP,
         PROJECT_ID,
         PROJECT_NAME,
         PROJECT_BLOCK_ID,
         PROJECT_BLOCK_NAME,
         CONTRACT_ID,
         CONTRACT_NAME,
         LEADING_UNIT_ID,
         LEADING_UNIT_NAME,
         ORDERRATE,
         DELIVERYRATE,
         PERSON_NAME,
         OPER_PHONE_NUM,
         CONST_NAME,
         CONST_PHONE_NUM,
         FSECONDPARTYNAME,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN)
      values
        (l_num,
         rec_po.PO_HEADER_ID,
         rec_po.project_org_name,
         rec_po.total_amount,
         rec_po.LAST_DELIVERY_DATE,
         rec_po.IS_PARTIAL_DELIVERY,
         rec_po.DELIVERY_STATUS,
         rec_po.DELIVERY_STATUS_DSP,
         rec_po.APPLYMENT_STATUS,
         rec_po.APPLYMENT_STATUS_DSP,
         rec_po.INVOICE_STATUS,
         rec_po.INVOICE_STATUS_DSP,
         rec_po.RECEIVE_STATUS,
         rec_po.RECEIVE_STATUS_DSP,
         rec_po.PROJECT_ID,
         rec_po.PROJECT_NAME,
         rec_po.PROJECT_BLOCK_ID,
         rec_po.PROJECT_BLOCK_NAME,
         rec_po.CONTRACT_ID,
         rec_po.CONTRACT_NAME,
         rec_po.LEADING_UNIT_ID,
         rec_po.LEADING_UNIT_NAME,
         rec_po.ORDERRATE,
         rec_po.DELIVERYRATE,
         rec_po.PERSON_NAME,
         rec_po.OPER_PHONE_NUM,
         rec_po.CONST_NAME,
         rec_po.CONST_PHONE_NUM,
         rec_po.FSECONDPARTYNAME,
         rec_po.vendor_name,
         rec_po.spot_prices,
         rec_po.spot_prices_date,
         SYSDATE,
         -1,
         SYSDATE,
         -1,
         -1);
      commit;
    end loop;
  
  END;
end CUX_QUERY_PO_HEADERS_PKG;
