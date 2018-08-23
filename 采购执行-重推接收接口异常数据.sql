
select * from po_interface_errors pie
WHERE  pie.interface_type = 'RCV-856'
AND    EXISTS (SELECT 1
        FROM   rcv_headers_interface t
        WHERE  t.processing_status_code = 'ERROR'
        AND    pie.batch_id = t.group_id
        AND    t.group_id > 1970);

CREATE TABLE rcv_headers_interface_180103 AS
  SELECT *
  FROM   rcv_headers_interface t
  WHERE  t.processing_status_code = 'ERROR'
  AND    t.group_id > 1970;

CREATE TABLE rcv_transactions_int_180103 AS
  SELECT *
  FROM   rcv_transactions_interface rti
  WHERE  EXISTS (SELECT 1
          FROM   rcv_headers_interface t
          WHERE  t.processing_status_code = 'ERROR'
          AND    rti.group_id = t.group_id
          AND    t.group_id > 1970);



DELETE po_interface_errors pie
WHERE  pie.interface_type = 'RCV-856'
AND    EXISTS (SELECT 1
        FROM   rcv_headers_interface t
        WHERE  t.processing_status_code = 'ERROR'
        AND    pie.batch_id = t.group_id
        AND    t.group_id > 1970);
        
UPDATE rcv_transactions_interface rti
SET    rti.transaction_status_code = 'PENDING'
      ,rti.processing_status_code  = 'PENDING'
      ,rti.document_line_num       = NULL
WHERE  EXISTS (SELECT 1
        FROM   rcv_headers_interface t
        WHERE  t.processing_status_code = 'ERROR'
        AND    rti.group_id = t.group_id
        AND    t.group_id > 1970);
        
UPDATE rcv_headers_interface t
SET    t.processing_status_code = 'PENDING'
      ,t.transaction_type       = 'NEW'
WHERE  t.processing_status_code = 'ERROR'
AND    t.group_id > 1970;



DECLARE

  v_request_id NUMBER;

BEGIN

  fnd_global.apps_initialize(user_id      => 0,
                             resp_id      => 53386,
                             resp_appl_id => 201);

  fnd_request.set_org_id(org_id => 2253);

  FOR rec_group IN (SELECT t.group_id FROM rcv_headers_interface_180103 t) LOOP
    v_request_id := fnd_request.submit_request('PO',
                                               'RVCTP',
                                               '',
                                               '',
                                               FALSE,
                                               'BATCH' /*事务处理模式*/,
                                               rec_group.group_id /*事务处理组标识*/,
                                               2253 /*业务实体ID*/);
  
    dbms_output.put_line('v_request_id:' || v_request_id);
  
    IF v_request_id > 0 THEN
      COMMIT;
    ELSE
      ROLLBACK;
    END IF;
  
  END LOOP;

END;
