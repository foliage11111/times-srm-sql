select  poh.authorization_status from po_headers_all poh where poh.segment1='2017010501' for update --INCOMPLETE   IN PROCESS   REQUIRES REAPPROVAL  APPROVED


 SELECT usr.user_name,------------ÐÞ¸ÄÃÜÂë
       get_pwd.decrypt((SELECT (SELECT get_pwd.decrypt(fnd_web_sec.get_guest_username_pwd,
                                                      usertable.encrypted_foundation_password)
                                 FROM DUAL) AS apps_password
                         FROM apps.fnd_user usertable
                        WHERE usertable.user_name =
                              (SELECT SUBSTR(fnd_web_sec.get_guest_username_pwd,
                                             1,
                                             INSTR(fnd_web_sec.get_guest_username_pwd,
                                                   '/') - 1)
                                 FROM DUAL)),
                       usr.encrypted_user_password) PASSWORD
  FROM apps.fnd_user usr
 WHERE UPPER(usr.user_name) like '%'||UPPER('&USER_NAME')||'%';
