CREATE OR REPLACE PACKAGE BODY cux_pr_plan_change_pkg IS
  FUNCTION get_org_id RETURN NUMBER IS
  BEGIN
    RETURN g_org_id;
  END;

  FUNCTION get_contract_id RETURN NUMBER IS
  BEGIN
    RETURN g_contract_id;
  END;

  /*==================================================
  Copyright (C) Vivo Customization Application
             AllRights Reserved
  ==================================================*/
  /*==================================================
  Program Name:
       upd_delivery_quality
  Description:
       提交时更新计划行上面的已送货数量和已接收数量
  
  History:
      1.00  2017/3/4   sie_zsl  Creation
  ==================================================*/
  PROCEDURE upd_delivery_quality(p_header_id   IN NUMBER
                                ,x_return_code OUT VARCHAR2
                                ,x_return_msg  OUT VARCHAR2) IS
  
    l_version_num    NUMBER;
    l_header_id      NUMBER;
    l_plan_number    VARCHAR2(100);
    l_delivery_count NUMBER;
    l_revice_count   NUMBER;
  
  BEGIN
    BEGIN
      SELECT cph.version_num
            ,cph.plan_number
      INTO   l_version_num
            ,l_plan_number
      FROM   cux_pr_plan_headers cph
      WHERE  cph.header_id = p_header_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_version_num := 1;
    END;
  
    -- 如果版本不是第一个版本时，更新送货数量和接收数量
    IF l_version_num <> 1 THEN
    
      -- 循环版本
      FOR r1 IN REVERSE 1 .. l_version_num LOOP
        IF r1 <> 1 THEN
          -- 取出每个版本的头ID
          BEGIN
            SELECT cph.header_id
            INTO   l_header_id
            FROM   cux_pr_plan_headers cph
            WHERE  cph.version_num = r1
            AND    cph.plan_number = l_plan_number;
          EXCEPTION
            WHEN OTHERS THEN
              l_header_id := -1;
          END;
          -- 取出对应的行数据，更新上一版本数量
          FOR r2 IN (SELECT *
                     FROM   cux_pr_plan_lines cpl
                     WHERE  cpl.header_id = l_header_id) LOOP
            IF r1 = l_version_num THEN
              BEGIN
                SELECT saaf_generate_tender_code.getdeliveriedcount((SELECT pla.po_line_id
                                                                    FROM   po_lines_all pla
                                                                    WHERE  pla.attribute5 =
                                                                           (CASE
                                                                             WHEN (SELECT ch.plan_status
                                                                                   FROM   cux_pr_plan_headers ch
                                                                                   WHERE  ch.header_id =
                                                                                          r2.header_id) =
                                                                                  'DRAFT' THEN
                                                                              r2.attribute2
                                                                             ELSE
                                                                              to_char(r2.line_id)
                                                                           END)
                                                                    AND    rownum = 1))
                INTO   l_delivery_count
                FROM   dual;
              EXCEPTION
                WHEN OTHERS THEN
                  l_delivery_count := 0;
              END;
              BEGIN
                SELECT saaf_generate_tender_code.getreceivecount((SELECT pla.po_line_id
                                                                 FROM   po_lines_all pla
                                                                 WHERE  pla.attribute5 =
                                                                        (CASE
                                                                          WHEN (SELECT ch.plan_status
                                                                                FROM   cux_pr_plan_headers ch
                                                                                WHERE  ch.header_id =
                                                                                       r2.header_id) =
                                                                               'DRAFT' THEN
                                                                           r2.attribute2
                                                                          ELSE
                                                                           to_char(r2.line_id)
                                                                        END)
                                                                 AND    rownum = 1))
                INTO   l_revice_count
                FROM   dual;
              EXCEPTION
                WHEN OTHERS THEN
                  l_revice_count := 0;
              END;
            END IF;
          
            -- 更新数据
            UPDATE cux_pr_plan_lines cppl
            SET    cppl.has_delivery_count = l_delivery_count
                  ,cppl.has_revice_count   = l_revice_count
            WHERE  cppl.line_id = to_number(r2.attribute2);
            COMMIT;
          END LOOP;
        END IF;
      END LOOP;
    
    END IF;
  END upd_delivery_quality;

  /*==================================================
  Program Name:
       upd_pur_delivery_quality
  Description:
       提交时更新批量采购计划行上面的已送货数量和已接收数量
  
  History:
      1.00  2017/3/4   sie_zsl  Creation
  ==================================================*/
  PROCEDURE upd_pur_delivery_quality(p_header_id   IN NUMBER
                                    ,x_return_code OUT VARCHAR2
                                    ,x_return_msg  OUT VARCHAR2) IS
    l_version_num    NUMBER;
    l_header_id      NUMBER;
    l_plan_number    VARCHAR2(100);
    l_delivery_count NUMBER;
    l_revice_count   NUMBER;
  
  BEGIN
    BEGIN
      SELECT cph.version_num
            ,cph.plan_number
      INTO   l_version_num
            ,l_plan_number
      FROM   cux_pr_purchase_plan_headers cph
      WHERE  cph.header_id = p_header_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_version_num := 1;
    END;
  
    -- 如果版本不是第一个版本时，更新送货数量和接收数量
    IF l_version_num <> 1 THEN
    
      -- 循环版本
      FOR r1 IN REVERSE 1 .. l_version_num LOOP
        IF r1 <> 1 THEN
          -- 取出每个版本的头ID
          BEGIN
            SELECT cph.header_id
            INTO   l_header_id
            FROM   cux_pr_purchase_plan_headers cph
            WHERE  cph.version_num = r1
            AND    cph.plan_number = l_plan_number;
          EXCEPTION
            WHEN OTHERS THEN
              l_header_id := -1;
          END;
          -- 取出对应的行数据，更新上一版本数量
          FOR r2 IN (SELECT *
                     FROM   cux_pr_purchase_plan_lines cpl
                     WHERE  cpl.header_id = l_header_id) LOOP
            IF r1 = l_version_num THEN
              BEGIN
                SELECT saaf_generate_tender_code.getdeliveriedcount((SELECT pla.po_line_id
                                                                    FROM   po_lines_all pla
                                                                    WHERE  pla.attribute7 =
                                                                           (CASE
                                                                             WHEN (SELECT ch.plan_status
                                                                                   FROM   cux_pr_plan_headers ch
                                                                                   WHERE  ch.header_id =
                                                                                          r2.header_id) =
                                                                                  'DRAFT' THEN
                                                                              r2.attribute2
                                                                             ELSE
                                                                              to_char(r2.line_id)
                                                                           END)
                                                                    AND    rownum = 1))
                INTO   l_delivery_count
                FROM   dual;
              EXCEPTION
                WHEN OTHERS THEN
                  l_delivery_count := 0;
              END;
              BEGIN
                SELECT saaf_generate_tender_code.getreceivecount((SELECT pla.po_line_id
                                                                 FROM   po_lines_all pla
                                                                 WHERE  pla.attribute7 =
                                                                        (CASE
                                                                          WHEN (SELECT ch.plan_status
                                                                                FROM   cux_pr_purchase_plan_headers ch
                                                                                WHERE  ch.header_id =
                                                                                       r2.header_id) =
                                                                               'DRAFT' THEN
                                                                           r2.attribute2
                                                                          ELSE
                                                                           to_char(r2.line_id)
                                                                        END)
                                                                 AND    rownum = 1))
                INTO   l_revice_count
                FROM   dual;
              EXCEPTION
                WHEN OTHERS THEN
                  l_revice_count := 0;
              END;
            END IF;
          
            -- 更新数据
            UPDATE cux_pr_purchase_plan_lines cppl
            SET    cppl.has_delivery_count = l_delivery_count
                  ,cppl.has_revice_count   = l_revice_count
            WHERE  cppl.line_id = to_number(r2.attribute2);
            COMMIT;
          END LOOP;
        END IF;
      END LOOP;
    
    END IF;
  END upd_pur_delivery_quality;

  PROCEDURE getorgconinfo(p_header_id IN NUMBER) IS
  
  BEGIN
    SELECT cph.org_id
    INTO   cux_pr_plan_change_pkg.g_org_id
    FROM   cux_pr_plan_headers cph
    WHERE  cph.header_id = p_header_id;
  
    SELECT cph.contract_id
    INTO   cux_pr_plan_change_pkg.g_contract_id
    FROM   cux_pr_plan_headers cph
    WHERE  cph.header_id = p_header_id;
  
  END getorgconinfo;

  FUNCTION get_amount(p_header_id   IN NUMBER
                     ,p_category_id IN NUMBER) RETURN NUMBER IS
    l_amount NUMBER;
  BEGIN
    SELECT cph.org_id
    INTO   cux_pr_plan_change_pkg.g_org_id
    FROM   cux_pr_plan_headers cph
    WHERE  cph.header_id = p_header_id;
  
    SELECT cph.contract_id
    INTO   cux_pr_plan_change_pkg.g_contract_id
    FROM   cux_pr_plan_headers cph
    WHERE  cph.header_id = p_header_id;
  
    BEGIN
      SELECT DISTINCT cplan.sum_plan sum_plan
      INTO   l_amount
      FROM   cux_pr_plan_lines cpl
            ,cux_pr_plan_headers cph
            ,(SELECT tt.category_code
                    ,SUM(sum_plan) sum_plan
              FROM   (SELECT cpl.category_id
                            ,SUM(cpl.quantity * cpl.unit_price) sum_plan
                            ,(SELECT mcc.segment1 || '.' || mcc.segment2 || '.' ||
                                     mcc.segment3
                              FROM   mtl_categories mcc
                              WHERE  mcc.category_id = cpl.category_id) category_code
                      FROM   cux_pr_plan_lines   cpl
                            ,cux_pr_plan_headers cph
                      WHERE  cpl.header_id = cph.header_id
                      AND    cph.org_id = cux_pr_plan_change_pkg.g_org_id
                      AND    cph.contract_id =
                             cux_pr_plan_change_pkg.g_contract_id
                      AND    (SELECT mcc.segment1 || '.' || mcc.segment2 || '.' ||
                                     mcc.segment3
                              FROM   mtl_categories mcc
                              WHERE  mcc.category_id = cpl.category_id) =
                             (SELECT DISTINCT (mc.segment1 || '.' ||
                                               mc.segment2 || '.' ||
                                               mc.segment3)
                               FROM   mtl_categories mc
                               WHERE  EXISTS (SELECT 1
                                       FROM   cux_pr_plan_lines cppl
                                       WHERE  cppl.category_id =
                                              mc.category_id
                                       AND    EXISTS
                                        (SELECT 1
                                               FROM   cux_pr_plan_headers cpph
                                               WHERE  cpph.plan_number =
                                                      cph.plan_number
                                               AND    cppl.header_id =
                                                      cpph.header_id))
                               AND    rownum = 1)
                      AND    cph.version_num =
                             (SELECT MAX(cphh.version_num)
                               FROM   cux_pr_plan_headers cphh
                               WHERE  cphh.plan_number = cph.plan_number
                               AND    cphh.plan_status IN
                                      ('APPROVING', 'APPROVED', 'ORDERED'))
                      GROUP  BY cpl.category_id) tt
              GROUP  BY tt.category_code) cplan
      WHERE  cpl.header_id = cph.header_id
      AND    EXISTS
       (SELECT 1
              FROM   mtl_categories mcc
              WHERE  mcc.category_id = cpl.category_id
              AND    mcc.segment1 || '.' || mcc.segment2 || '.' ||
                     mcc.segment3 = cplan.category_code
              AND    rownum = 1)
      AND    cph.org_id = (SELECT DISTINCT cp.org_id
                           FROM   cux_pr_plan_headers cp
                           WHERE  cp.header_id = p_header_id)
      AND    cph.contract_id =
             (SELECT DISTINCT cp.contract_id
               FROM   cux_pr_plan_headers cp
               WHERE  cp.header_id = p_header_id)
      AND    (SELECT mcc.segment1 || '.' || mcc.segment2 || '.' ||
                     mcc.segment3
              FROM   mtl_categories mcc
              WHERE  mcc.category_id = cpl.category_id) =
             (SELECT DISTINCT (mc.segment1 || '.' || mc.segment2 || '.' ||
                               mc.segment3)
               FROM   mtl_categories mc
               WHERE  EXISTS
                (SELECT 1
                       FROM   cux_pr_plan_lines cppl
                       WHERE  cppl.category_id = mc.category_id
                       AND    EXISTS
                        (SELECT 1
                               FROM   cux_pr_plan_headers cpph
                               WHERE  cpph.plan_number = cph.plan_number
                               AND    cppl.header_id = cpph.header_id))
               AND    rownum = 1)
      AND    cph.version_num =
             (SELECT MAX(cphh.version_num)
               FROM   cux_pr_plan_headers cphh
               WHERE  cphh.plan_number = cph.plan_number
               AND    cphh.plan_status IN
                      ('APPROVING', 'APPROVED', 'ORDERED'))
      AND    cpl.category_id = p_category_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_amount := 0;
    END;
    dbms_output.put_line(l_amount || '===========');
    RETURN l_amount;
  END get_amount;

  /**获取规划金额*/
  PROCEDURE get_suprls_amount(p_header_id IN NUMBER
                             ,p_item_id   IN NUMBER
                             ,p_line_id   IN NUMBER) IS
  
    l_org_id      NUMBER;
    l_contract_id NUMBER;
    l_amount      NUMBER;
    l_item_code   VARCHAR2(200);
  
  BEGIN
    -- 获取物料编码
    BEGIN
      SELECT msb.segment1
      INTO   l_item_code
      FROM   mtl_system_items_b msb
      WHERE  msb.inventory_item_id = p_item_id
      AND    EXISTS
       (SELECT 1
              FROM   mtl_parameters mp
              WHERE  mp.master_organization_id = msb.organization_id);
    EXCEPTION
      WHEN OTHERS THEN
        l_item_code := NULL;
    END;
    -- 获取组织和合同
    BEGIN
      SELECT cph.org_id
            ,cph.contract_id
      INTO   l_org_id
            ,l_contract_id
      FROM   cux_pr_plan_headers cph
      WHERE  cph.header_id = p_header_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_org_id := NULL;
    END;
    -- 获取价格
    BEGIN
      SELECT DISTINCT wbv.sumq
      INTO   l_amount
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
                    ,SUM(wbt.fquantity) sumq /*规划数量*/
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
                       AND    wcct.fbomid = t.fbomid) OR EXISTS
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
                       ,t.segment3) wbv /*取物料清单和规划数量*/
            ,(SELECT mtl.category_id
                    ,mtl.description              cate_desc
                    ,mtl.concatenated_segments
                    ,mtl.segment1
                    ,mtl.segment2
                    ,mtl.segment3
                    ,msib.inventory_item_id
                    ,msib.segment1                item_num
                    ,msib.description             item_desc
                    ,msib.long_description
                    ,msib.primary_uom_code
                    ,msib.primary_unit_of_measure unit_name
              FROM   mtl_item_categories t
                    ,mtl_system_items_vl msib
                    ,(SELECT mc.category_id
                            ,mc.segment1
                            ,mc.segment2
                            ,mc.segment3
                            ,fnd_flex_ext.get_segs('INV',
                                                   'MCAT',
                                                   mc.structure_id,
                                                   mc.category_id) concatenated_segments
                            ,mc.description
                      FROM   mtl_categories mc
                      WHERE  mc.structure_id = 101
                      AND    (mc.disable_date IS NULL OR
                            mc.disable_date >= SYSDATE)
                      AND    mc.enabled_flag = 'Y') mtl
              WHERE  t.inventory_item_id = msib.inventory_item_id
              AND    t.organization_id = msib.organization_id
              AND    t.category_id = mtl.category_id
                    /* AND    msib.primary_uom_code = muom.uom_code*/
              AND    msib.organization_id = 460
              AND    t.category_set_id = 1) cateitem
            ,(SELECT cpl.category_id
                     /*,SUM(cpl.quantity * cpl.unit_price) sum_plan    */
                    ,cplan.sum_plan sum_plan
              FROM   cux_pr_plan_lines cpl
                    ,cux_pr_plan_headers cph
                    ,(SELECT tt.category_code
                            ,SUM(sum_plan) sum_plan
                      FROM   (SELECT cpl.category_id
                                    ,SUM(cpl.quantity * cpl.unit_price) sum_plan
                                    ,(SELECT mcc.segment1 || '.' ||
                                             mcc.segment2 || '.' ||
                                             mcc.segment3
                                      FROM   mtl_categories mcc
                                      WHERE  mcc.category_id =
                                             cpl.category_id) category_code
                              FROM   cux_pr_plan_lines   cpl
                                    ,cux_pr_plan_headers cph
                              WHERE  cpl.header_id = cph.header_id
                              AND    cph.org_id = l_org_id
                              AND    cph.contract_id = l_contract_id
                                    /*183641*/
                              AND    (SELECT mcc.segment1 || '.' ||
                                             mcc.segment2 || '.' ||
                                             mcc.segment3
                                      FROM   mtl_categories mcc
                                      WHERE  mcc.category_id =
                                             cpl.category_id) =
                                     (SELECT DISTINCT (mc.segment1 || '.' ||
                                                       mc.segment2 || '.' ||
                                                       mc.segment3)
                                       FROM   mtl_categories mc
                                       WHERE  EXISTS (SELECT 1
                                               FROM   cux_pr_plan_lines cppl
                                               WHERE  cppl.category_id =
                                                      mc.category_id
                                               AND    EXISTS
                                                (SELECT 1
                                                       FROM   cux_pr_plan_headers cpph
                                                       WHERE  cpph.plan_number =
                                                              cph.plan_number
                                                       AND    cppl.header_id =
                                                              cpph.header_id))
                                       AND    rownum = 1)
                              AND    cph.version_num =
                                     (SELECT MAX(cphh.version_num)
                                       FROM   cux_pr_plan_headers cphh
                                       WHERE  cphh.plan_number =
                                              cph.plan_number
                                       AND    cphh.plan_status IN
                                              ('APPROVING',
                                                'APPROVED',
                                                'ORDERED'))
                              GROUP  BY cpl.category_id) tt
                      GROUP  BY tt.category_code) cplan
              WHERE  cpl.header_id = cph.header_id
              AND    EXISTS
               (SELECT 1
                      FROM   mtl_categories mcc
                      WHERE  mcc.category_id = cpl.category_id
                      AND    mcc.segment1 || '.' || mcc.segment2 || '.' ||
                             mcc.segment3 = cplan.category_code
                      AND    rownum = 1)
              AND    cph.org_id = l_org_id
              AND    cph.contract_id = l_contract_id
                    /*183641*/
              AND    (SELECT mcc.segment1 || '.' || mcc.segment2 || '.' ||
                             mcc.segment3
                      FROM   mtl_categories mcc
                      WHERE  mcc.category_id = cpl.category_id) =
                     (SELECT DISTINCT (mc.segment1 || '.' || mc.segment2 || '.' ||
                                       mc.segment3)
                       FROM   mtl_categories mc
                       WHERE  EXISTS
                        (SELECT 1
                               FROM   cux_pr_plan_lines cppl
                               WHERE  cppl.category_id = mc.category_id
                               AND    EXISTS
                                (SELECT 1
                                       FROM   cux_pr_plan_headers cpph
                                       WHERE  cpph.plan_number =
                                              cph.plan_number
                                       AND    cppl.header_id = cpph.header_id))
                       AND    rownum = 1)
              AND    cph.version_num =
                     (SELECT MAX(cphh.version_num)
                       FROM   cux_pr_plan_headers cphh
                       WHERE  cphh.plan_number = cph.plan_number
                       AND    cphh.plan_status IN
                              ('APPROVING', 'APPROVED', 'ORDERED'))
              GROUP  BY cpl.category_id
                       ,cplan.sum_plan) planqty /*已计划数量*/
            ,wbd.wbd_project_t wpt
      WHERE  cateitem.segment1 = wbv.segment1
      AND    cateitem.segment2 = wbv.segment2
      AND    cateitem.segment3 = wbv.segment3
      AND    planqty.category_id(+) = cateitem.category_id
            -- AND    wcv.fconid = wbv.fconid
      AND    wpt.fprjno = wbv.fprjno
      AND    wpt.fiseffective = '1'
      AND    wpt.fwflowstate = '20'
      AND    NOT EXISTS
       (SELECT 1
              FROM   cux_pr_demand_headers cpdh
                    ,cux_pr_demand_lines   cpdl
              WHERE  cpdh.header_id = cpdl.header_id
              AND    cpdl.item_id = cateitem.inventory_item_id
              AND    cpdh.contract_id = wbv.fconid
              AND    rownum = 1)
      AND    wbv.fconid = l_contract_id
      AND    cateitem.item_num = l_item_code;
    EXCEPTION
      WHEN OTHERS THEN
        l_amount := 0;
    END;
    -- 更新数量
    UPDATE cux_pr_plan_lines cpl
    SET    cpl.surpl_plan_amount = round(l_amount, 2)
    WHERE  cpl.line_id = p_line_id;
    COMMIT;
  END get_suprls_amount;

END cux_pr_plan_change_pkg;
