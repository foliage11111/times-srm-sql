select sess.sid, 
    sess.serial#, 
    lo.oracle_username, 
    lo.os_user_name, 
    ao.object_name, 
    lo.locked_mode 
    from v$locked_object lo, 
    dba_objects ao, 
    v$session sess 
where ao.object_id = lo.object_id and lo.session_id = sess.sid;

alter system kill session '7758,46692'; 

--
SELECT DISTINCT per_name
FROM   (SELECT ppf.first_name || ppf.last_name per_name
              ,paa.effective_start_date
              ,paa.effective_end_date
        FROM   hr_organization_units_v hou
              ,per_all_assignments_f   paa
              ,per_people_f            ppf
        WHERE  hou.organization_id = paa.organization_id(+)
        AND    paa.person_id = ppf.person_id
        AND    paa.position_id IS NOT NULL
              /*AND    paa.effective_start_date <= SYSDATE
              AND    paa.effective_end_date >= SYSDATE*/
        AND    ppf.effective_start_date <= SYSDATE
        AND    ppf.effective_end_date >= SYSDATE
        AND    to_char(paa.effective_end_date, 'yyyy-mm-dd') >=
               to_char('2017-04-23')
        AND    to_char(paa.effective_end_date, 'yyyy-mm-dd') <=
               to_char(SYSDATE, 'yyyy-mm-dd'))   
