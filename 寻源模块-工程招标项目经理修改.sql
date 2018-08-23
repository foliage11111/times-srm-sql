--由于HR系统人员信息调整后，招标计划中的项目经理ID未进行调整，所以资格预审项目经理流程发起不正常。
--上次有一个招标"汉溪项目4栋19层商业总部办公室装修工程"出现问题后，发过调整项目经理ID的脚本，
--以及重推那个招标"汉溪项目4栋19层商业总部办公室装修工程"项目经理流程的脚本，
--不排除还有其他招标未进行重推
--
----本sql查询招标的时候能否选到项目经理，这个wbd确实是个麻烦问题
---在tst职责下可以查项目分期与项目公司 关系
--这个地方的父组织是指的项目公司的母公司，比如惠州分公司这样，下面有好几个项目分公司
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


--以下是更新招标计划项目经理ID的脚本。

------
/*备份招标计划*/
create table cux_pon_bidding_plan_171031 as
SELECT *
  FROM cux.cux_pon_bidding_plan d
 WHERE EXISTS
 (SELECT 1
          FROM per_all_people_f a
              ,per_all_people_f b
         WHERE a.previous_last_name = b.previous_last_name
           AND SYSDATE BETWEEN a.effective_start_date AND
               a.effective_end_date
           AND SYSDATE BETWEEN b.effective_start_date AND
               b.effective_end_date
           AND a.person_type_id = 9
           AND b.person_type_id = 6
           AND d.manager_id = a.person_id);
           
/*更新招标计划项目经理ID*/       
 UPDATE cux.cux_pon_bidding_plan d
    SET d.manager_id =
        (SELECT b.person_id
           FROM per_all_people_f a
               ,per_all_people_f b
          WHERE a.previous_last_name = b.previous_last_name
            AND SYSDATE BETWEEN a.effective_start_date AND
                a.effective_end_date
            AND SYSDATE BETWEEN b.effective_start_date AND
                b.effective_end_date
            AND a.person_type_id = 9
            AND b.person_type_id = 6
            AND d.manager_id = a.person_id)
  WHERE EXISTS (SELECT 1
           FROM per_all_people_f a
               ,per_all_people_f b
          WHERE a.previous_last_name = b.previous_last_name
            AND SYSDATE BETWEEN a.effective_start_date AND
                a.effective_end_date
            AND SYSDATE BETWEEN b.effective_start_date AND
                b.effective_end_date
            AND a.person_type_id = 9
            AND b.person_type_id = 6
            AND d.manager_id = a.person_id);



重新发送入围供应商项目经理选中通知的脚本：


SELECT t.prequalificate_id
  FROM cux.cux_ten_mat_trial_tmp t
      ,cux.cux_pon_bidding_plan  pbp
 WHERE t.plan_id = pbp.plan_id
   AND pbp.plan_name = '汉溪项目4栋19层商业总部办公室装修工程';


begin
  -- Call the procedure
  cux_fnd_login_main_pkg.send_notification(p_document_id => 4905,
                                           p_notice_type => 'CUXNOTICE5');

end;



select * from WBD_PERWSDPH_V t where t.last_name like '%王敬军%'
;


select * from PER_ORG_STRUCTURE_ELEMENTS_V t where T.organization_id_child IN (6859,318);--parent_id=7543

select * from PER_ORG_STRUCTURE_ELEMENTS_V t where T.organization_id_child IN (7543);--parent=102
;
select * from PER_ORG_STRUCTURE_ELEMENTS_V t where T.organization_id_parent IN (102);--parent=102
; 


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
   and wp.last_name='朱春生'
   ;
   
   ---查项目的所属组织
   Select b.Fpbid             Project_Block_Id
      , --项目分期ID  
       b.Fnumber           Project_Block_Number
      , --分期编码   
       b.Fname             Project_Block_Name
      , --分期名称   
       Wpt.Fprjid          Project_Id
      ,Wpt.Fnumber         Project_Number
      ,Wpt.Fname           Project_Name
      ,Hou.Organization_Id Citycompanyid
      ,Hou.Name            Citycompany
      ,Wpt.Fprjno
  From Wbd_Projectblock_t        b
      ,Wbd.Wbd_Project_t         Wpt
      ,Hr_All_Organization_Units Hou
 Where 1 = 1
   And b.Fprjid = Wpt.Fprjid
   And Wpt.Fiseffective = '1'
   And Hou.Organization_Id =
       Cux_Assets_Utils_Pkg.Get_Top_Org_Structure(Wpt.Org_Id)
   And Wpt.Fname Like '%雁山%';
   
--查某个组织下面的项目经理
Select Distinct Wp.Last_Name Employeename
               ,Wp.Person_Id Employee_Id
  From Wbd_Perwsdph_v               Wp
      ,Per_Org_Structure_Elements_v Pose
 Where Last_Name Like Nvl(''
                         ,Last_Name)
   And 1 = 1
   And Organization_Desc Like Nvl(''
                                 ,Organization_Desc)
   And (Nvl(Name
           ,'9999') Like Nvl(''
                             ,Nvl(Name
                                 ,'9999')))
   And Job_Desc Like Nvl('项目经理'
                        ,Job_Desc)
   And Wp.Organization_Id = Pose.Organization_Id_Child
   And Pose.Organization_Id_Parent = 102;