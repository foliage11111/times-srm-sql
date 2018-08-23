BEGIN

  FOR csr_no IN (SELECT *
                   FROM (SELECT /*+ ORDERED PUSH_SUBQ USE_NL (WN WL WIT) index(WN WF_NOTIFICATIONS_N1)*/
                          wn.notification_id
                         ,wn.from_user
                         ,decode(wn.more_info_role
                                ,NULL
                                ,wn.to_user
                                ,wf_directory.getroledisplayname(wn.more_info_role)) AS to_user
                         ,decode(wn.more_info_role
                                ,NULL
                                ,wn.subject
                                ,fnd_message.get_string('FND'
                                                       ,'FND_MORE_INFO_REQUESTED') || ' ' ||
                                 wn.subject) AS subject
                         ,wn.language
                         ,wn.begin_date
                         ,wn.due_date
                         ,wn.status
                         ,wn.priority
                         ,'P' AS priority_f
                         ,wn.recipient_role
                         ,wn.end_date
                         ,wit.display_name AS TYPE
                         ,wn.more_info_role
                         ,wn.from_role
                         ,wn.message_type
                         ,wn.item_key
                         ,wn.message_name
                         ,wn.mail_status
                         ,wn.original_recipient
                           FROM wf_notifications wn
                               ,wf_item_types_tl wit
                               ,wf_lookups_tl    wl
                          WHERE wn.status = 'OPEN'
                            AND wn.message_type = wit.name
                            AND wit.language = userenv('LANG')
                            AND wl.lookup_type = 'WF_NOTIFICATION_STATUS'
                            AND wn.status = wl.lookup_code
                            AND wl.language = userenv('LANG')
                            AND wn.recipient_role IN
                                (SELECT wur.role_name
                                   FROM wf_user_roles wur
                                  WHERE wur.user_name = 'GUANZHONGXING')
                            AND more_info_role IS NULL
                            AND EXISTS
                          (SELECT 1
                                   FROM wf_notification_attributes na
                                       ,wf_message_attributes      ma
                                  WHERE na.notification_id =
                                        wn.notification_id
                                    AND ma.message_name = wn.message_name
                                    AND ma.message_type = wn.message_type
                                    AND ma.name = na.name
                                    AND ma.subtype = 'RESPOND')
                         UNION ALL
                         SELECT /*+ ORDERED PUSH_SUBQ USE_NL (WN WL WIT) index(WN WF_NOTIFICATIONS_N6)*/
                          wn.notification_id
                         ,wn.from_user
                         ,decode(wn.more_info_role
                                ,NULL
                                ,wn.to_user
                                ,wf_directory.getroledisplayname(wn.more_info_role)) AS to_user
                         ,decode(wn.more_info_role
                                ,NULL
                                ,wn.subject
                                ,fnd_message.get_string('FND'
                                                       ,'FND_MORE_INFO_REQUESTED') || ' ' ||
                                 wn.subject) AS subject
                         ,wn.language
                         ,wn.begin_date
                         ,wn.due_date
                         ,wn.status
                         ,wn.priority
                         ,'P' AS priority_f
                         ,wn.recipient_role
                         ,wn.end_date
                         ,wit.display_name AS TYPE
                         ,wn.more_info_role
                         ,wn.from_role
                         ,wn.message_type
                         ,wn.item_key
                         ,wn.message_name
                         ,wn.mail_status
                         ,wn.original_recipient
                           FROM wf_notifications wn
                               ,wf_item_types_tl wit
                               ,wf_lookups_tl    wl
                          WHERE wn.status = 'OPEN'
                            AND wn.message_type = wit.name
                            AND wit.language = userenv('LANG')
                            AND wl.lookup_type = 'WF_NOTIFICATION_STATUS'
                            AND wn.status = wl.lookup_code
                            AND wl.language = userenv('LANG')
                            AND wn.more_info_role IN
                                (SELECT wur.role_name
                                   FROM wf_user_roles wur
                                  WHERE wur.user_name = 'GUANZHONGXING')
                            AND EXISTS
                          (SELECT 1
                                   FROM wf_notification_attributes na
                                       ,wf_message_attributes      ma
                                  WHERE na.notification_id =
                                        wn.notification_id
                                    AND ma.message_name = wn.message_name
                                    AND ma.message_type = wn.message_type
                                    AND ma.name = na.name
                                    AND ma.subtype = 'RESPOND')) qrslt
                  WHERE EXISTS (SELECT *
                           FROM wf_items wi
                          WHERE wi.item_type = qrslt.message_type
                            AND wi.item_key = qrslt.item_key
                            AND wi.end_date <= SYSDATE)
                  ORDER BY TYPE ASC) LOOP
  
    dbms_output.put_line('标识：' || csr_no.notification_id);
    wf_notification.cancel(nid            => csr_no.notification_id
                          ,cancel_comment => '因流程作废而取消通知');
  
  END LOOP;

END;