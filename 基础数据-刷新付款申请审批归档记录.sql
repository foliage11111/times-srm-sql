--- body
sELECT *
  FROM wf_approve_html_t wah
 WHERE wah.item_key IN (SELECT MAX(wi.item_key) item_key
                          FROM wf_items    wi
													where
													wi.item_key='259706')
												--	for update
												;
 -- header
 SELECT *      FROM wf_items    wi
													where
													wi.item_key='259601';

--
		sELECT *
  FROM wf_approve_html_t wah where wah.source_code ='CUXCOMM'
	--and wah.item_key='259601'
	and wah.creation_date between to_date('2018-4-17 11:00:00','yyyy-mm-dd hh24:mi:ss') and to_date('2018-4-17 15:00:00','yyyy-mm-dd hh24:mi:ss')
	order by wah.creation_date desc ;
        
CREATE TABLE wf_approve_html_171019 AS
SELECT *
  FROM wf_approve_html_t wah
 WHERE wah.item_key IN (SELECT MAX(wi.item_key) item_key
                          FROM wf_items                     wi
                              ,cux.cux_payment_protal_apply cpp
                         WHERE wf_fwkmon.getitemstatus(wi.item_type
                                                      ,wi.item_key
                                                      ,wi.end_date
                                                      ,wi.root_activity
                                                      ,wi.root_activity_version) =
                               'COMPLETE'
                           AND wi.item_type = 'CUXCOMM'
                           AND wi.root_activity = 'CUXPOSFKSQ'
                           AND cpp.approve_state = 'APPROVED'
                           AND EXISTS
                         (SELECT 1
                                  FROM wf_item_attribute_values wia
                                 WHERE wia.item_type = wi.item_type
                                   AND wia.item_key = wi.item_key
                                   AND wia.name = 'SOURCE_HEADER_ID'
                                   AND wia.number_value = cpp.protal_apply_id)
                         GROUP BY cpp.protal_apply_id
                                 ,cpp.protal_apply_code
                                 ,cpp.approve_state);
      

CREATE TABLE wf_approve_html_17101901 AS
SELECT *
  FROM wf_approve_html_t wah
 WHERE wah.item_key IN (SELECT MAX(wi.item_key) item_key
                          FROM wf_items                     wi
                              ,cux.cux_payment_protal_apply cpp
                         WHERE wf_fwkmon.getitemstatus(wi.item_type
                                                      ,wi.item_key
                                                      ,wi.end_date
                                                      ,wi.root_activity
                                                      ,wi.root_activity_version) =
                               'COMPLETE'
                           AND wi.item_type = 'CUXCOMM'
                           AND wi.root_activity = 'CUXPOSFKSQ'
                           AND cpp.approve_state = 'APPROVED'
                           AND EXISTS
                         (SELECT 1
                                  FROM wf_item_attribute_values wia
                                 WHERE wia.item_type = wi.item_type
                                   AND wia.item_key = wi.item_key
                                   AND wia.name = 'SOURCE_HEADER_ID'
                                   AND wia.number_value = cpp.protal_apply_id)
                         GROUP BY cpp.protal_apply_id
                                 ,cpp.protal_apply_code
                                 ,cpp.approve_state);
      
CREATE TABLE wf_approve_html_17110201 AS
SELECT *
  FROM wf_approve_html_t wah
 WHERE wah.item_key IN (SELECT MAX(wi.item_key) item_key
                          FROM wf_items                     wi
                              ,cux.cux_payment_protal_apply cpp
                         WHERE wf_fwkmon.getitemstatus(wi.item_type
                                                      ,wi.item_key
                                                      ,wi.end_date
                                                      ,wi.root_activity
                                                      ,wi.root_activity_version) =
                               'COMPLETE'
                           AND wi.item_type = 'CUXCOMM'
                           AND wi.root_activity = 'CUXPOSFKSQ'
                           AND cpp.approve_state = 'APPROVED'
                           AND EXISTS
                         (SELECT 1
                                  FROM wf_item_attribute_values wia
                                 WHERE wia.item_type = wi.item_type
                                   AND wia.item_key = wi.item_key
                                   AND wia.name = 'SOURCE_HEADER_ID'
                                   AND wia.number_value = cpp.protal_apply_id)
                         GROUP BY cpp.protal_apply_id
                                 ,cpp.protal_apply_code
                                 ,cpp.approve_state);
                                                            
 DELETE  FROM wf_approve_html_t wah
 WHERE wah.item_key IN (SELECT MAX(wi.item_key) item_key
                          FROM wf_items                     wi
                              ,cux.cux_payment_protal_apply cpp
                         WHERE wf_fwkmon.getitemstatus(wi.item_type
                                                      ,wi.item_key
                                                      ,wi.end_date
                                                      ,wi.root_activity
                                                      ,wi.root_activity_version) =
                               'COMPLETE'
                           AND wi.item_type = 'CUXCOMM'
                           AND wi.root_activity = 'CUXPOSFKSQ'
                           AND cpp.approve_state = 'APPROVED'
                           AND EXISTS
                         (SELECT 1
                                  FROM wf_item_attribute_values wia
                                 WHERE wia.item_type = wi.item_type
                                   AND wia.item_key = wi.item_key
                                   AND wia.name = 'SOURCE_HEADER_ID'
                                   AND wia.number_value = cpp.protal_apply_id)
                         GROUP BY cpp.protal_apply_id
                                 ,cpp.protal_apply_code
                                 ,cpp.approve_state);
                                                            
DECLARE
  p_itemkey VARCHAR2(240);

  v_body_html CLOB;
  v_his_html  CLOB;

  v_count NUMBER;

BEGIN

  FOR rec_h IN (SELECT MAX(wi.item_key) item_key
                      ,cpp.protal_apply_id
                      ,cpp.protal_apply_code
                      ,cpp.approve_state
                  FROM wf_items                     wi
                      ,cux.cux_payment_protal_apply cpp
                 WHERE wf_fwkmon.getitemstatus(wi.item_type
                                              ,wi.item_key
                                              ,wi.end_date
                                              ,wi.root_activity
                                              ,wi.root_activity_version) =
                       'COMPLETE'
                   AND wi.item_type = 'CUXCOMM'
                   AND wi.root_activity = 'CUXPOSFKSQ'
                   AND cpp.approve_state = 'APPROVED'
                   AND EXISTS
                 (SELECT 1
                          FROM wf_item_attribute_values wia
                         WHERE wia.item_type = wi.item_type
                           AND wia.item_key = wi.item_key
                           AND wia.name = 'SOURCE_HEADER_ID'
                           AND wia.number_value = cpp.protal_apply_id)
                 GROUP BY cpp.protal_apply_id
                         ,cpp.protal_apply_code
                         ,cpp.approve_state) LOOP
  
    p_itemkey := rec_h.item_key;
  
    SELECT COUNT(1)
      INTO v_count
      FROM wf_approve_html_t wah
     WHERE wah.item_key = p_itemkey;
  
    v_body_html := cux_wf_approve_pkg.construct_body_p('CUXCOMM'
                                                      ,p_itemkey);
  
    v_his_html := cux_wf_approve_pkg.construct_history_p('CUXCOMM'
                                                        ,p_itemkey);
  
    IF v_count = 0 THEN
    
      INSERT INTO wf_approve_html_t
      
        (item_key
        ,
         
         source_code
        ,
         
         source_id
        ,
         
         body_html
        ,
         
         his_html
        ,
         
         last_update_date
        ,
         
         last_updated_by
        ,
         
         creation_date
        ,
         
         created_by
        ,
         
         last_update_login)
      
      VALUES
      
        (p_itemkey
        ,
         
         'CUXCOMM'
        ,
         
         rec_h.protal_apply_id
        ,
         
         v_body_html
        ,
         
         v_his_html
        ,
         
         SYSDATE
        ,
         
         fnd_global.user_id
        ,
         
         SYSDATE
        ,
         
         fnd_global.user_id
        ,
         
         fnd_global.login_id);
    
    ELSE
    
      UPDATE wf_approve_html_t wah
         SET wah.body_html = v_body_html
            ,wah.his_html  = v_his_html
       WHERE wah.item_key = p_itemkey;
    
    END IF;
  
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    NULL;

end;
