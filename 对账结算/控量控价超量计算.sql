--控量
SELECT wc.fconid
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
                     and wc.fconid = 177717
             GROUP BY wc.fconid
                     ,t.inventory_item_id
                     ;
                     
                     ---确认一下控价还是控量
                     SELECT a.fbomlistid
                          ,a.fbomid
                          ,a.fquantity
                          ,b.fnumber
                          ,b.fname
                          ,b.segment1
                          ,b.segment2
                          ,b.segment3
                          ,b.segment4
                      
                      FROM wpc_bomlist_t  a
                          ,wbd_material_t b
                     WHERE a.fprdid = b.fprdid
                       AND a.ftype = '2'
                       and a.fbomid=2492
                       ;
                ---控价分类汇总计算ok，虽然阅读计划的这个写法按标段来看是有问题的，但是不分标段的汇总是对的。       
                       
                       SELECT wc.fconid
                  ,t.fnumber
                   ,SUM(nvl(wbt.fquantity
                          ,0)) sumq
              FROM wpc_contract_t wc
                  ,( SELECT a.fbomlistid
                          ,a.fbomid
                          ,a.fquantity
                          ,b.fnumber
                          ,b.fname
                          ,b.segment1
                          ,b.segment2
                          ,b.segment3
                          ,b.segment4
                      
                      FROM wpc_bomlist_t  a
                          ,wbd_material_t b
                     WHERE a.fprdid = b.fprdid
                       AND a.ftype = '2') t
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
                     and wc.fconid = 177717
             GROUP BY wc.fconid
                     ,t.fnumber
                     ;
