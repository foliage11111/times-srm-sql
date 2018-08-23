CREATE OR REPLACE PACKAGE BODY cux_pr_plan_action_pkg IS

  FUNCTION get_overrun_quantity(p_contract_id IN NUMBER
                               ,p_item_id     IN NUMBER) RETURN NUMBER
  
   IS
  
    v_plan_quantity    NUMBER := 0; /*规划数量*/
    v_quantity         NUMBER := 0; /*计划需求数量*/
    v_overrun_quantity NUMBER := 0; /*超出数量*/
  
  BEGIN
  
    SELECT SUM(nvl(wbt.fquantity
                  ,0)) sumq
      INTO v_plan_quantity
      FROM wpc_contract_t wc
          ,(SELECT a.rowid row_id
                  ,a.fbomlistid
                  ,a.fbomid
                  ,a.fprdid
                  ,a.fquantity
                  ,b.fnumber
                  ,b.inventory_item_id
                  ,b.fname
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
       AND wc.fconid = p_contract_id
       AND t.inventory_item_id = p_item_id
     GROUP BY wc.fconid
             ,t.inventory_item_id;
  
    SELECT nvl(SUM(cpl.quantity)
              ,0)
      INTO v_quantity
      FROM cux_pr_plan_lines   cpl
          ,cux_pr_plan_headers cph
     WHERE 1 = 1
       AND cpl.item_id = p_item_id
       AND cpl.header_id = cph.header_id
       AND cph.contract_id = p_contract_id
       AND cph.last_update_date =
           (SELECT MAX(cphh.last_update_date)
              FROM cux_pr_plan_headers cphh
             WHERE cphh.plan_number = cph.plan_number
               AND cphh.plan_status IN ('APPROVING'
                                       ,'APPROVED'
                                       ,'ORDERED'));
  
    IF v_quantity > v_plan_quantity THEN
    
      v_overrun_quantity := v_quantity - v_plan_quantity;
    
    END IF;
  
    RETURN v_overrun_quantity;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END get_overrun_quantity;

  FUNCTION get_overrun_amount(p_contract_id IN NUMBER
                             ,p_item_id     IN NUMBER DEFAULT NULL)
    RETURN NUMBER
  
   IS
  
    v_quantity       NUMBER;
    v_overrun_amount NUMBER := 0; /*超出金额*/
  
  BEGIN
  
    
  
    SELECT SUM((CASE
                 WHEN cpp.plan_quantity > wctt.sumq THEN
                  trunc(cpp.plan_price * (1 + nvl(fnd_profile.value('CUX_ITEM_FLOAT')
                                                 ,0) / 100)
                       ,4) * (cpp.plan_quantity - wctt.sumq)
                 ELSE
                  0
               END))
      INTO v_overrun_amount
      FROM (SELECT wc.fconid
                  ,t.inventory_item_id
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
             GROUP BY wc.fconid
                     ,t.inventory_item_id) wctt
          ,(SELECT cph.contract_id
                  ,cpl.item_id
                  ,SUM(cpl.quantity) plan_quantity
                  ,MAX(cpl.unit_price) plan_price
              FROM cux_pr_plan_lines   cpl
                  ,cux_pr_plan_headers cph
             WHERE 1 = 1
               AND cpl.header_id = cph.header_id
               AND cph.last_update_date =
                   (SELECT MAX(cphh.last_update_date)
                      FROM cux_pr_plan_headers cphh
                     WHERE cphh.plan_number = cph.plan_number
                       AND cphh.plan_status IN
                           ('APPROVING'
                           ,'APPROVED'
                           ,'ORDERED'))
             GROUP BY cph.contract_id
                     ,cpl.item_id) cpp
     WHERE cpp.contract_id(+) = wctt.fconid
       AND cpp.item_id(+) = wctt.inventory_item_id
       AND wctt.fconid = p_contract_id
       AND wctt.inventory_item_id =
           nvl(p_item_id
              ,wctt.inventory_item_id);
  
    RETURN v_overrun_amount;
  
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END get_overrun_amount;

END cux_pr_plan_action_pkg;



---验证查询

SELECT  cpp.contract_id,cpp.item_id,wctt.fconid,
         wctt.inventory_item_id,cpp.plan_quantity,wctt.sumq,cpp.plan_price,
            (CASE
                 WHEN cpp.plan_quantity > wctt.sumq THEN
                  trunc(cpp.plan_price * (1 + nvl(fnd_profile.value('CUX_ITEM_FLOAT')
                                                 ,0) / 100)
                       ,4) * (cpp.plan_quantity - wctt.sumq)
                 ELSE
                  0
               END) amount
   
      FROM (SELECT wc.fconid
                  ,t.inventory_item_id
                
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
                           ,wpc_changecontract_t wcct   --此处考虑了合同版本问题
                      WHERE wcct.fcvid = wct.fcvid
                        AND wct.fchangetype IN ('10'
                                               ,'20')
                        AND wct.fwflowstate = '20'
                        AND wcct.fconid = wc.fconid
                        AND wcct.fbomid = t.fbomid) OR EXISTS
                    (SELECT 1
                       FROM wpc.wpc_contract_t wc1
                      WHERE wc1.fmainconid = wc.fconid  --出处考虑了补充合同
                        AND wc1.fwflowstate = '20'
                        AND wc1.fbomid = t.fbomid))
               AND t.fbomid = wbt.fbomid(+)
               AND t.fbomlistid = wbt.fbomlistid(+)
               AND nvl(wc.fcontractproperty
                      ,'1') <> '2'
                      and wc.fconid=190843 --直接写好合同能提高速度
             GROUP BY wc.fconid
                     ,t.inventory_item_id) wctt
                    
                     
          ,(SELECT cph.contract_id
                  ,cpl.item_id
                  ,SUM(cpl.quantity) plan_quantity
                  ,max(cpl.unit_price) plan_price
              FROM cux_pr_plan_lines   cpl
                  ,cux_pr_plan_headers cph
             WHERE 1 = 1
               AND cpl.header_id = cph.header_id
               AND cph.last_update_date =
                   (SELECT MAX(cphh.last_update_date)
                      FROM cux_pr_plan_headers cphh
                     WHERE cphh.plan_number = cph.plan_number
                       AND cphh.plan_status IN
                           ('APPROVING'
                           ,'APPROVED'
                           ,'ORDERED'))
             GROUP BY cph.contract_id
                     ,cpl.item_id
                      ) cpp
     WHERE cpp.contract_id(+) = wctt.fconid
       AND cpp.item_id(+) = wctt.inventory_item_id
       and wctt.sumq>=0
       and cpp.plan_quantity is not null
       AND wctt.fconid = 190843--直接写好合同能提高速度
     /*  AND wctt.inventory_item_id =
           nvl(p_item_id
              ,wctt.inventory_item_id)*/
              ;