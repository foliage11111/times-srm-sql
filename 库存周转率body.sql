create or replace PACKAGE BODY cuxs_mfgr021_pkg IS
  g_pkg_name CONSTANT VARCHAR2(30) := 'CUXS_MFGR021_PKG';
  /*===============================================
    Copyright (C) Hand Business Consulting Services
                AllRights Reserved
  ================================================
  * ===============================================
  *   PROGRAM NAME:
  *                CUXS_MFGR021_PKG
  *   DESCRIPTION:
  *                库存周转率报表
  *   HISTORY:
  *     1.00   2006-2-23   Jianping.ni@hand-china.com Creation
  *     1.01   2008-6-15   WangYun, change hint
  * ==============================================*/
  ---获取库存组织名称
  FUNCTION get_organization_name(i_organization_id IN NUMBER) RETURN VARCHAR2 IS
    v_organization_name VARCHAR2(100);
  BEGIN
    SELECT organization_name
    INTO   v_organization_name
    FROM   org_organization_definitions
    WHERE  organization_id = i_organization_id;
    RETURN v_organization_name;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
  
  ---获取有效人员名称
  FUNCTION get_person_name(i_person_id IN NUMBER) RETURN VARCHAR2 IS
    v_full_name VARCHAR2(300);
  BEGIN
    SELECT full_name
    INTO   v_full_name
    FROM   per_all_people_f
    WHERE  person_id = i_person_id
    AND    SYSDATE BETWEEN effective_start_date AND effective_end_date;
    RETURN v_full_name;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
  
  ---获取物料描述，通过物料目录--》实际很可能很多没有，但是这个是关键数据吗？
  FUNCTION get_item_description(i_item_catalog_group_id IN NUMBER)
    RETURN VARCHAR2 IS
    v_item_desc VARCHAR2(300);
  BEGIN
    SELECT segment1 || segment3 || segment7
    INTO   v_item_desc
    FROM   mtl_item_catalog_groups_b
    WHERE  item_catalog_group_id = i_item_catalog_group_id;
    RETURN v_item_desc;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;
  
  --获取库存现有量
  FUNCTION get_onhand_qty(i_organization_id   IN NUMBER
                         ,i_inventory_item_id IN NUMBER
                         ,i_subinventory_code IN VARCHAR2) RETURN NUMBER IS
    v_qty NUMBER;
  BEGIN
    SELECT SUM(transaction_quantity)
    INTO   v_qty
    FROM   mtl_onhand_quantities moq
    WHERE  moq.organization_id = i_organization_id
    AND    moq.inventory_item_id = i_inventory_item_id
    AND    moq.subinventory_code = i_subinventory_code;
    RETURN nvl(v_qty, 0);
  END;
  
  --获取大于i_date_end所有库存事务处理数量--》type 不等24，90，action_id 不等于24，30这些是什么？
  FUNCTION get_history_onhand_qty(i_organization_id   IN NUMBER
                                 ,i_inventory_item_id IN NUMBER
                                 ,i_subinventory_code IN VARCHAR2
                                 ,i_date_end          IN DATE) RETURN NUMBER IS
    v_qty NUMBER;
  BEGIN
    --Modified by zhugw@midea on 2015-07-14 性能优化，提定索引
    --这些事务处理被过滤了
    -- Standard cost update，WIP cost update，Periodic Cost Update，WIP assembly scrap，WIP return from scrap，WIP estimated scrap

    SELECT SUM(mmt.primary_quantity)
    INTO   v_qty
    FROM   mtl_material_transactions mmt
    WHERE  mmt.organization_id = i_organization_id
    AND    mmt.inventory_item_id = i_inventory_item_id
    AND    mmt.transaction_date >= i_date_end
    AND    mmt.subinventory_code = i_subinventory_code
    AND    mmt.transaction_type_id <> 24
    AND    mmt.transaction_type_id <> 90
    AND    mmt.transaction_action_id <> 24
    AND    mmt.transaction_action_id <> 30;
    RETURN nvl(v_qty, 0);
  END;
  
  
  --获取本期发生所有库存事务处理数量
  PROCEDURE get_instk_outstk_qty(i_organization_id   IN NUMBER
                                ,i_inventory_item_id IN NUMBER
                                ,i_subinventory_code IN VARCHAR2
                                ,i_date_from         IN DATE
                                ,i_date_to           IN DATE
                                ,o_instk_qty         OUT NUMBER
                                ,o_outstk_qty        OUT NUMBER) IS
  BEGIN
    SELECT SUM(decode(sign(mmt.primary_quantity),
                      1,
                      mmt.primary_quantity,
                      0))
          ,SUM(decode(sign(mmt.primary_quantity),
                      -1,
                      mmt.primary_quantity,
                      0))
    INTO   o_instk_qty
          ,o_outstk_qty
    FROM   mtl_material_transactions mmt
    WHERE  mmt.organization_id = i_organization_id
    AND    mmt.inventory_item_id = i_inventory_item_id
    AND    mmt.transaction_date BETWEEN i_date_from AND i_date_to
    AND    mmt.subinventory_code = i_subinventory_code
    AND    mmt.transaction_type_id <> 24
    AND    mmt.transaction_type_id <> 90
    AND    mmt.transaction_action_id <> 24
    AND    mmt.transaction_action_id <> 30;
    o_instk_qty  := nvl(o_instk_qty, 0);
    o_outstk_qty := -nvl(o_outstk_qty, 0);
  EXCEPTION
    WHEN OTHERS THEN
      o_instk_qty  := 0;
      o_outstk_qty := 0;
  END;

  --获取最近交易日
  FUNCTION get_max_transaction_date(i_organization_id   IN NUMBER
                                   ,i_inventory_item_id IN NUMBER
                                   ,i_subinventory_code IN VARCHAR2
                                   ,i_date_from         IN DATE
                                   ,i_date_to           IN DATE) RETURN DATE IS
    v_max_transaction_date DATE;
  BEGIN
    SELECT MAX(transaction_date)
    INTO   v_max_transaction_date
    FROM   mtl_material_transactions mmt
    WHERE  mmt.organization_id = i_organization_id
    AND    mmt.inventory_item_id = i_inventory_item_id
          --AND mmt.transaction_date BETWEEN i_date_from AND i_date_to
    AND    mmt.subinventory_code = i_subinventory_code;
    RETURN v_max_transaction_date;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END;

  --获取截至日期为d_date_end那一刻的库存数量
  FUNCTION get_onhand_qty_by_date(i_organization_id   IN NUMBER
                                 ,i_inventory_item_id IN NUMBER
                                 ,i_subinventory_code IN VARCHAR2
                                 ,i_date_end          IN DATE) RETURN NUMBER IS
    v_onhand_qty  NUMBER;
    v_history_qty NUMBER;
    v_qty         NUMBER;
  BEGIN
    v_onhand_qty  := get_onhand_qty(i_organization_id,
                                    i_inventory_item_id,
                                    i_subinventory_code);
    v_history_qty := get_history_onhand_qty(i_organization_id,
                                            i_inventory_item_id,
                                            i_subinventory_code,
                                            i_date_end);
    v_qty         := nvl(v_onhand_qty, 0) - nvl(v_history_qty, 0);
    RETURN v_qty;
  END;
  
  ---获取物料成本？
  FUNCTION get_item_cost(i_organization_id   IN NUMBER
                        ,i_inventory_item_id IN NUMBER
                        ,i_cost_type_id      IN NUMBER) RETURN NUMBER IS
    v_item_cost NUMBER;
  BEGIN
    SELECT nvl(item_cost, 0)
    INTO   v_item_cost
    FROM   cst_item_costs
    WHERE  organization_id = i_organization_id
    AND    inventory_item_id = i_inventory_item_id
    AND    cost_type_id = i_cost_type_id;
    RETURN v_item_cost;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END;

  --异常抛出
  PROCEDURE raise_exception(p_return_status VARCHAR2) IS
  BEGIN
    IF (p_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (p_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  END raise_exception;

  PROCEDURE process_output(p_init_msg_list     IN VARCHAR2
                          ,p_commit            IN VARCHAR2
                          ,x_return_status     OUT NOCOPY VARCHAR2
                          ,x_msg_count         OUT NOCOPY NUMBER
                          ,x_msg_data          OUT NOCOPY VARCHAR2
                          ,i_organization_id   IN NUMBER
                          ,i_date_from         IN VARCHAR2
                          ,i_date_to           IN VARCHAR2
                          ,i_subinventory_from IN VARCHAR2
                          ,i_subinventory_to   IN VARCHAR2
                          ,i_item_number_from  IN VARCHAR2
                          ,i_item_number_to    IN VARCHAR2
                          ,i_slacken_time_flag IN VARCHAR2 --增加开关，是否计算呆滞时间 刘朝旭 20080722
                           ) IS
    CURSOR cur_item(i_cur_organization_id   IN NUMBER
                   ,i_cur_date_from         IN DATE
                   ,i_cur_date_to           IN DATE
                   ,i_cur_subinventory_from IN VARCHAR2
                   ,i_cur_subinventory_to   IN VARCHAR2
                   ,i_cur_item_number_from  IN VARCHAR2
                   ,i_cur_item_number_to    IN VARCHAR2) IS
      SELECT DISTINCT inventory_item_id
                     ,item_number
                     ,item_desc
                     ,item_catalog_group_id
                     ,primary_unit_of_measure
                     ,buyer_id
                     ,item_type
                     ,subinventory_code
      FROM   (SELECT /*+ no_expand index(mmt MTL_MATERIAL_TRANSACTIONS_N1) */
               mmt.inventory_item_id
              ,msib.segment1 item_number
              ,msib.description item_desc
              ,msib.item_catalog_group_id
              ,msib.primary_unit_of_measure
              ,msib.buyer_id
              ,(SELECT meaning
                FROM   fnd_lookup_values
                WHERE  lookup_type = 'ITEM_TYPE'
                AND    LANGUAGE = 'ZHS'
                AND    lookup_code = msib.item_type) item_type
              ,mmt.subinventory_code
              FROM   mtl_material_transactions mmt
                    ,mtl_system_items_b        msib
              WHERE  mmt.organization_id = i_cur_organization_id
              AND    mmt.transaction_date BETWEEN i_cur_date_from AND
                     SYSDATE + 1
              AND    mmt.subinventory_code BETWEEN i_cur_subinventory_from AND
                     i_cur_subinventory_to
              AND    msib.organization_id = mmt.organization_id
              AND    msib.inventory_item_id = mmt.inventory_item_id
              AND    msib.segment1 BETWEEN
                     nvl(i_cur_item_number_from, msib.segment1) AND
                     nvl(i_cur_item_number_to, msib.segment1)
              UNION ALL
              SELECT /*+ no_expand leading (mmt)*/ -- changed by WangYun,2009-6-15, original is leading(mmt)
               mmt.inventory_item_id
              ,msib.segment1 item_number
              ,msib.description item_desc
              ,msib.item_catalog_group_id
              ,msib.primary_unit_of_measure
              ,msib.buyer_id
              ,(SELECT meaning
                FROM   fnd_lookup_values
                WHERE  lookup_type = 'ITEM_TYPE'
                AND    LANGUAGE = 'ZHS'
                AND    lookup_code = msib.item_type) item_type
              ,mmt.subinventory_code
              FROM   mtl_onhand_quantities mmt
                    ,mtl_system_items_b    msib
              WHERE  mmt.organization_id = i_cur_organization_id
              AND    mmt.subinventory_code BETWEEN i_cur_subinventory_from AND
                     i_cur_subinventory_to
                    /*NVL(i_cur_subinventory_from, mmt.subinventory_code) AND
                    NVL(i_cur_subinventory_to, mmt.subinventory_code)*/ --modify by wangxw
              AND    msib.organization_id = mmt.organization_id
              AND    msib.inventory_item_id = mmt.inventory_item_id
              AND    msib.segment1 BETWEEN
                     nvl(i_cur_item_number_from, msib.segment1) AND
                     nvl(i_cur_item_number_to, msib.segment1));
  
    v_date_from             DATE;
    v_date_to               DATE;
    v_item_desc             mtl_system_items_b.description%TYPE;
    v_qc_qty                NUMBER;
    v_qm_qty                NUMBER;
    v_instk_qty             NUMBER;
    v_outstk_qty            NUMBER;
    v_velocity              NUMBER;
    v_item_cost             NUMBER;
    v_slacken_time          VARCHAR(240);
    v_buyer_name            VARCHAR2(240);
    v_max_transasction_date DATE;
    v_amount                NUMBER;
    v_organization_name     VARCHAR2(240);
    v_line_number           NUMBER;
    v_return_status         VARCHAR2(100);
    v_dzl                   NUMBER;
    v_api_name       CONSTANT VARCHAR2(30) := 'PROCESS_OUTPUT';
    v_savepoint_name CONSTANT VARCHAR2(30) := 'PROCESS_OUTPUT';
    v_sep          VARCHAR2(15);
    v_program_name VARCHAR2(1000);
    v_line_str     VARCHAR2(4000);
  BEGIN
    x_return_status := cuxs_conc_program_utl.start_activity(p_pkg_name       => g_pkg_name,
                                                            p_api_name       => v_api_name,
                                                            p_savepoint_name => v_savepoint_name,
                                                            p_init_msg_list  => p_init_msg_list);
    raise_exception(x_return_status);
  
    v_date_from := to_date(i_date_from, 'RRRR/MM/DD HH24:MI:SS');
    v_date_to   := to_date(substr(i_date_to, 1, 10) || ' 23:59:59',
                           'RRRR/MM/DD HH24:MI:SS');
    -- set print report name
    IF (v_return_status = fnd_api.g_ret_sts_unexp_error) THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (v_return_status = fnd_api.g_ret_sts_error) THEN
      RAISE fnd_api.g_exc_error;
    END IF;
    -- report header: title / print date
    v_line_number                              := v_line_number + 1;
    v_organization_name                        := get_organization_name(i_organization_id);
    cuxs_html_reports_utl.v_report_output_mode := 'F';
  
    v_sep          := cuxs_html_reports_utl.g_delimiter;
    v_program_name := v_organization_name || '物料周转率表';
    --输出报表标题
    cuxs_html_reports_utl.html_title(p_program_title => v_program_name,
                                     p_report_title  => v_program_name);
    cuxs_html_reports_utl.output_line('<table width=100% style="border-collapse:collapse; border:none; font-family: 宋体
                                     ; font-size: 10pt" border=1 bordercolor=#000000 cellspacing="0">');
    --输出参数
    cuxs_html_reports_utl.line_title(p_title_string    => '起始时间：' ||
                                                          to_char(v_date_from,
                                                                  'YYYY-MM-DD HH24:MI:SS') ||
                                                          '***colspan=3',
                                     p_with_other_attr => 'Y',
                                     p_attr_delimiter  => '***',
                                     p_delimiter       => v_sep);
    cuxs_html_reports_utl.line_title(p_title_string    => '结束时间：' ||
                                                          to_char(v_date_to,
                                                                  'YYYY-MM-DD HH24:MI:SS') ||
                                                          '***colspan=3',
                                     p_with_other_attr => 'Y',
                                     p_attr_delimiter  => '***',
                                     p_delimiter       => v_sep);
    cuxs_html_reports_utl.line_title(p_title_string    => '子库存从:' ||
                                                          i_subinventory_from ||
                                                          '***colspan=3',
                                     p_with_other_attr => 'Y',
                                     p_attr_delimiter  => '***',
                                     p_delimiter       => v_sep);
    cuxs_html_reports_utl.line_title(p_title_string    => '子库存到：' ||
                                                          i_subinventory_to ||
                                                          '***colspan=3',
                                     p_with_other_attr => 'Y',
                                     p_attr_delimiter  => '***',
                                     p_delimiter       => v_sep);
    cuxs_html_reports_utl.line_title(p_title_string    => '物料从：' ||
                                                          i_item_number_from ||
                                                          '***colspan=3',
                                     p_with_other_attr => 'Y',
                                     p_attr_delimiter  => '***',
                                     p_delimiter       => v_sep);
    cuxs_html_reports_utl.line_title(p_title_string    => '物料到:' ||
                                                          i_item_number_to ||
                                                          '***colspan=3',
                                     p_with_other_attr => 'Y',
                                     p_attr_delimiter  => '***',
                                     p_delimiter       => v_sep);
    v_line_str := '子库存,物料编码,物料描述,物料类型,期初数量,期末数量,本期增加,本期减少,周转率,呆滞率,计量单位,冻结成本,金额,呆滞时间,最近交易日,采购员,';
    cuxs_html_reports_utl.line_title(p_title_string => v_line_str);
    FOR rec_item IN cur_item(i_organization_id,
                             v_date_from,
                             v_date_to,
                             i_subinventory_from,
                             i_subinventory_to,
                             i_item_number_from,
                             i_item_number_to) LOOP
      --Modified by zhugw@midea on 2015-07-14 多余的LOG信息
      --fnd_file.put_line(fnd_file.log, 'tttt');
      --取物料说明
      v_item_desc := rec_item.item_desc;
      --期初数量
      v_qc_qty := get_onhand_qty_by_date(i_organization_id,
                                         rec_item.inventory_item_id,
                                         rec_item.subinventory_code,
                                         v_date_from);
      --期末数量
      v_qm_qty := get_onhand_qty_by_date(i_organization_id,
                                         rec_item.inventory_item_id,
                                         rec_item.subinventory_code,
                                         v_date_to + 1 / (60 * 60 * 24));
      --本期发生增加
      --本期发生减少
      get_instk_outstk_qty(i_organization_id,
                           rec_item.inventory_item_id,
                           rec_item.subinventory_code,
                           v_date_from,
                           v_date_to,
                           v_instk_qty,
                           v_outstk_qty);
      --周转率 := 本期发生减少/(期初数量+本期发生增加)
      IF v_qc_qty + v_instk_qty != 0
         AND v_outstk_qty != 0 THEN
        v_velocity := round(v_outstk_qty / (v_qc_qty + v_instk_qty), 2);
      ELSE
        v_velocity := 0;
      END IF;
    
      IF v_outstk_qty <> 0
         AND v_qc_qty + v_instk_qty <> 0 THEN
      --呆滞率=（1-本期减少量/（期初数量+本期发生增加））
        v_dzl := round(1 - v_outstk_qty / (v_qc_qty + v_instk_qty), 2);
      ELSE
        v_dzl := 0;
      END IF;
      --计量单位
      --冻结成本
      v_item_cost := get_item_cost(i_organization_id,
                                   rec_item.inventory_item_id,
                                   1);
      --金额 := 期末数量*冻结成本
      v_amount := round(v_qm_qty * v_item_cost, 4);
      --采购员
      v_buyer_name  := get_person_name(rec_item.buyer_id);
      v_line_number := v_line_number + 1;
    
      IF i_slacken_time_flag = 'Y' THEN
        --为减少报表运行时间，当i_slacken_time_flag等于'Y'，计算最近交易日和呆滞时间，否则不计算
        --最近交易日
        v_max_transasction_date := get_max_transaction_date(i_organization_id,
                                                            rec_item.inventory_item_id,
                                                            rec_item.subinventory_code,
                                                            v_date_from,
                                                            v_date_to);
        --呆滞时间 := sysdate - max(transasction_date)
        IF v_max_transasction_date IS NULL THEN
          v_slacken_time := '无限大';
        ELSE
          v_slacken_time := to_char(round(SYSDATE - v_max_transasction_date));
        END IF;
      ELSE
        v_max_transasction_date := NULL;
        v_slacken_time          := NULL;
      END IF;
      cuxs_html_reports_utl.line_title(p_title_string    => rec_item.subinventory_code ||
                                                            v_sep || --子库存
                                                            rec_item.item_number ||
                                                            '*** nowrap x:str ' ||
                                                            v_sep || --物料编码
                                                            rec_item.item_desc ||
                                                            v_sep || --物料描述
                                                            rec_item.item_type ||
                                                            v_sep || --物料类型
                                                            to_char(v_qc_qty) ||
                                                            v_sep || --期初数量
                                                            to_char(v_qm_qty) ||
                                                            v_sep || --期末数量
                                                            to_char(v_instk_qty) ||
                                                            v_sep || --本期增加
                                                            to_char(v_outstk_qty) ||
                                                            v_sep || --本期减少
                                                            to_char(v_velocity) ||
                                                            v_sep || --周转率
                                                            to_char(v_dzl) ||
                                                            v_sep || --呆滞率
                                                            rec_item.primary_unit_of_measure ||
                                                            v_sep || --计量单位
                                                            to_char(v_item_cost) ||
                                                            v_sep || --冻结成本
                                                            to_char(v_amount) ||
                                                            v_sep || --金额
                                                            v_slacken_time ||
                                                            v_sep || --呆滞时间
                                                            to_char(v_max_transasction_date,
                                                                    'YYYY-MM-DD') ||
                                                            v_sep || --最近交易日
                                                            v_buyer_name ||
                                                            v_sep --采购员
                                      ,
                                       p_with_other_attr => 'Y',
                                       p_attr_delimiter  => '***',
                                       p_delimiter       => v_sep);
    
    END LOOP;
  
    x_return_status := cuxs_conc_program_utl.end_activity(p_pkg_name  => g_pkg_name,
                                                          p_api_name  => v_api_name,
                                                          p_commit    => p_commit,
                                                          x_msg_count => x_msg_count,
                                                          x_msg_data  => x_msg_data);
    raise_exception(x_return_status);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := cuxs_conc_program_utl.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                                 p_api_name       => v_api_name,
                                                                 p_exc_name       => cuxs_conc_program_utl.g_exc_name_error,
                                                                 p_savepoint_name => v_savepoint_name,
                                                                 x_msg_count      => x_msg_count,
                                                                 x_msg_data       => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := cuxs_conc_program_utl.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                                 p_api_name       => v_api_name,
                                                                 p_exc_name       => cuxs_conc_program_utl.g_exc_name_error,
                                                                 p_savepoint_name => v_savepoint_name,
                                                                 x_msg_count      => x_msg_count,
                                                                 x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := cuxs_conc_program_utl.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                                 p_api_name       => v_api_name,
                                                                 p_exc_name       => cuxs_conc_program_utl.g_exc_name_error,
                                                                 p_savepoint_name => v_savepoint_name,
                                                                 x_msg_count      => x_msg_count,
                                                                 x_msg_data       => x_msg_data);
    
  END;

  PROCEDURE process_request(p_init_msg_list     IN VARCHAR2 DEFAULT fnd_api.g_false
                           ,p_commit            IN VARCHAR2 DEFAULT 'F'
                           ,x_return_status     OUT NOCOPY VARCHAR2
                           ,x_msg_count         OUT NOCOPY NUMBER
                           ,x_msg_data          OUT NOCOPY VARCHAR2
                           ,i_organization_id   IN NUMBER
                           ,i_date_from         IN VARCHAR2
                           ,i_date_to           IN VARCHAR2
                           ,i_subinventory_from IN VARCHAR2
                           ,i_subinventory_to   IN VARCHAR2
                           ,i_item_number_from  IN VARCHAR2
                           ,i_item_number_to    IN VARCHAR2
                           ,i_slacken_time_flag IN VARCHAR2) IS
  
    v_api_name       CONSTANT VARCHAR2(30) := 'PROCESS_REQUEST';
    v_savepoint_name CONSTANT VARCHAR2(30) := 'PROCESS_REQUEST';
  BEGIN
    x_return_status := cuxs_conc_program_utl.start_activity(p_pkg_name       => g_pkg_name,
                                                            p_api_name       => v_api_name,
                                                            p_savepoint_name => v_savepoint_name,
                                                            p_init_msg_list  => p_init_msg_list);
    raise_exception(x_return_status);
  
    --output
    process_output(p_init_msg_list     => p_init_msg_list,
                   p_commit            => p_commit,
                   x_return_status     => x_return_status,
                   x_msg_count         => x_msg_count,
                   x_msg_data          => x_msg_data,
                   i_organization_id   => i_organization_id,
                   i_date_from         => i_date_from,
                   i_date_to           => i_date_to,
                   i_subinventory_from => i_subinventory_from,
                   i_subinventory_to   => i_subinventory_to,
                   i_item_number_from  => i_item_number_from,
                   i_item_number_to    => i_item_number_to,
                   i_slacken_time_flag => i_slacken_time_flag);
    raise_exception(x_return_status);
  
    x_return_status := cuxs_conc_program_utl.end_activity(p_pkg_name  => g_pkg_name,
                                                          p_api_name  => v_api_name,
                                                          p_commit    => p_commit,
                                                          x_msg_count => x_msg_count,
                                                          x_msg_data  => x_msg_data);
    raise_exception(x_return_status);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := cuxs_conc_program_utl.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                                 p_api_name       => v_api_name,
                                                                 p_exc_name       => cuxs_conc_program_utl.g_exc_name_error,
                                                                 p_savepoint_name => v_savepoint_name,
                                                                 x_msg_count      => x_msg_count,
                                                                 x_msg_data       => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := cuxs_conc_program_utl.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                                 p_api_name       => v_api_name,
                                                                 p_exc_name       => cuxs_conc_program_utl.g_exc_name_error,
                                                                 p_savepoint_name => v_savepoint_name,
                                                                 x_msg_count      => x_msg_count,
                                                                 x_msg_data       => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := cuxs_conc_program_utl.handle_exceptions(p_pkg_name       => g_pkg_name,
                                                                 p_api_name       => v_api_name,
                                                                 p_exc_name       => cuxs_conc_program_utl.g_exc_name_error,
                                                                 p_savepoint_name => v_savepoint_name,
                                                                 x_msg_count      => x_msg_count,
                                                                 x_msg_data       => x_msg_data);
  END process_request;

  /* =============================================
  *   FUNCTION / PROCEDURE
  *   NAME :
  *            main
  *   DESCRIPTION:
  *            CUXS.库存周转率报表
  *   ARGUMENT:
  *
  *   RETURN:
  *           报表请求主程序
  *   HISTORY:
  *     1.00 2015-11-06  sie_fengcl    Creation
  *
  * =============================================*/
  PROCEDURE main(errbuf              OUT VARCHAR2
                ,retcode             OUT VARCHAR2
                ,i_organization_id   IN NUMBER
                ,i_date_from         IN VARCHAR2
                ,i_date_to           IN VARCHAR2
                ,i_subinventory_from IN VARCHAR2
                ,i_subinventory_to   IN VARCHAR2
                ,i_item_number_from  IN VARCHAR2
                ,i_item_number_to    IN VARCHAR2
                ,i_slacken_time_flag IN VARCHAR2 --增加开关，是否计算呆滞时间 刘朝旭 20080722
                 ) IS
  
    v_return_status VARCHAR2(10);
    v_msg_count     NUMBER;
    v_msg_data      VARCHAR2(3000);
  BEGIN
    --请求的主程序
    process_request(p_init_msg_list     => fnd_api.g_true,
                    p_commit            => fnd_api.g_true,
                    x_return_status     => v_return_status,
                    x_msg_count         => v_msg_count,
                    x_msg_data          => v_msg_data,
                    i_organization_id   => i_organization_id,
                    i_date_from         => i_date_from,
                    i_date_to           => i_date_to,
                    i_subinventory_from => i_subinventory_from,
                    i_subinventory_to   => i_subinventory_to,
                    i_item_number_from  => i_item_number_from,
                    i_item_number_to    => i_item_number_to,
                    i_slacken_time_flag => i_slacken_time_flag);
    raise_exception(v_return_status);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      retcode := '1';
      errbuf  := v_msg_data;
    WHEN fnd_api.g_exc_unexpected_error THEN
      retcode := '2';
      errbuf  := v_msg_data;
    WHEN OTHERS THEN
      retcode := '2';
      errbuf  := SQLERRM;
  END;
END;
