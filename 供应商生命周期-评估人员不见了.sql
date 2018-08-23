

---查评估单id
select * from cux.cux_slc_inspect_headers t where t.insp_code ='E201709005'; --insp_header_id=3410

--查账号
select *from fnd_user fu where fu.user_name = 'XIAOJUNBIN';

--人员名字是否重复
select * from hr_employees he where he.full_name like '蔡荣勋,'; --1034  -->  21245

select * from hr_employees he where he.employee_id= 1034;

--查评估人员表，有人员、部门、职务
select *  from cux_slc_score_person t where t.insp_header_id = 3410 ;



drop table cux_slc_score_person20171201;
 --先备份 
 create   table cux_slc_score_person20171201 as select * from cux_slc_score_person t
  where t.insp_header_id = 3410 and t.score_person_id = 2016; --注意用的是行id不是人的id
  
  --确认备份成功
  select * from cux_slc_score_person20171201 ;

--更新
update cux_slc_score_person t set t.score_user =21245 
 where t.insp_header_id = 3410 and  t.score_person_id = 2016;--注意用的是行id不是人的id

 
--检查
SELECT fu.user_id
              ,fu.user_name
              ,fu.employee_id
              ,he.employee_num
              ,he.full_name
        FROM   fnd_user     fu
              ,hr_employees he
        WHERE  fu.employee_id = he.employee_id(+)
        AND    fu.start_date <= SYSDATE
        AND    nvl(fu.end_date, SYSDATE) >= SYSDATE
        and fu.user_name='XIAOJUNBIN'



 

----0genju id kan shibushi you mingzi 
SELECT cuxslcscorepersoneo.score_person_id
      ,cuxslcscorepersoneo.insp_header_id
      ,cuxslcscorepersoneo.score_user
      ,cuxslcscorepersoneo.score_dept
      ,cuxslcscorepersoneo.score_job
      ,cuxslcscorepersoneo.score_weight
      ,cuxslcscorepersoneo.is_no_score is_no_score_s
      ,cuxslcscorepersoneo.total_score
      ,(nvl(cuxslcscorepersoneo.trans_status, 'TRANSNO')) trans_status
      ,cuxslcscorepersoneo.trans_user
      ,cuxslcscorepersoneo.submit_date
      ,cuxslcscorepersoneo.submit_status
      ,cuxslcscorepersoneo.is_submit
      ,cuxslcscorepersoneo.s_desc
      ,cuxslcscorepersoneo.remark
      ,cuxslcscorepersoneo.creation_date
      ,cuxslcscorepersoneo.created_by
      ,cuxslcscorepersoneo.last_updated_by
      ,cuxslcscorepersoneo.last_update_date
      ,cuxslcscorepersoneo.last_update_login
      ,cuxslcscorepersoneo.attribute_category
      ,cuxslcscorepersoneo.attribute1
      ,cuxslcscorepersoneo.attribute2
      ,cuxslcscorepersoneo.attribute3
      ,cuxslcscorepersoneo.attribute4
      ,cuxslcscorepersoneo.attribute5
      ,cuxslcscorepersoneo.attribute6
      ,cuxslcscorepersoneo.attribute7
      ,cuxslcscorepersoneo.attribute8
      ,cuxslcscorepersoneo.attribute9
      ,cuxslcscorepersoneo.attribute10
      ,cuxslcscorepersoneo.attribute11
      ,cuxslcscorepersoneo.attribute12
      ,cuxslcscorepersoneo.attribute13
      ,cuxslcscorepersoneo.attribute14
      ,cuxslcscorepersoneo.attribute15
      ,nvl(cuxslcscorepersoneo.is_no_score, 'N') is_no_score
      ,nvl(phe.full_name, phe.user_name) score_user_name
      ,haou.name score_dept_name
      ,hpf.position_name score_job_name
      ,phe1.full_name trans_user_name
      ,nvl(cuxslcscorepersoneo.is_no_score, 'N') if_score
      ,(SELECT fu.user_id
        FROM   fnd_user fu
        WHERE  fu.employee_id = cuxslcscorepersoneo.score_user
        AND    fu.start_date <= SYSDATE
        AND    nvl(fu.end_date, SYSDATE) >= SYSDATE) score_user_id
      ,nvl((SELECT fu.user_id
           FROM   fnd_user fu
           WHERE  fu.employee_id = cuxslcscorepersoneo.trans_user
           AND    fu.start_date <= SYSDATE
           AND    nvl(fu.end_date, SYSDATE) >= SYSDATE),
           -1) tranfer_user_id
      ,(CASE
         WHEN nvl(cuxslcscorepersoneo.is_no_score, 'N') <> 'Y' THEN
          to_number('')
         ELSE
          (nvl((SELECT SUM(csrs.ass_score)
               FROM   cux_slc_review_score csrs
                     ,fnd_user             fu
               WHERE  cuxslcscorepersoneo.insp_header_id =
                      csrs.insp_header_id
               AND    csrs.score_user = fu.user_id
               AND    fu.employee_id = cuxslcscorepersoneo.score_user
               /* AND    csrs.score_job = cuxslcscorepersoneo.score_job*/
               ),
               (SELECT SUM(csrs.ass_score)
                FROM   cux_slc_review_score csrs
                      ,fnd_user             fu
                WHERE  cuxslcscorepersoneo.insp_header_id =
                       csrs.insp_header_id
                AND    csrs.score_user = fu.user_id
                AND    fu.employee_id = cuxslcscorepersoneo.trans_user)))
       END) ass_sum_score
      ,'' trans_user_flag
      ,(SELECT csh.insp_status
        FROM   cux_slc_inspect_headers csh
        WHERE  csh.ins_header_id = cuxslcscorepersoneo.insp_header_id) tran_insp_status
      ,row_number() over(PARTITION BY cuxslcscorepersoneo.insp_header_id ORDER BY cuxslcscorepersoneo.score_person_id) p_row_num
      ,'' view_hide_score
FROM   cux_slc_score_person cuxslcscorepersoneo
      ,(SELECT fu.user_id
              ,fu.user_name
              ,fu.employee_id
              ,he.employee_num
              ,he.full_name
        FROM   fnd_user     fu
              ,hr_employees he
        WHERE  fu.employee_id = he.employee_id(+)
        AND    fu.start_date <= SYSDATE
        AND    nvl(fu.end_date, SYSDATE) >= SYSDATE) phe
      ,hr_all_organization_units haou
      ,(SELECT ap.position_id
              ,ap.name position_name
        FROM   hr_all_positions_f ap
        WHERE  ap.effective_start_date <= SYSDATE
        AND    ap.effective_end_date >= SYSDATE) hpf
      ,(SELECT fu.user_id
              ,fu.user_name
              ,fu.employee_id
              ,he.employee_num
              ,he.full_name
        FROM   fnd_user     fu
              ,hr_employees he
        WHERE  fu.employee_id = he.employee_id(+)
        AND    fu.start_date <= SYSDATE
        AND    nvl(fu.end_date, SYSDATE) >= SYSDATE) phe1
WHERE  cuxslcscorepersoneo.score_user = phe.employee_id(+)
AND    haou.organization_id = cuxslcscorepersoneo.score_dept
AND    hpf.position_id(+) = cuxslcscorepersoneo.score_job
AND    cuxslcscorepersoneo.trans_user = phe1.employee_id(+)
AND    cuxslcscorepersoneo.insp_header_id = 3410
