--数据已调整。

--数据修复步骤可参考如下：
--1.清空并将a、要更改 招标话，b、原有的联系人，c 最新的人。数据写进临时表c，原来的人和后面要变的人
select * from cux.cux_pon_plan_div_temp;

--2.备份现有招标计划关键节点信息。
CREATE TABLE cux_pon_plan_division_171030 AS
  SELECT d.*
    FROM cux.cux_pon_plan_div_temp t
        ,cux_pon_plan_division     d
   WHERE EXISTS (SELECT *
            FROM cux.cux_pon_bidding_plan pb
           WHERE pb.plan_id = d.plan_id
             AND pb.plan_number = t.plan_number)
     AND d.key_node = 's_Agreement_signed';
 
--3.更新招标计划协议签订节点对应的负责人。



--此 sql 查看每个不同类型招标都有哪些节点，按节点调整
SELECT ffv.flex_value_set_id,ffv.flex_value_id,ffv.flex_value,ffv.enabled_flag,ffv.parent_flex_value_low,ffv.parent_flex_value_high,ffv.attribute1,ffv.attribute3
  FROM fnd_flex_values ffv where
	ffv.flex_value_set_id=1014670
	and ffv.enabled_flag='Y'
	order by ffv.parent_flex_value_low,ffv.flex_value
	;--
	
UPDATE cux_pon_plan_division d
   SET (d.manage_department
      ,d.manager_id
      ,d.manager_pos_id) =
       (SELECT h.department_id
              ,h.person_id
              ,h.position_id
          FROM cux.cux_pon_bidding_plan pb
              ,cux.cux_pon_plan_div_temp t
              ,hr_employees he
              ,(SELECT paa.person_id
                      ,paa.position_id
                      ,paa.job_id
                      ,paa.organization_id department_id
                      ,hpf.position_name
                      ,pjv.job_name
                      ,hou.name            department_name
                  FROM per_all_assignments_f paa
                      ,(SELECT ap.position_id
                              ,ap.name position_name
                          FROM hr_all_positions_f ap
                         WHERE ap.effective_start_date <= SYSDATE
                           AND ap.effective_end_date >= SYSDATE) hpf
                      ,(SELECT pj.job_id
                              ,pj.name job_name
                          FROM per_jobs_vl pj
                         WHERE (pj.date_from IS NULL OR
                               pj.date_from <= SYSDATE)
                           AND (pj.date_to IS NULL OR pj.date_to >= SYSDATE)) pjv
                      ,hr_organization_units_v hou
                 WHERE paa.effective_start_date <= SYSDATE
                   AND paa.effective_end_date >= SYSDATE
                   AND paa.ass_attribute1 = 'HR'
                   AND paa.position_id IS NOT NULL
                   AND hpf.position_id(+) = paa.position_id
                   AND pjv.job_id(+) = paa.job_id
                   AND hou.organization_id /*(+)*/
                       = paa.organization_id
                   AND NOT EXISTS
                 (SELECT 1
                          FROM per_all_people_f a
                         WHERE SYSDATE BETWEEN a.effective_start_date AND
                               a.effective_end_date
                           AND a.person_type_id = 9
                           AND a.person_id = paa.person_id)) h
         WHERE pb.plan_id = d.plan_id
           AND pb.plan_number = t.plan_number
           AND he.last_name = t.cost_employee_name
           AND h.person_id = he.employee_id
           AND h.department_name = '成本管理部(00007)'  ---被调整人所在的部门，需要根据请来找
           AND NOT EXISTS
         (SELECT 1
                  FROM per_all_people_f a
                 WHERE SYSDATE BETWEEN a.effective_start_date AND
                       a.effective_end_date
                   AND a.person_type_id = 9
                   AND a.person_id = he.employee_id))
 WHERE EXISTS (SELECT *
          FROM cux.cux_pon_bidding_plan  pb
              ,cux.cux_pon_plan_div_temp t
         WHERE pb.plan_id = d.plan_id
           AND pb.plan_number = t.plan_number)
   AND d.key_node = 's_Agreement_signed';     ----具体调整的节点
   
   
   
   ---后续导致答疑小组有重复值的查询
   ---查询答疑小组
   select distinct pd.plan_id, 
                    pd.MANAGER_ID        employee_id, 
                    pd.manage_department departmentId, 
                    pd.manager_pos_id    positionId, 
                    hdv.department_name  department, /*负责人部门*/ 
                    hpv.position_name    position, /*负责人岗位*/ 
                    ev1.employee_name    member /*负责人*/ 
      from CUX.CUX_PON_PLAN_DIVISION pd, 
           CUX.CUX_PON_BIDDING_PLAN  pbp, 
           cux_hr_departments_v  hdv, 
           cux_hr_positions_v    hpv, 
           cux_hr_employees_v    ev1 
     where 1 = 1 
       AND pbp.plan_id = pd.plan_id 
       AND pd.manage_department = hdv.organization_id(+) 
       and pd.manager_pos_id = hpv.position_id(+) 
       AND pd.manager_id = ev1.employee_id(+) 
       and ev1.employee_name is not null
       AND PD.PLAN_ID = 7905
			 
			 --单个查询具体的职位和部门
			 select pd.plan_id, 
                    pd.MANAGER_ID        employee_id, 
                    pd.manage_department departmentId, 
                    pd.manager_pos_id    positionId,
										pd.*
										 from  CUX.CUX_PON_PLAN_DIVISION pd
         --  ,CUX.CUX_PON_BIDDING_PLAN  pbp
					 where -- pbp.plan_id = pd.plan_id AND
					  PD.PLAN_ID = 7905
						--修复脚本
						--update CUX.CUX_PON_PLAN_DIVISION pd set pd.manager_pos_id=447941 where pd.plan_id=7905 and pd.plan_division_id=11385