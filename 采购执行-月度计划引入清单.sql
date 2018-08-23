

SELECT wc.fconid
                  ,t.inventory_item_id
                  ,wbt.fbomid
                  ,SUM(nvl(wbt.fquantity
                          ,0)) sumq
              FROM wpc_contract_t wc
                  ,(SELECT a.fbomlistid
                          ,a.fbomid
                          ,a.fquantity
                          ,b.inventory_item_id
                      FROM wpc_bomlist_t  a
                          ,wbd_material_t b
                     WHERE a.fprdid = b.fprdid
                       AND a.ftype = '0') t
                  ,wpc.wpc_bomorderlist_t wbt
             WHERE (wc.fbomid = t.fbomid OR EXISTS
                    (SELECT wcct.fconid
                           ,wcct.fbomid
                       FROM wpc.wpc_changevisa_t wct
                           ,wpc_changecontract_t wcct
                      WHERE wcct.fcvid = wct.fcvid
                        AND wct.fchangetype IN ('10'
                                               ,'20')
                        AND wct.fwflowstate = '20'
                        AND wcct.fconid = wc.fconid
                        AND wcct.fbomid = t.fbomid) OR EXISTS
                    (SELECT 1
                       FROM wpc.wpc_contract_t wc1
                      WHERE wc1.fmainconid = wc.fconid
                        AND wc1.fwflowstate = '20'
                        AND wc1.fbomid = t.fbomid))
               AND t.fbomid = wbt.fbomid(+)
               AND t.fbomlistid = wbt.fbomlistid(+)
               AND nvl(wc.fcontractproperty
                      ,'1') <> '2'
                      and wc.fconid=190843 --
             GROUP BY wc.fconid
                   ,wbt.fbomid
                     ,t.inventory_item_id


--- 


 SELECT rownum rn
              ,tt.fbomlistid
              ,tt.fbomid
              ,tt.fprdid
              ,tt.fquantity
              ,tt.fnumber
              ,tt.fname
              ,tt.fsize
              ,tt.funit
              ,tt.fprice
              ,tt.fprechangequantity
              ,tt.loss_rate
              ,tt.project_rule
              ,tt.sum_quantity
              ,tt.fconid
              ,tt.category_id
              ,
               /*itemcate.cate_desc*/tt.cate_desc
              ,tt.inventory_item_id
              ,tt.item_num
              ,tt.item_desc
              ,tt.primary_uom_code
              ,tt.unit_name
              ,tt.sum_plan_qty
              ,tt.l_quantity
              ,tt.other_quantity /* = -*/
              ,tt.surplus_amount
              ,tt.surplus_plan_amount
              ,'N' select_flag
              ,tt.category_code
              ,tt.bom_fnumber
        FROM   (SELECT to_number(NULL) fbomlistid
                       ,to_number(NULL) fbomid
                       ,fbo.fprdid
                       ,fbo.fquantity
                       ,fbo.fnumber
                       ,fbo.fname
                       ,fbo.fsize
                       ,fbo.funit
                       ,fbo.fprice
                       ,to_number(NULL) fprechangequantity
                       ,to_number(NULL) loss_rate
                       ,NULL project_rule
                       ,fbo.sumq sum_quantity
                       ,fbo.fconid
                       ,itemcate.category_id
                       , /*itemcate.cate_desc*/nvl(itemcate.item_desc,
                            itemcate.cate_desc) cate_desc
                       ,itemcate.inventory_item_id
                       ,itemcate.item_num
                       ,nvl(substr(itemcate.long_description, 0, 240),
                            /*long_description */
                            itemcate.item_desc) item_desc
                       ,itemcate.primary_uom_code
                       ,itemcate.unit_name
                       ,planqty.sum_plan sum_plan_qty
                       ,nvl(itemquantity.l_quantity, 0) l_quantity
                       ,fbo.sumq - nvl(planqty.sum_plan, 0) other_quantity /* = -*/
                       ,to_number(NULL) surplus_amount
                       ,to_number(NULL) surplus_plan_amount
                       ,itemcate.category_code
                       ,'' bom_fnumber
                 FROM   (SELECT wc.fconid
                               ,t.fprdid
                               ,t.fquantity
                               ,t.fnumber
                               ,t.fname
                               ,t.fsize
                               ,t.funit
                               ,t.fprice
                               ,t.inventory_item_id
                               ,SUM(nvl(wbt.fquantity, 0)) sumq /**/
                         
                         FROM   wpc_contract_t wc
                               ,(SELECT a.rowid row_id
                                       ,a.fbomlistid
                                       ,a.fbomid
                                       ,a.fprdid
                                       ,a.fquantity
                                       ,b.fnumber
                                       ,b.inventory_item_id
                                       ,b.fname
                                       ,b.fsize
                                       ,b.funit
                                       ,b.fprice
                                       ,a.fprechangequantity
                                       ,a.loss_rate
                                       ,a.project_rule
                                       ,a.sum_ven_price
                                 FROM   wpc_bomlist_t  a
                                       ,wbd_material_t b
                                 WHERE  a.fprdid = b.fprdid
                                 AND    a.ftype = '0') t
                               ,wpc.wpc_bomorderlist_t wbt
                         
                         WHERE  (wc.fbomid = t.fbomid OR EXISTS
                                 (SELECT wcct.fconid
                                        ,wcct.fbomid
                                  FROM   wpc.wpc_changevisa_t wct
                                        ,wpc_changecontract_t wcct
                                  WHERE  wcct.fcvid = wct.fcvid
                                  AND    wct.fchangetype IN ('10', '20')
                                  AND    wct.fwflowstate = '20'
                                  AND    wcct.fconid = wc.fconid
                                  AND    wcct.fbomid = t.fbomid) OR EXISTS
                                 (SELECT 1
                                  FROM   wpc.wpc_contract_t wc1
                                  WHERE  wc1.fmainconid = wc.fconid
                                  AND    wc1.fwflowstate = '20'
                                  AND    wc1.fbomid = t.fbomid))
                         AND    t.fbomid = wbt.fbomid(+)
                         AND    t.fbomlistid = wbt.fbomlistid(+)
                         AND    nvl(wc.fcontractproperty, '1') <> '2' /*AND wbt.fquantity IS NOT NULL*/
                         GROUP  BY wc.fconid
                                  ,t.fprdid
                                  ,t.fquantity
                                  ,t.fnumber
                                  ,t.fname
                                  ,t.fsize
                                  ,t.funit
                                  ,t.fprice
                                  ,t.inventory_item_id) fbo /**/
                       ,(SELECT mtl.category_id
                               ,mtl.description              cate_desc
                               ,msib.inventory_item_id
                               ,msib.segment1                item_num
                               ,msib.description             item_desc
                               ,msib.long_description
                               ,msib.primary_uom_code
                               ,muom.unit_of_measure_tl      unit_name
                               ,msib.primary_unit_of_measure unit_name
                               ,mtl.category_code
                         FROM   mtl_item_categories t
                               ,mtl_system_items_vl msib
                               ,mtl_units_of_measure_vl muom
                               ,(SELECT mc.category_id
                                       ,fnd_flex_ext.get_segs('INV',
                                                              'MCAT',
                                                              mc.structure_id,
                                                              mc.category_id) concatenated_segments
                                       ,mc.description
                                       ,mc.segment1 || '.' || mc.segment2 || '.' ||
                                        mc.segment3 category_code
                                 FROM   mtl_categories mc
                                 WHERE  mc.structure_id = 101
                                 AND    (mc.disable_date IS NULL OR
                                       mc.disable_date >= SYSDATE)
                                 AND    mc.enabled_flag = 'Y') mtl
                         WHERE  t.inventory_item_id = msib.inventory_item_id
                         AND    t.organization_id = msib.organization_id
                         AND    t.category_id = mtl.category_id /*AND msib.primary_uom_code = muom.uom_code*/
                         AND    msib.organization_id = 460
                         AND    t.category_set_id = 1
                         AND    msib.inventory_item_status_code <> 'Inactive') itemcate /**/
                       ,(SELECT l.item_id
                               ,SUM(l.quantity) l_quantity
                         FROM   po_headers_all h
                               ,po_lines_all   l
                         WHERE  h.type_lookup_code = 'STANDARD'
                         AND    h.authorization_status = 'APPROVED'
                         AND    nvl(h.closed_code, 'OPEN') = 'OPEN'
                         AND    nvl(h.cancel_flag, 'N') = 'N'
                         AND    h.po_header_id = l.po_header_id
                         AND    nvl(l.closed_code, 'OPEN') = 'OPEN'
                         AND    nvl(l.cancel_flag, 'N') = 'N'
                         AND    h.attribute1 = /*'3696'*/
                                :1
                         AND    l.attribute3 = /* '183641'*/
                                :2
                         GROUP  BY l.item_id) itemquantity /**/
                        
                       ,(SELECT cpl.item_id
                               ,SUM(cpl.quantity) sum_plan
                         FROM   cux_pr_plan_lines   cpl
                               ,cux_pr_plan_headers cph
                         WHERE  cpl.header_id = cph.header_id
                         AND    cph.org_id = :3
                         AND    cph.contract_id = :4
                         AND    cph.plan_type <> 'SPOT_CHECK_ORDERS'
                         AND    cph.last_update_date =
                                (SELECT MAX(cphh.last_update_date)
                                  FROM   cux_pr_plan_headers cphh
                                  WHERE  cphh.plan_number = cph.plan_number
                                  AND    cphh.plan_status IN
                                         ('APPROVING', 'APPROVED', 'ORDERED'))
                         GROUP  BY cpl.item_id) planqty /**/
                 WHERE  /*fbo.fnumber = itemcate.item_num*/
                  fbo.inventory_item_id = itemcate.inventory_item_id
               AND    itemcate.inventory_item_id = itemquantity.item_id(+)
               AND    itemcate.inventory_item_id = planqty.item_id(+)
               AND    fbo.fconid = :5
                 /*AND NOT EXISTS (SELECT 1 FROM cux_pr_demand_headers csths ,cux_pr_demand_lines cspd
                 WHERE csths.header_id = cspd.header_id AND csths.contract_id = fbo.fconid AND cspd.item_id = itemcate.inventory_item_id)*/
                 UNION ALL
                 SELECT DISTINCT ttt.fbomlistid
                                ,ttt.fbomid
                                ,ttt.fprdid
                                ,ttt.fquantity
                                ,ttt.fnumber
                                ,ttt.fname
                                ,ttt.fsize
                                ,ttt.funit
                                ,ttt.fprice
                                ,ttt.fprechangequantity
                                ,ttt.loss_rate
                                ,ttt.project_rule
                                ,ttt.sum_quantity
                                ,ttt.fconid
                                ,ttt.category_id
                                ,ttt.cate_desc
                                ,ttt.inventory_item_id
                                ,ttt.item_num
                                ,ttt.item_desc
                                ,ttt.primary_uom_code
                                ,ttt.unit_name
                                ,ttt.sum_plan_qty
                                ,ttt.l_quantity
                                ,ttt.other_quantity
                                ,ttt.surplus_amount
                                ,ttt.surplus_plan_amount
                                ,ttt.category_code
                                ,ttt.bom_fnumber
                 FROM   (SELECT to_number(NULL) fbomlistid
                               ,to_number(NULL) fbomid
                               ,wbv.fprdid
                               ,wbv.fquantity
                               ,cateitem.item_num fnumber
                               ,cateitem.item_desc fname
                               ,wbv.fsize
                               ,wbv.funit
                               ,wbv.fprice
                               ,to_number(NULL) fprechangequantity
                               ,to_number(NULL) loss_rate
                               ,NULL project_rule
                               ,to_number(NULL) sum_quantity
                               ,wbv.fconid
                               ,cateitem.category_id
                               ,cateitem.item_desc cate_desc
                               ,cateitem.inventory_item_id
                               ,cateitem.item_num
                               ,cateitem.long_description item_desc
                               ,cateitem.primary_uom_code
                               ,cateitem.unit_name
                               ,to_number(NULL) sum_plan_qty
                               ,to_number(NULL) l_quantity
                               ,to_number(NULL) other_quantity
                               ,wbv.sumq - nvl(planqty.sum_plan, 0) surplus_amount
                               ,wbv.sumq surplus_plan_amount
                               ,wpt.fregion
                               ,wbv.tenders
                               ,wbv.fpbno
                               ,cateitem.category_code
                               ,wbv.fnumber bom_fnumber
                         FROM   (SELECT wc.fconid
                                       ,wc.fpbno
                                       ,wc.fprjno
                                       ,MAX(wb.tenders) tenders
                                       ,t.fprdid
                                       ,t.fquantity
                                       ,t.fnumber
                                       ,t.fname
                                       ,t.fsize
                                       ,t.funit
                                       ,t.fprice
                                       ,t.segment1
                                       ,t.segment2
                                       ,t.segment3
                                       ,t.segment4
                                       ,SUM(wbt.fquantity) sumq /**/
                                 FROM   wpc_contract_t wc
                                       ,wpc_bom_t wb
                                       ,(SELECT a.rowid row_id
                                               ,a.fbomlistid
                                               ,a.fbomid
                                               ,a.fprdid
                                               ,a.fquantity
                                               ,b.fnumber
                                               ,b.fname
                                               ,b.fsize
                                               ,b.funit
                                               ,b.fprice
                                               ,a.fprechangequantity
                                               ,a.loss_rate
                                               ,a.project_rule
                                               ,a.sum_ven_price
                                               ,b.segment1
                                               ,b.segment2
                                               ,b.segment3
                                               ,b.segment4
                                         FROM   wpc_bomlist_t  a
                                               ,wbd_material_t b
                                         WHERE  a.fprdid = b.fprdid
                                         AND    a.ftype = '2') t
                                       ,wpc.wpc_bomorderlist_t wbt
                                 WHERE  wb.fbomid = t.fbomid
                                 AND    (wc.fbomid = t.fbomid OR EXISTS
                                        (SELECT wcct.fconid
                                                ,wcct.fbomid
                                          FROM   wpc.wpc_changevisa_t wct
                                                ,wpc_changecontract_t wcct
                                          WHERE  wcct.fcvid = wct.fcvid
                                          AND    wct.fchangetype IN ('10', '20')
                                          AND    wct.fwflowstate = '20'
                                          AND    wcct.fconid = wc.fconid
                                          AND    wcct.fbomid = t.fbomid) OR
                                        EXISTS
                                        (SELECT 1
                                          FROM   wpc.wpc_contract_t wc1
                                          WHERE  wc1.fmainconid = wc.fconid
                                          AND    wc1.fwflowstate = '20'
                                          AND    wc1.fbomid = t.fbomid))
                                 AND    t.fbomid = wbt.fbomid
                                 AND    t.fbomlistid = wbt.fbomlistid
                                 AND    nvl(wc.fcontractproperty, '1') <> '2'
                                 AND    wbt.fquantity IS NOT NULL
                                 GROUP  BY wc.fconid
                                          ,wc.fpbno
                                          ,wc.fprjno
                                          ,t.fprdid
                                          ,t.fquantity
                                          ,t.fnumber
                                          ,t.fname
                                          ,t.fsize
                                          ,t.funit
                                          ,t.fprice
                                          ,t.segment1
                                          ,t.segment2
                                          ,t.segment3
                                          ,t.segment4) wbv /**/
                               ,wpc_contract_t wcv
                               ,(SELECT mtl.category_id
                                       ,mtl.description              cate_desc
                                       ,mtl.concatenated_segments
                                       ,mtl.segment1
                                       ,mtl.segment2
                                       ,mtl.segment3
                                       ,mtl.segment4
                                       ,msib.inventory_item_id
                                       ,msib.segment1                item_num
                                       ,msib.description             item_desc
                                       ,msib.long_description
                                       ,msib.primary_uom_code
                                       ,muom.unit_of_measure_tl      unit_name
                                       ,msib.primary_unit_of_measure unit_name
                                       ,mtl.category_code
                                 FROM   mtl_item_categories t
                                       ,mtl_system_items_vl msib
                                       ,mtl_units_of_measure_vl muom
                                       ,(SELECT mc.category_id
                                               ,mc.segment1
                                               ,mc.segment2
                                               ,mc.segment3
                                               ,mc.segment4
                                               ,fnd_flex_ext.get_segs('INV',
                                                                      'MCAT',
                                                                      mc.structure_id,
                                                                      mc.category_id) concatenated_segments
                                               ,mc.description
                                               ,mc.segment1 || '.' ||
                                                mc.segment2 || '.' ||
                                                mc.segment3 category_code
                                         FROM   mtl_categories mc
                                         WHERE  mc.structure_id = 101
                                         AND    (mc.disable_date IS NULL OR
                                               mc.disable_date >= SYSDATE)
                                         AND    mc.enabled_flag = 'Y') mtl
                                 WHERE  t.inventory_item_id =
                                        msib.inventory_item_id
                                 AND    t.organization_id =
                                        msib.organization_id
                                 AND    t.category_id = mtl.category_id /* AND msib.primary_uom_code = muom.uom_code*/
                                 AND    msib.organization_id = 460
                                 AND    t.category_set_id = 1
                                 AND    msib.inventory_item_status_code <>
                                        'Inactive') cateitem
                               ,(SELECT SUM(cpl1.quantity * cpl1.unit_price) sum_plan
                                       ,mc.segment1 || '.' || mc.segment2 || '.' ||
                                        mc.segment3 category_code
                                 FROM   cux_pr_plan_lines   cpl1
                                       ,cux_pr_plan_headers cph1
                                       ,mtl_categories      mc
                                 WHERE  cpl1.header_id = cph1.header_id
                                 AND    cph1.org_id = :6
                                 AND    cph1.contract_id = :7
                                 AND    mc.structure_id = 101
                                 AND    mc.category_id = cpl1.category_id
                                 AND    cpl1.surpl_plan_amount IS NOT NULL
                                 AND    cph1.plan_type <> 'SPOT_CHECK_ORDERS'
                                 AND    cph1.plan_status <> 'DRAFT'
                                 AND    cph1.last_update_date =
                                        (SELECT MAX(cphh.last_update_date)
                                          FROM   cux_pr_plan_headers cphh
                                          WHERE  cphh.plan_number =
                                                 cph1.plan_number
                                          AND    cphh.plan_status IN
                                                 ('APPROVING',
                                                   'APPROVED',
                                                   'ORDERED'))
                                 GROUP  BY mc.segment1 || '.' || mc.segment2 || '.' ||
                                           mc.segment3) planqty /**/
                               ,wbd.wbd_project_t wpt
                         WHERE  cateitem.segment1 = wbv.segment1
                         AND    cateitem.segment2 = wbv.segment2
                         AND    cateitem.segment3 = wbv.segment3
                         AND    cateitem.segment4 =
                                nvl(wbv.segment4, cateitem.segment4)
                         AND    planqty.category_code(+) =
                                cateitem.category_code
                               -- AND wcv.fconid = wbv.fconid 
                         AND    wpt.fprjno = wbv.fprjno
                         AND    wpt.fiseffective = '1'
                         AND    wpt.fwflowstate = '20'
                         AND    wbv.fconid = :8 /*183641*/
                         ) ttt
                       ,cux_pr_plan_blanket_v cpbt
                 WHERE  cpbt.fnumber = ttt.item_num
                 AND    cpbt.fpbno = ttt.fpbno
                 AND    (cpbt.block_division = ttt.tenders OR
                       cpbt.block_division IS NULL)
                 AND    (cpbt.attribute10 IS NULL OR
                       cpbt.attribute10 = ttt.fregion)) tt) qrslt

