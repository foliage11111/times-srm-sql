--����ͷ
select * from cux_slc_template_header t where t.temple_code = 'T2017003';
--����ά��
select * from cux_slc_assess_dimension t where t.temple_header_id = 218;
--����ά����--���Զ������
select * from cux_slc_dimension_lines t where t.dimen_header_id in (331,332,334,333);
--����ָ��
select * from cux_slc_target_headers;
--���Ƕ�Ӧ��������4���û��Ĵ���÷�
select *
  from cux_slc_review_score t
 where t.insp_header_id = 7932
   and t.score_user in (1562, 14808, 7945, 2557)
   and not exists
 (select 1
          from cux_slc_target_headers th
         where th.target_header_id = t.target_header_id
           and th.tample_header_id = 218
           and exists (select 1
                  from cux_slc_assess_dimension cd
                 where cd.temple_header_id = 218
                   and cd.dimension_id = th.ass_diminsion_id
                   and cd.dimension_id = 334));
                   
                   
									 
									 select *
          from cux_slc_target_headers th
         where   th.tample_header_id = 218
           and exists (select 1
                  from cux_slc_assess_dimension cd
                 where cd.temple_header_id = 218
                   and cd.dimension_id = th.ass_diminsion_id
                   and cd.dimension_id = 334)
									 ;
									 
  --������������
create table cux_slc_review_score20180423 as select *
  from cux_slc_review_score t
 where t.insp_header_id = 7932
   and t.score_user in (1562, 14808, 7945, 2557)
   and not exists
 (select 1
          from cux_slc_target_headers th
         where th.target_header_id = t.target_header_id
           and th.tample_header_id = 218
           and exists (select 1
                  from cux_slc_assess_dimension cd
                 where cd.temple_header_id = 218
                   and cd.dimension_id = th.ass_diminsion_id
                   and cd.dimension_id = 334));

select * from cux_slc_review_score20180423;


---ɾ����������

delete from  cux_slc_review_score css
 where css.insp_header_id = 7932
   and exists
 (select 1
          from cux_slc_review_score t
         where t.insp_header_id = 7932
           and t.score_user in (1562, 14808, 7945, 2557)
           and t.score_id = css.score_id
           and not exists
         (select 1
                  from cux_slc_target_headers th
                 where th.target_header_id = t.target_header_id
                   and th.tample_header_id = 218
                   and exists
                 (select 1
                          from cux_slc_assess_dimension cd
                         where cd.temple_header_id = 218
                           and cd.dimension_id = th.ass_diminsion_id
                           and cd.dimension_id = 334)));

---����ģ���е�����
create table cux_slc_dimension_lines0423 as 
select * from cux_slc_dimension_lines t where t.dimen_header_id = 333 and t.dimen_line_id = 418;

select * from cux_slc_dimension_lines0423;

---ɾ��ģ���ж�������ֲ���
delete from cux_slc_dimension_lines t where t.dimen_header_id = 333 and t.dimen_line_id = 418;


update cux_slc_inspect_headers t set t.total_score = 96.23 where t.insp_code = 'E201803016';