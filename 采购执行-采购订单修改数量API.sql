DECLARE

  l_user_id    NUMBER := 0; --User ID?Sysadmin
  x_api_errors po_api_errors_rec_type; --11.5.10
  l_result     NUMBER;
BEGIN
  mo_global.init('PO');
  --Should initialize before po_change_api1_s.update_po
  apps.fnd_global.apps_initialize(user_id      => l_user_id,
                                  resp_id      => 20707,
                                  resp_appl_id => 201);

  l_result := po_change_api1_s.update_po(x_po_number           => '863',
                                         x_release_number      => NULL,
                                         x_revision_number     => 1,
                                         x_line_number         => 1,
                                         x_shipment_number     => 1,
                                         new_quantity          => 60,
                                         new_price             => 52,
                                         new_promised_date     => SYSDATE,
                                         launch_approvals_flag => 'Y',
                                         update_source         => 'Test Only',
                                         version               => '1.0',
                                         x_override_date       => NULL,
                                         x_api_errors          => x_api_errors,
                                         p_buyer_name          => NULL);

  IF l_result IS NOT NULL THEN
    dbms_output.put_line(l_result);
  END IF;
 /* FOR i IN 1 .. x_api_errors.message_name.COUNT LOOP
    dbms_output.put_line(x_api_errors.message_name(i));
    dbms_output.put_line(x_api_errors.message_text(i));
    dbms_output.put_line(x_api_errors.table_name(i));
    dbms_output.put_line(x_api_errors.column_name(i));
    dbms_output.put_line(x_api_errors.entity_type(i));
    dbms_output.put_line(x_api_errors.entity_id(i));
    dbms_output.put_line(x_api_errors.processing_date(i));
    dbms_output.put_line(x_api_errors.message_type(i));
  END LOOP;*/

END;
