
--test 脚本，在test里面改userid和orgid，
--orgid根据当前这个业务所属的项目公司来看：select * from hr_organization_units hou where hou.organization_id=6735
DECLARE

BEGIN
  -- Test statements here
  FOR cr IN (SELECT b.user_id
                   ,b.responsibility_id
                   ,b.responsibility_application_id
                   ,fr.responsibility_name
               FROM fnd_user_resp_groups_direct b
                   ,fnd_responsibility_vl       fr
              WHERE b.end_date IS NULL
                AND fr.responsibility_id = b.responsibility_id
                AND b.user_id = 1178) LOOP
    BEGIN
    
      cux_init_app_pkg.init(p_user_id      => cr.user_id
                           ,p_resp_id      => cr.responsibility_id
                           ,p_resp_appl_id => cr.responsibility_application_id);
    
      FOR rec_org IN (SELECT organization_name
                            ,organization_id
                        FROM mo_glob_org_access_tmp) LOOP
      
        IF rec_org.organization_id = 6735 THEN
          dbms_output.put_line('职责=====' || cr.responsibility_name);
          dbms_output.put_line('组织=====' || rec_org.organization_name);
        END IF;
      END LOOP;
    
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END LOOP;
END;





SELECT DISTINCT wp.last_name employeename
               ,wp.person_id employee_id
               ,wp.organization_id 
                ,hou1.name
               , pose.organization_id_child
                     ,wp.organization_desc
      ,hou2.name
  FROM wbd_perwsdph_v               wp
      ,per_org_structure_elements_v pose
      ,hr_organization_units hou1
     
      ,hr_organization_units hou2

 WHERE
      hou1.organization_id=pose.organization_id_parent
   and wp.organization_id=hou2.organization_id
 and last_name LIKE nvl(''
                         ,last_name)
   AND 1 = 1
   AND organization_desc LIKE nvl(''
                                 ,organization_desc)
   
   AND job_desc LIKE nvl('项目经理'
                        ,job_desc)
   AND wp.organization_id = pose.organization_id_child
   and wp.last_name='陈志国'
   ;
   
   
   select 　* from wbd_perwsdph_v               wp;