declare
  p_contract_id NUMBER;
  p_item_id NUMBER;
    v_quantity       NUMBER;
    v_overrun_amount NUMBER := 0; /*³¬³ö½ð¶î*/
  
  BEGIN
  --
    p_contract_id := 177717;
  
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
              
              dbms_output.put_line('v_overrun_amount'||v_overrun_amount);
            end  ;
