CREATE OR REPLACE PACKAGE BODY cux_pr_plan_main_pkg IS
  FUNCTION get_add_date RETURN DATE IS
  BEGIN
    RETURN g_add_date;
  END;
  PROCEDURE generate_po_order(p_header_id     IN NUMBER
                             ,x_return_status OUT VARCHAR2
                             ,x_return_msg    OUT VARCHAR2) IS
    l_return_status VARCHAR2(1);
    l_return_msg    VARCHAR2(4000);
    l_batch_id      NUMBER;
    l_org_id        NUMBER;
    l_reject_count  NUMBER;
    l_accept_count  NUMBER;
    l_error_count   NUMBER;
  
    v_change_summary VARCHAR2(2000);
  
    l_document_number VARCHAR2(150);
    v_header_id       NUMBER;
  
    l_create_exp EXCEPTION;
    v_count         NUMBER;
    l_error_code    VARCHAR2(4000);
    l_line_id       NUMBER;
    l_po_header_id  NUMBER;
    l_error_message VARCHAR2(4000);
  BEGIN
  
    mo_global.init('PO');
    apps.fnd_global.apps_initialize(user_id      => 0
                                   ,resp_id      => 20707
                                   ,resp_appl_id => 201);
  
    SELECT COUNT(1)
      INTO v_count
      FROM po_lines_interface pli
     WHERE EXISTS (SELECT 1
              FROM cux_pr_plan_lines cpl
             WHERE cpl.header_id = p_header_id
               AND cpl.line_id = pli.line_attribute5)
       AND pli.process_code <> 'REJECTED';
  
    IF v_count > 0 THEN
      RETURN;
    END IF;
  
    insert_po_interface(p_header_id     => p_header_id
                       ,x_batch_id      => l_batch_id
                       ,x_org_id        => l_org_id
                       ,x_return_status => l_return_status
                       ,x_return_msg    => l_return_msg);
    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      x_return_msg := l_return_msg;
      RAISE l_create_exp;
    END IF;
  
    cux_ag_release_pkg.exec_po_api(p_batch_id      => l_batch_id
                                  ,p_org_id        => l_org_id
                                  ,p_doc_type      => 'STANDARD'
                                  ,x_return_status => l_return_status
                                  ,x_return_msg    => l_return_msg);
    IF (l_return_status <> fnd_api.g_ret_sts_success) THEN
      x_return_msg := '创建采购订单失败：' || l_return_msg;
      RAISE l_create_exp;
    ELSE
      l_accept_count := 0;
      l_reject_count := 0;
      --遍历接口表行，判断每个行是否都成功了
      FOR r1 IN (SELECT pohi.po_header_id
                       ,poli.process_code
                       ,poli.po_line_id
                       ,poli.line_attribute5
                       ,pohi.attribute9
                       ,pohi.from_header_id
                   FROM po_headers_interface pohi
                       ,po_lines_interface   poli
                  WHERE pohi.interface_header_id = poli.interface_header_id
                    AND pohi.batch_id = l_batch_id
                    AND pohi.interface_source_code IN
                        ('INSPECTION_PLAN'
                        ,'ADDITIONAL_PLAN'
                        ,'PR_PLAN')) LOOP
        IF (r1.process_code = 'ACCEPTED') THEN
          l_accept_count := l_accept_count + 1;
        
        ELSE
          l_reject_count := l_reject_count + 1;
        END IF;
      END LOOP;
    
      --如果存在失败的行，则遍历接口的错误表，提取错误信息
      IF (l_reject_count > 0) THEN
        l_return_msg  := '';
        l_error_count := 1;
      
        FOR r2 IN (SELECT error_message
                     FROM po_interface_errors
                    WHERE interface_header_id IN
                          (SELECT pohi.interface_header_id
                             FROM po_headers_interface pohi
                            WHERE pohi.batch_id = l_batch_id)) LOOP
          l_return_msg  := l_return_msg || l_error_count || '.' ||
                           r2.error_message || '<br>';
          l_error_count := l_error_count + 1;
        
        END LOOP;
      
        --删除部分已经生成的订单，全部完成才算成功
        --删除行
        DELETE FROM po_lines_all pla
         WHERE pla.po_line_id IN
               (SELECT poli.po_line_id
                  FROM po_headers_interface pohi
                      ,po_lines_interface   poli
                 WHERE pohi.interface_header_id = poli.interface_header_id
                   AND pohi.batch_id = l_batch_id
                   AND pohi.interface_source_code IN
                       ('INSPECTION_PLAN'
                       ,'ADDITIONAL_PLAN'
                       ,'PR_PLAN'));
      
        --删除头
        DELETE FROM po_headers_all pla
         WHERE pla.po_header_id IN (SELECT pohi.po_header_id
                                      FROM po_headers_interface pohi
                                     WHERE pohi.batch_id = l_batch_id
                                       AND pohi.interface_source_code IN
                                           ('INSPECTION_PLAN'
                                           ,'ADDITIONAL_PLAN'
                                           ,'PR_PLAN'));
      
        /*IF (l_accept_count > 0) THEN
          UPDATE cux_pr_plan_headers cph
        SET    cph.plan_status = 'PARTORDER'
        WHERE  cph.header_id = p_header_id;
        
        END IF;*/
      
        x_return_status := 'E';
        x_return_msg    := '创建采购订单失败，原因为：' || l_return_msg;
      
      END IF;
    
      IF l_reject_count = 0 THEN
      
        UPDATE cux_pr_plan_headers cph
           SET cph.plan_status = 'ORDERED'
         WHERE cph.header_id = p_header_id;
      
      END IF;
    
      /*      --全部创建成功
      IF (L_REJECT_COUNT = 0)
      THEN
        UPDATE CUX_LXDD_CART_HEADERS CSH
        SET    CSH.STATUS            = 'Y'
              ,CSH.LAST_UPDATE_DATE  = SYSDATE
              ,CSH.LAST_UPDATED_BY   = FND_GLOBAL.USER_ID
              ,CSH.LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
        WHERE  CSH.CART_HEADER_ID = P_CART_HEADER_ID;
        COMMIT;
        X_RETURN_MSG    := '创建订单成功。';
        X_RETURN_STATUS := 'Y';
        --部分创建成功
      ELSIF (L_REJECT_COUNT > 0 AND L_ACCEPT_COUNT > 0)
      THEN
        UPDATE CUX_LXDD_CART_HEADERS CSH
        SET    CSH.STATUS            = 'P'
              ,CSH.LAST_UPDATE_DATE  = SYSDATE
              ,CSH.LAST_UPDATED_BY   = FND_GLOBAL.USER_ID
              ,CSH.LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
        WHERE  CSH.CART_HEADER_ID = P_CART_HEADER_ID;
        COMMIT;
        X_RETURN_MSG    := '<html>创建采购订单部分成功！失败部分原因如下：<br>' || L_RETURN_MSG ||
                           '</html>';
        X_RETURN_STATUS := 'P';
      ELSE
        ROLLBACK;
        X_RETURN_MSG    := '<html>创建采购订单失败！原因如下：<br>' || L_RETURN_MSG ||
                           '</html>';
        X_RETURN_STATUS := 'N';
      END IF;*/
    
    END IF;
    COMMIT;
  
    --获取采购订单id
    BEGIN
      SELECT cpl.line_id
        INTO l_line_id
        FROM cux_pr_plan_headers cpr
            ,cux_pr_plan_lines   cpl
       WHERE cpr.header_id = cpl.header_id
         AND cpr.header_id = p_header_id
         AND rownum = 1;
    EXCEPTION
      WHEN OTHERS THEN
        l_line_id := NULL;
    END;
  
    BEGIN
      SELECT poh.po_header_id
        INTO l_po_header_id
        FROM po_headers_all poh
       WHERE 1 = 1
         AND EXISTS
       (SELECT 1
                FROM po_lines_all pol
               WHERE pol.attribute5 = l_line_id
                 AND pol.po_header_id = poh.po_header_id);
    EXCEPTION
      WHEN OTHERS THEN
        l_po_header_id := NULL;
    END;
  
    UPDATE po_headers_all poh
       SET poh.revision_num = 1
     WHERE poh.po_header_id = l_po_header_id;
  
    COMMIT;
    
    --added by sie 20170926 根据公式进行调价
    srm_adjustset_pkg.generate_po(p_po_header_id => p_header_id
                                 ,p_errorcode    => l_error_code
                                 ,p_errorname    => l_error_message);
  
    --发送通知
    cux_fnd_login_main_pkg.send_notification(p_document_id   => p_header_id
                                            ,p_notice_type   => 'CUXNOTICE38'
                                            ,x_error_code    => l_error_code
                                            ,x_error_message => l_error_message);
  
    --发送邮件
    cux_fnd_login_main_pkg.send_email(p_document_id => p_header_id
                                     ,p_mail_type   => 'CUXEMAIL12');
  EXCEPTION
    WHEN l_create_exp THEN
      ROLLBACK;
      x_return_status := 'E';
    WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := 'E';
      x_return_msg    := '创建采购订单失败，原因为：' || SQLERRM;
  END generate_po_order;

  --根据最新月度供货计划ID找到历史版本最大的月度计划ID
  FUNCTION get_pr_plan_id(p_header_id IN NUMBER) RETURN NUMBER IS
  
    l_header_id NUMBER;
  
  BEGIN
  
    BEGIN
    
      SELECT cpr.header_id
        INTO l_header_id
        FROM cux_pr_plan_headers cpr
       WHERE 1 = 1
         AND cpr.plan_status = 'ORDERED'
         AND cpr.last_update_date =
             (SELECT MAX(cpr1.last_update_date)
                FROM cux_pr_plan_headers cpr1
                    ,cux_pr_plan_headers cpr2
               WHERE 1 = 1
                 AND cpr1.plan_status = 'ORDERED'
                 AND cpr1.plan_number = cpr2.plan_number
                 AND cpr1.plan_number = cpr.plan_number
                 AND cpr2.header_id = p_header_id
                 AND cpr1.last_update_date < cpr2.last_update_date);
    
    EXCEPTION
      WHEN OTHERS THEN
        l_header_id := p_header_id;
    END;
  
    RETURN l_header_id;
  END;

  --根据月度计划头ID找到历史订单信息
  FUNCTION get_po_header_id(p_header_id IN NUMBER) RETURN NUMBER IS
    l_line_id      NUMBER;
    l_po_header_id NUMBER;
  BEGIN
    SELECT to_number(cpl.attribute2) line_id
      INTO l_line_id
      FROM cux_pr_plan_headers cpr
          ,cux_pr_plan_lines   cpl
     WHERE 1 = 1
       AND cpr.header_id = cpl.header_id
       AND cpr.header_id = p_header_id
       AND rownum = 1;
  
    SELECT poh.po_header_id
      INTO l_po_header_id
      FROM po_headers_all poh
     WHERE 1 = 1
       AND EXISTS (SELECT 1
              FROM po_lines_all pol
             WHERE pol.po_header_id = poh.po_header_id
               AND pol.attribute5 = l_line_id);
    RETURN l_po_header_id;
  END;

  PROCEDURE update_po_interface(p_header_id     IN NUMBER
                               ,x_return_status OUT VARCHAR2
                               ,x_return_msg    OUT VARCHAR2) IS
  
    l_iface_rec       po.po_headers_interface%ROWTYPE;
    l_iface_lines_rec po.po_lines_interface%ROWTYPE;
  
    l_version_num  NUMBER;
    l_pr_plan_id   NUMBER;
    l_po_header_id NUMBER;
  
    l_result           NUMBER;
    l_progress         NUMBER;
    l_errors           po_api_errors_rec_type;
    l_chg              po_changes_rec_type;
    l_shipment_changes po_shipments_rec_type;
    l_return_status    VARCHAR2(30);
  
    l_need_by_date   DATE;
    l_quantity       NUMBER;
    l_pr_line_id     NUMBER;
    l_version_number NUMBER;
    l_quantity_bf    NUMBER;
    l_remark         VARCHAR2(240);
  
    l_error_code    VARCHAR2(4000);
    l_error_message VARCHAR2(4000);
    l_count         NUMBER;
  
    CURSOR csr_po_plan(p_pr_plan_id IN NUMBER) IS
      SELECT DISTINCT pol.po_header_id
        FROM cux_pr_plan_lines cpl
            ,po_lines_all      pol
       WHERE cpl.header_id = p_pr_plan_id
         AND pol.attribute9 = cpl.ag_line_id
         AND pol.attribute5 = cpl.line_id;
  BEGIN
  
    --l_po_header_id := get_po_header_id(p_header_id);
  
    l_pr_plan_id := get_pr_plan_id(p_header_id);
  
    FOR rec_po_plan IN csr_po_plan(l_pr_plan_id) LOOP
    
      l_po_header_id := rec_po_plan.po_header_id;
    
      /*--找出在订单行里面在最新版本月度计划的条数，如果不存在，则将订单变成未完成
      begin
        select count(1)
          into l_count
          from po_lines_all pol
         where pol.po_header_id = l_po_header_id
           and pol.attribute9 in
               (select cpl.ag_line_id from cux_pr_plan_lines cpl where
                cpl.header_id = p_header_id);
      exception
        when others then
          l_count := null;
      end;
      
      if l_count=0 then
        update po_headers_all poh
           set poh.authorization_status = 'INCOMPLETE',
               poh.approved_flag        = 'R'
         where poh.po_header_id = l_po_header_id;
      commit;
      CONTINUE;
      end if;*/
    
      --在最新版本的月度计划不存在的采购订单行先存入临时表
      INSERT INTO cux_po_lines_all
        SELECT *
          FROM po_lines_all pol
         WHERE 1 = 1
           AND pol.po_header_id = l_po_header_id
           AND NOT EXISTS
         (SELECT 1
                  FROM cux_pr_plan_lines cpl
                 WHERE cpl.header_id = p_header_id
                   AND cpl.attribute2 = pol.attribute5);
    
      --删除在最新版本的月度计划不存在的采购订单行
      DELETE FROM po_lines_all pol
       WHERE 1 = 1
         AND pol.po_header_id = l_po_header_id
         AND NOT EXISTS
       (SELECT 1
                FROM cux_pr_plan_lines cpl
               WHERE cpl.header_id = p_header_id
                 AND cpl.attribute2 = pol.attribute5);
    
      SELECT COUNT(1)
        INTO l_count
        FROM po_lines_all pol
       WHERE 1 = 1
         AND pol.po_header_id = l_po_header_id;
    
      IF l_count = 0 THEN
        /*订单行全部删除后*/
        UPDATE po_headers_all poh
           SET poh.authorization_status = 'INCOMPLETE'
              ,poh.approved_flag        = 'R'
         WHERE poh.po_header_id = l_po_header_id;
        COMMIT;
      
      ELSE
      
        COMMIT;
        --初始化
        mo_global.set_policy_context('S'
                                    ,2253);
      
        fnd_global.apps_initialize(user_id      => 0
                                  ,resp_id      => 20707
                                  ,resp_appl_id => 201);
      
        --更新最新月度供货计划对应的采购订单行需求数量和需求日期
        FOR rec_po_lines IN (SELECT pol.quantity
                                   ,pol.po_line_id
                                   ,pol.line_num
                                   ,pol.attribute5
                                   ,(SELECT polla.line_location_id
                                       FROM po_line_locations_all polla
                                      WHERE polla.po_line_id =
                                            pol.po_line_id
                                        AND rownum = 1) line_location_id
                                   ,(SELECT polla.need_by_date
                                       FROM po_line_locations_all polla
                                      WHERE polla.po_line_id =
                                            pol.po_line_id
                                        AND rownum = 1) need_by_date
                               FROM po_lines_all pol
                              WHERE pol.po_header_id = l_po_header_id) LOOP
          --通过attribute5找到最新月度供货计划行的需求日期和需求数量
          BEGIN
            SELECT cpl.quantity
                  ,cpl.need_by_date
                  ,cpl.line_id
                  ,cpl.attribute1
              INTO l_quantity
                  ,l_need_by_date
                  ,l_pr_line_id
                  ,l_remark
              FROM cux_pr_plan_headers cpr
                  ,cux_pr_plan_lines   cpl
             WHERE 1 = 1
               AND cpr.header_id = p_header_id
               AND cpr.header_id = cpl.header_id
               AND (cpl.attribute2 = rec_po_lines.attribute5 OR
                   cpl.line_id = rec_po_lines.attribute5);
          EXCEPTION
            WHEN OTHERS THEN
              l_quantity     := NULL;
              l_need_by_date := NULL;
              l_pr_line_id   := NULL;
              l_remark       := NULL;
          END;
        
          l_chg := po_changes_rec_type.create_object(p_po_header_id  => l_po_header_id
                                                    ,p_po_release_id => NULL);
        
          l_chg.line_changes.add_change(p_po_line_id => rec_po_lines.po_line_id
                                       ,p_quantity   => l_quantity);
        
          l_chg.shipment_changes.add_change(p_po_line_location_id => rec_po_lines.line_location_id
                                           ,p_quantity            => l_quantity
                                           ,p_need_by_date        => l_need_by_date);
        
          po_document_update_grp.update_document(p_api_version           => 1.0
                                                , -- pass this as 1.0
                                                 p_init_msg_list         => fnd_api.g_true
                                                , -- pass this as TRUE
                                                 x_return_status         => l_return_status
                                                , -- returns the result of execution
                                                 p_changes               => l_chg
                                                , -- changes obj. contains all changes intended to be made on document
                                                 p_run_submission_checks => fnd_api.g_false
                                                , -- set to TRUE if want to perform submission check
                                                 p_launch_approvals_flag => fnd_api.g_false
                                                , -- set to TRUE if want to launch approval work flow after making the changes
                                                 p_buyer_id              => NULL
                                                , -- buyer id
                                                 p_update_source         => NULL
                                                , -- name of a source who is calling this API. In case of manual call can be passed as NULL
                                                 p_override_date         => NULL
                                                ,x_api_errors            => l_errors
                                                , -- list of errors if any occurred in execution
                                                 p_mass_update_releases  => NULL);
        
          --明细行需求数量与第一版订单需求数量不同时，修改原备注
        
          SELECT cpl.quantity
            INTO l_quantity_bf
            FROM cux_pr_plan_lines cpl
           WHERE cpl.line_id = rec_po_lines.attribute5;
        
          IF l_quantity_bf <> l_quantity THEN
            IF (l_remark IS NOT NULL) THEN
              l_remark := l_remark || '数量由' || l_quantity_bf || '调整为' ||
                          l_quantity;
            ELSE
              l_remark := '数量由' || l_quantity_bf || '调整为' || l_quantity;
            END IF;
          END IF;
        
          UPDATE cux_pr_plan_lines cpl
             SET cpl.attribute1 = l_remark
           WHERE cpl.line_id = l_pr_line_id;
        
          IF l_errors IS NOT NULL THEN
          
            FOR i IN 1 .. l_errors.message_text.count LOOP
              dbms_output.put_line(' Error is ' ||
                                   l_errors.message_text(i) || ' - name' ||
                                   l_errors.message_name(i));
            END LOOP;
          END IF;
          COMMIT;
        
          --
          UPDATE po_lines_all pol
             SET pol.line_num = rec_po_lines.line_num
           WHERE pol.po_line_id = rec_po_lines.po_line_id;
        
          --更新采购行的attribute5
          UPDATE po_lines_all pol
             SET pol.attribute5 = nvl(l_pr_line_id
                                     ,pol.attribute5)
           WHERE pol.po_line_id = rec_po_lines.po_line_id;
        
          IF l_quantity = 0 THEN
          
            UPDATE po_lines_all pol
               SET pol.quantity = l_quantity
             WHERE pol.po_line_id = rec_po_lines.po_line_id;
          
            UPDATE po_line_locations_all pol
               SET pol.quantity = l_quantity
             WHERE pol.po_line_id = rec_po_lines.line_location_id;
          
          END IF;
        
          COMMIT;
        
        END LOOP;
      
        SELECT cpr.version_num
          INTO l_version_number
          FROM cux_pr_plan_headers cpr
         WHERE cpr.header_id = p_header_id;
      
        /*UPDATE po_headers_all poh
          SET poh.revision_num = l_version_number
        WHERE poh.po_header_id = l_po_header_id;*/
      
        --清空订单确认时间
        UPDATE cux_po_confirm_headers_all cpc
           SET cpc.confirm_date = NULL
         WHERE cpc.po_header_id = l_po_header_id
           AND cpc.attribute1 = to_char(l_version_number);
      
        po_document_action_pvt.do_approve(p_document_id      => l_po_header_id
                                         ,p_document_type    => 'PO'
                                         ,p_document_subtype => 'STANDARD'
                                         ,p_note             => NULL
                                         ,p_approval_path_id => NULL
                                         ,x_return_status    => l_error_code
                                         ,x_exception_msg    => l_error_message);
      
        COMMIT;
      
      END IF;
    
    END LOOP;
  
    --发送通知
    cux_fnd_login_main_pkg.send_notification(p_document_id   => p_header_id
                                            ,p_notice_type   => 'CUXNOTICE46'
                                            ,x_error_code    => l_error_code
                                            ,x_error_message => l_error_message);
  
    --发送邮件
    cux_fnd_login_main_pkg.send_email(p_document_id => p_header_id
                                     ,p_mail_type   => 'CUXEMAIL20');
  
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
    
  END;

  PROCEDURE insert_po_interface(p_header_id     IN NUMBER
                               ,x_batch_id      OUT NUMBER
                               ,x_org_id        OUT NUMBER
                               ,x_return_status OUT VARCHAR2
                               ,x_return_msg    OUT VARCHAR2) IS
    l_msg_html         VARCHAR2(4000);
    l_return_status    VARCHAR2(1);
    l_count            NUMBER;
    l_org_id           NUMBER;
    l_org_name         VARCHAR2(240);
    l_organization_id  NUMBER;
    l_agent_id         NUMBER;
    l_status           VARCHAR2(1);
    l_category_id      NUMBER;
    l_category_name    VARCHAR2(240);
    l_item_id          NUMBER;
    l_item_code        VARCHAR2(30);
    l_item_description VARCHAR2(240);
    l_unit_meas        VARCHAR2(30);
    l_unit_code        VARCHAR2(30);
    l_currency_code    VARCHAR2(30);
    l_unit_price       NUMBER;
    l_not_tax_price    NUMBER;
    l_is_bestow        VARCHAR2(1);
    l_enabled_flag     VARCHAR2(1);
    l_attr_category    NUMBER;
    l_batch_id         NUMBER;
    l_intfc_header_id  NUMBER;
    l_intfc_line_id    NUMBER;
    l_no_tax_price     NUMBER;
    l_line_num         NUMBER;
    l_vendor_site_id   NUMBER;
  
    l_rate_type VARCHAR2(30);
    l_rate_date DATE;
    v_count     NUMBER;
  
    v_project_id       NUMBER;
    v_project_block_id NUMBER;
  
    l_create_exp EXCEPTION;
    l_document_num VARCHAR2(240);
  
    l_code   VARCHAR2(240);
    l_number NUMBER;
  
    l_plan_org_id VARCHAR2(20);
  
  BEGIN
    l_return_status := fnd_api.g_ret_sts_success;
    l_msg_html      := '<html>';
  
    l_org_id   :=  /*fnd_global.org_id*/
     2253;
    l_agent_id := 3386; --fnd_global.employee_id;
  
/*    --获取采购编号
    SELECT saaf_generate_receive_code.generate_po_code
      INTO l_document_num
      FROM dual;
  
    SELECT to_number(substr(l_document_num
                           ,5))
      INTO l_number
      FROM dual;
  
    SELECT to_number(substr(l_document_num
                           ,1
                           ,4))
      INTO l_code
      FROM dual;
  
    l_number := l_number - 1;*/
  
    --获取业务实体名称
    BEGIN
      SELECT hou.name
        INTO l_org_name
        FROM hr_operating_units hou
       WHERE hou.organization_id = l_org_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_org_name := NULL;
    END;
  
    --验证采购员是否有效
    SELECT COUNT(1)
      INTO l_count
      FROM hr_operating_units hou
     WHERE (hou.date_from IS NULL OR hou.date_from <= SYSDATE)
       AND (hou.date_to IS NULL OR hou.date_to >= SYSDATE)
       AND hou.organization_id = l_org_id
       AND EXISTS (SELECT 1
              FROM hr_all_organization_units hao
             WHERE hao.organization_id = hou.organization_id
               AND hao.attribute13 = 'Y');
  
    IF (l_count = 0) THEN
      l_msg_html := l_msg_html || '当前组织不是材料公司，不能下单。<br>';
      RAISE l_create_exp;
    END IF;
  
    --验证采购员是否有效
    SELECT COUNT(pa.agent_id)
      INTO l_count
      FROM po_agents pa
     WHERE trunc(SYSDATE) BETWEEN trunc(pa.start_date_active) AND
           trunc(nvl(pa.end_date_active
                    ,SYSDATE))
       AND pa.agent_id = l_agent_id;
    IF (l_count = 0) THEN
      l_msg_html := l_msg_html || '当前采购员无效。<br>';
      RAISE l_create_exp;
    END IF;
  
    --查询当前的业务实体，是否启用了非全局的弹性域
    BEGIN
      SELECT enabled_flag
        INTO l_enabled_flag
        FROM fnd_descr_flex_contexts
       WHERE descriptive_flex_context_code = to_char(l_org_id)
         AND descriptive_flexfield_name = 'PO_HEADERS';
      IF (l_enabled_flag = 'Y') THEN
        l_attr_category := l_org_id;
      ELSE
        l_attr_category := NULL;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        l_enabled_flag  := 'N';
        l_attr_category := NULL;
    END;
  
    SELECT cux.cux_po_interface_batch_s.nextval
      INTO l_batch_id
      FROM dual;
  
    FOR r1 IN (SELECT DISTINCT pha.vendor_id
                              ,pha.currency_code
                              ,hou.location_id ship_to_location_id
                              ,cph.org_id project_org_id
                              ,cph.contract_id
                              ,cph.plan_type
                              ,decode(cph.plan_type
                                     ,'SPOT_CHECK_ORDERS'
                                     ,'INSPECTION_PLAN'
                                     ,'ADD_ORDERS'
                                     ,'ADDITIONAL_PLAN'
                                     ,'PR_PLAN') order_type
                 FROM cux_pr_plan_lines         cpl
                     ,cux_pr_plan_headers       cph
                     ,po_headers_all            pha
                     ,po_vendor_sites_all       pvs
                     ,hr_all_organization_units hou
                WHERE cpl.ag_header_id = pha.po_header_id
                  AND pha.vendor_site_id = pvs.vendor_site_id
                  AND cph.header_id = cpl.header_id
                  AND hou.organization_id = l_org_id
                  AND cph.header_id = p_header_id) LOOP
    
      /*      l_is_bestow := cux_dzcg_util_pkg.is_bestow_to_org(r1.ag_header_id,
                                                        l_org_id);
      IF (l_is_bestow <> 'Y') THEN
        l_msg_html      := l_msg_html || '协议：' || r1.segment1 ||
                           '，不能用于当前业务实体。<br>';
        l_return_status := fnd_api.g_ret_sts_unexp_error;
      END IF;*/
    
      --获取订单编号
      /*l_number       := l_number + 1;*/
    --获取采购编号
    SELECT saaf_generate_receive_code.generate_po_code
      INTO l_document_num
      FROM dual;
  
    SELECT to_number(substr(l_document_num
                           ,5))
      INTO l_number
      FROM dual;
  
    SELECT to_number(substr(l_document_num
                           ,1
                           ,4))
      INTO l_code
      FROM dual;
      l_document_num := l_code || lpad(to_char(l_number)
                                      ,6
                                      ,'0');
      --验证供应商地点
      BEGIN
        SELECT pvs1.vendor_site_id
          INTO l_vendor_site_id
          FROM po_vendor_sites_all pvs1
         WHERE pvs1.org_id = l_org_id
           AND nvl(purchasing_site_flag
                  ,'N') = 'Y'
           AND trunc(nvl(inactive_date
                        ,SYSDATE + 1)) > trunc(SYSDATE)
           AND pvs1.vendor_id = r1.vendor_id
           AND rownum < 2;
      EXCEPTION
        WHEN OTHERS THEN
          l_vendor_site_id := 0;
      END;
      IF (l_vendor_site_id = 0) THEN
        l_msg_html      := l_msg_html || '供应商地点没有分配给当前业务实体或已失效。<br>';
        l_return_status := fnd_api.g_ret_sts_unexp_error;
      END IF;
    
      SELECT po_headers_interface_s.nextval
        INTO l_intfc_header_id
        FROM dual;
    
      --add by jinshaojun@chinasie.com 20140707
      SELECT COUNT(1)
        INTO v_count
        FROM financials_system_params_all fs
            ,gl_ledgers                   gl
       WHERE gl.ledger_id = fs.set_of_books_id
         AND fs.org_id = l_org_id
         AND gl.currency_code = nvl(r1.currency_code
                                   ,gl.currency_code);
    
      /*      IF v_count = 0 THEN
        l_rate_type := r1.rate_type;
        l_rate_date := trunc(SYSDATE);
      ELSE
        l_rate_type := NULL;
        l_rate_date := NULL;
      END IF;*/
    
      SELECT wct.fprjno
            ,wct.fpbno
        INTO v_project_id
            ,v_project_block_id
        FROM wpc_contract_t wct
       WHERE wct.fconid = r1.contract_id;
    
      IF r1.plan_type = 'SPOT_CHECK_ORDERS' THEN
        l_plan_org_id := 2253;
      ELSE
        l_plan_org_id := r1.project_org_id;
      END IF;
    
      --insert接口头表
      INSERT INTO po_headers_interface
        (interface_header_id
        ,batch_id
        ,interface_source_code
        ,process_code
        ,action
        ,document_subtype
        ,approval_status
        ,style_id
        ,from_header_id
        ,org_id
        ,
         --REVISION_NUM,
         bill_to_location_id
        ,ship_to_location_id
        ,agent_id
        ,currency_code
        ,vendor_id
        ,vendor_site_id
        ,rate_type
        ,rate
        ,rate_date
        ,attribute1
        ,attribute11
        ,attribute12
        ,document_num)
      VALUES
        (l_intfc_header_id
        ,l_batch_id
        ,r1.order_type
        ,'PENDING'
        ,'ORIGINAL'
        ,'STANDARD'
        ,'APPROVED'
        ,1
        ,NULL
        ,l_org_id
        ,
         --  1,
         r1.ship_to_location_id
        ,r1.ship_to_location_id
        ,l_agent_id
        ,r1.currency_code
        ,r1.vendor_id
        ,l_vendor_site_id
        ,l_rate_type
        ,
         /*r1.rate*/NULL
        ,l_rate_date
        ,l_plan_org_id
        ,l_org_id
        ,l_org_name
        ,l_document_num);
    
      l_line_num := 0;
    
      FOR r2 IN (SELECT cpl.line_id
                       ,cpl.ag_header_id
                       ,cpl.ag_line_id
                       ,cpl.item_id
                       ,cpl.quantity
                       ,cpl.need_by_date
                       ,trunc(cpl.unit_price
                             ,4) tax_price
                       ,trunc(cpl.unit_price /
                              (1 + zrb.percentage_rate / 100)
                             ,4) unit_price /*不含税单价*/
                       ,cpl.uom_code
                       ,cpl.rate_id
                       ,cph.org_id
                       ,hou.location_id ship_to_location_id
                       ,cph.contract_id
                       ,cpl.attribute4
                   FROM cux_pr_plan_lines         cpl
                       ,cux_pr_plan_headers       cph
                       ,hr_all_organization_units hou
                       ,zx_rates_b                zrb
                 
                  WHERE cpl.header_id = p_header_id
                    AND cph.header_id = cpl.header_id
                    AND hou.organization_id = l_org_id /*cph.org_id*/
                    AND cpl.rate_id = zrb.tax_rate_id
                    AND (zrb.effective_to IS NULL OR
                        zrb.effective_to >= SYSDATE)
                    AND EXISTS
                  (SELECT 1
                           FROM po_headers_all pha
                          WHERE pha.po_header_id = cpl.ag_header_id
                            AND pha.vendor_id = r1.vendor_id)) LOOP
      
        l_line_num := l_line_num + 1;
      
        l_unit_code  := r2.uom_code;
        l_item_id    := NULL;
        l_unit_price := r2.unit_price;
      
        BEGIN
          SELECT l.unit_price
            INTO l_unit_price
            FROM po_lines_all   l
                ,po_headers_all h
                ,zx_rates_b     zrb
           WHERE l.po_header_id = h.po_header_id
             AND h.type_lookup_code = 'BLANKET'
             AND h.attribute6 IS NOT NULL
             AND zrb.tax_rate_code = h.attribute6
             AND l.po_line_id = r2.ag_line_id
             AND trunc(nvl(l.attribute11
                          ,l.unit_price *
                           (1 + nvl(zrb.percentage_rate
                                   ,0) / 100))
                      ,4) = r2.tax_price;
        
        EXCEPTION
          WHEN OTHERS THEN
            NULL;
        END;
      
        SELECT ood.organization_id
          INTO l_organization_id
          FROM hr_locations_all             hla
              ,org_organization_definitions ood
         WHERE hla.inventory_organization_id = ood.organization_id
           AND hla.bill_to_site_flag = 'Y'
           AND hla.location_id = r2.ship_to_location_id;
      
        --校验物料是否有效
        BEGIN
        
          SELECT msib.inventory_item_id
            INTO l_item_id
            FROM mtl_system_items_b msib
           WHERE msib.organization_id = l_organization_id
             AND trunc(SYSDATE) BETWEEN
                 trunc(nvl(msib.start_date_active
                          ,SYSDATE)) AND
                 trunc(nvl(msib.end_date_active
                          ,SYSDATE))
             AND msib.inventory_item_status_code <> 'Inactive'
             AND msib.purchasing_enabled_flag = 'Y'
             AND msib.inventory_item_id = r2.item_id;
        
        EXCEPTION
          WHEN no_data_found THEN
            l_msg_html      := l_msg_html || '物料没有分配到当前组织或已失效。<br>';
            l_return_status := fnd_api.g_ret_sts_unexp_error;
        END;
      
        BEGIN
          SELECT mom.unit_of_measure_tl
            INTO l_unit_meas
            FROM mtl_units_of_measure_vl mom
           WHERE mom.uom_code = l_unit_code
             AND (mom.disable_date IS NULL OR
                 mom.disable_date >= trunc(SYSDATE));
        EXCEPTION
          WHEN OTHERS THEN
          
            l_msg_html      := l_msg_html || '单位：' || l_unit_code ||
                               ' 不存在或已失效。<br>';
            l_return_status := fnd_api.g_ret_sts_unexp_error;
        END;
      
        SELECT po_lines_interface_s.nextval
          INTO l_intfc_line_id
          FROM dual;
      
        BEGIN
          SELECT enabled_flag
            INTO l_enabled_flag
            FROM fnd_descr_flex_contexts
           WHERE descriptive_flex_context_code = to_char(l_org_id)
             AND descriptive_flexfield_name = 'PO_LINES';
          IF (l_enabled_flag = 'Y') THEN
            l_attr_category := l_org_id;
          ELSE
            l_attr_category := NULL;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            l_enabled_flag  := 'N';
            l_attr_category := NULL;
        END;
      
        --insert接口行表
        INSERT INTO po_lines_interface
          (interface_line_id
          ,interface_header_id
          ,line_num
          ,shipment_num
          ,item_id
          ,uom_code
          ,quantity
          ,unit_price
          ,category_id
          ,need_by_date
          ,promised_date
          ,line_type_id
          ,process_code
          ,receiving_routing_id
           --,from_header_id
           --,from_line_id
          ,line_attribute1
          ,line_attribute2
          ,line_attribute3
          ,line_attribute5
          ,line_attribute6
          ,line_attribute9
          ,line_attribute11
          ,min_order_quantity
          ,line_attribute12)
        VALUES
          (l_intfc_line_id
          ,l_intfc_header_id
          ,l_line_num
          ,1
          ,l_item_id
          ,l_unit_code
          ,r2.quantity
          ,l_unit_price
          ,l_category_id
          ,r2.need_by_date
          ,r2.need_by_date
          ,1
          ,'PENDING'
          ,3
           -- ,r2.ag_header_id
           -- ,r2.ag_line_id
          ,v_project_id
          ,v_project_block_id
          ,r1.contract_id
          ,r2.line_id
          ,r2.rate_id
          ,r2.ag_line_id
          ,r2.tax_price
          ,r2.attribute4
          ,r2.attribute4);
      
        --insert 分配行接口表
        INSERT INTO po_distributions_interface
          (interface_header_id
          ,interface_line_id
          ,interface_distribution_id
          ,distribution_num
          ,quantity_ordered
          ,org_id)
        VALUES
          (l_intfc_header_id
          ,l_intfc_line_id
          ,po_distributions_interface_s.nextval
          ,1
          ,r2.quantity
          ,r2.org_id);
      
      END LOOP;
    END LOOP;
  
    IF (l_return_status = fnd_api.g_ret_sts_success) THEN
      COMMIT;
    ELSE
      ROLLBACK;
      x_return_msg := l_msg_html || '</html>';
    END IF;
    x_batch_id      := l_batch_id;
    x_org_id        := l_org_id;
    x_return_status := l_return_status;
  
  EXCEPTION
    WHEN l_create_exp THEN
      ROLLBACK;
      x_return_msg    := l_msg_html || '</html>';
      x_return_status := fnd_api.g_ret_sts_error;
    WHEN OTHERS THEN
      ROLLBACK;
      x_return_msg    := SQLERRM;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END insert_po_interface;

  PROCEDURE getdateinfo(p_add_date  IN VARCHAR2
                       ,p_plan_type IN VARCHAR2) IS
  
  BEGIN
    IF p_plan_type = 'ADD_ORDERS' THEN
      SELECT trunc(to_date(p_add_date
                          ,'yyyy-mm-dd'))
        INTO cux_pr_plan_main_pkg.g_add_date
        FROM dual;
    ELSE
      SELECT trunc(SYSDATE)
        INTO cux_pr_plan_main_pkg.g_add_date
        FROM dual;
    
    END IF;
    -- COMMIT;
  END getdateinfo;

  PROCEDURE getdateinfo(p_header_id IN NUMBER) IS
  
    v_plan_type  VARCHAR2(30);
    v_v_add_date DATE;
  
  BEGIN
  
    SELECT trunc(nvl(h.add_order_date
                    ,SYSDATE))
      INTO cux_pr_plan_main_pkg.g_add_date
      FROM cux.cux_pr_plan_headers h
     WHERE h.header_id = p_header_id;
  
  END getdateinfo;

  FUNCTION get_pr_price_count(p_add_date  IN VARCHAR2
                             ,p_plan_type IN VARCHAR2
                             ,p_item_id   IN VARCHAR2
                             ,p_line_id   IN VARCHAR2) RETURN NUMBER IS
  
    l_get_count NUMBER;
  BEGIN
  
    getdateinfo(p_add_date
               ,p_plan_type);
  
    BEGIN
      SELECT COUNT(1)
        INTO l_get_count
        FROM cux_pr_plan_blanket_v t
       WHERE t.inventory_item_id = p_item_id
         AND t.po_line_id = p_line_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_get_count := 0;
    END;
    RETURN l_get_count;
  END get_pr_price_count;

  FUNCTION need_adjust_flag(p_header_id IN NUMBER) RETURN VARCHAR2 IS
  
    v_count NUMBER;
    v_code  VARCHAR2(1) := 'F';
  
  BEGIN
  
    SELECT COUNT(1)
      INTO v_count
      FROM cux_pr_plan_lines a
     WHERE EXISTS (SELECT 1
              FROM srm_categoryadjustsetdtl_t b
             WHERE b.fcasid = srm_adjustset_pkg.get_set(a.line_id)
               AND b.fisinputbaseprice = '1')
       AND a.header_id = p_header_id;
  
    IF v_count > 0 THEN
      v_code := 'T';
    END IF;
  
    RETURN v_code;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'F';
  END need_adjust_flag;

  FUNCTION init_adjust_data(p_header_id IN NUMBER) RETURN VARCHAR2 IS
  
    v_count     NUMBER;
    v_user_id   NUMBER := fnd_global.user_id;
    v_curr_date DATE := SYSDATE;
    v_login_id  NUMBER := fnd_global.login_id;
  
    rec_adjust cux_pr_plan_adjust_header%ROWTYPE;
    rec_prices cux_pr_plan_adjust_prices%ROWTYPE;
  
  BEGIN
    SELECT COUNT(1)
      INTO v_count
      FROM cux.cux_pr_plan_headers pap
     WHERE pap.header_id = p_header_id
       AND pap.plan_status = 'APPROVED';
  
    IF v_count = 0 THEN
      RETURN 'S';
    END IF;
  
    FOR rec_h IN (SELECT a.fcasid      formula_header_id
                        ,b.fcasdid     formula_line_id
                        ,a.fcategoryid category_id
                        ,flv.meaning   adjust_name
                        ,b.fvalue      adjust_value
                        ,b.fdesc       adjust_desc
                    FROM srm_categoryadjustset_t    a
                        ,srm_categoryadjustsetdtl_t b
                        ,fnd_lookup_values_vl       flv
                   WHERE EXISTS (SELECT 1
                            FROM cux_pr_plan_lines cpl
                           WHERE cpl.header_id = p_header_id
                             AND b.fcasid =
                                 srm_adjustset_pkg.get_set(cpl.line_id))
                     AND b.fcasid = a.fcasid
                     AND b.fisinputbaseprice = '1'
                     AND flv.lookup_type = 'SRM_BASEMATERIAL'
                     AND flv.lookup_code = b.fsetitem) LOOP
    
      SELECT COUNT(1)
        INTO v_count
        FROM cux.cux_pr_plan_adjust_header pap
       WHERE pap.header_id = p_header_id
         AND pap.formula_header_id = rec_h.formula_header_id;
    
      IF v_count = 0 THEN
      
        SELECT cux.cux_pr_plan_adjust_header_s.nextval
          INTO rec_adjust.adjust_id
          FROM dual;
        rec_adjust.header_id         := p_header_id;
        rec_adjust.formula_header_id := rec_h.formula_header_id;
        rec_adjust.category_id       := rec_h.category_id;
      
        rec_adjust.created_by        := v_user_id;
        rec_adjust.last_updated_by   := v_user_id;
        rec_adjust.creation_date     := v_curr_date;
        rec_adjust.last_update_date  := v_curr_date;
        rec_adjust.last_update_login := v_login_id;
      
        INSERT INTO cux.cux_pr_plan_adjust_header
        VALUES rec_adjust;
      
      END IF;
    
      SELECT COUNT(1)
        INTO v_count
        FROM cux.cux_pr_plan_adjust_prices pap
       WHERE pap.header_id = p_header_id
         AND pap.formula_header_id = rec_h.formula_header_id
         AND pap.formula_line_id = rec_h.formula_line_id;
    
      IF v_count = 0 THEN
      
        SELECT cux.cux_pr_plan_adjust_prices_s.nextval
          INTO rec_prices.price_id
          FROM dual;
      
        rec_prices.header_id         := p_header_id;
        rec_prices.formula_header_id := rec_h.formula_header_id;
        rec_prices.formula_line_id   := rec_h.formula_line_id;
        rec_prices.category_id       := rec_h.category_id;
      
        rec_prices.attribute1   := rec_h.adjust_name;
        rec_prices.adjust_price := rec_h.adjust_value;
        rec_prices.description  := rec_h.adjust_desc;
      
        rec_prices.created_by        := v_user_id;
        rec_prices.last_updated_by   := v_user_id;
        rec_prices.creation_date     := v_curr_date;
        rec_prices.last_update_date  := v_curr_date;
        rec_prices.last_update_login := v_login_id;
      
        INSERT INTO cux.cux_pr_plan_adjust_prices
        VALUES rec_prices;
      
      END IF;
    
    END LOOP;
  
    COMMIT;
  
    RETURN 'S';
  
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('error:' || SQLERRM);
      ROLLBACK;
      RETURN 'E';
    
  END init_adjust_data;

  PROCEDURE validate_before_order(p_header_id     IN NUMBER
                                 ,x_return_status OUT VARCHAR2
                                 ,x_return_msg    OUT VARCHAR2) IS
  
    v_row_count NUMBER;
    v_err_count NUMBER;
    v_code      VARCHAR2(1);
  
  BEGIN
  
    v_code := need_adjust_flag(p_header_id);
  
    IF v_code = 'T' THEN
    
      SELECT COUNT(1)
            ,nvl(SUM((CASE
                       WHEN pap.adjust_price IS NULL
                            OR pap.adjust_date IS NULL THEN
                        1
                       ELSE
                        0
                     END))
                ,0)
        INTO v_row_count
            ,v_err_count
        FROM cux.cux_pr_plan_adjust_prices pap
       WHERE pap.header_id = p_header_id;
    
      IF v_row_count = 0
         OR v_err_count > 0 THEN
      
        x_return_status := 'E';
        x_return_msg    := '需要维护现货价！请进入详细单据页面，通过点击生成订单按钮来进入现货价维护界面！';
        RETURN;
      
      END IF;
    
    END IF;
  
    x_return_status := 'S';
  
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'E';
      x_return_msg    := '验证出现异常:' || SQLERRM;
  END validate_before_order;

END cux_pr_plan_main_pkg;
