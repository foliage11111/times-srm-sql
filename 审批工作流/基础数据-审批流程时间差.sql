
select distinct ActivityEO.DISPLAY_NAME,
aa.item_key,status,subject
,to_user,pf.LAST_NAME
,aa.begin_date,aa.end_date,
to_char(aa.end_date,'yyyy-mm-dd'),
to_char(aa.begin_date,'yyyy-mm-dd'),
wfpa.user_comment
--,un.name
  from wf_items t ,wf_notifications aa 
-- left join wf_item_attribute_values bb on aa.item_key=bb.item_key and bb.item_type ='CUXCOMM' 

  --left join PER_ORG_STRUCTURE_ELEMENTS_V t1 on bb.number_value=t1.organization_id_child
-- left join hr_all_organization_units un on t1.organization_id_parent=un.organization_id
       
 left join  fnd_user fn on aa.responder=fn.user_name
 left join  PER_PEOPLE_F pf on fn.employee_id=pf.PERSON_ID
 left join wf_item_activity_statuses wfas on aa.notification_id=wfas.notification_id
 LEFT JOIN    wf_process_activities  wfpa on wfas.process_activity=wfpa.instance_id
 left join  WF_ACTIVITIES_VL ActivityEO on t.ITEM_TYPE=ActivityEO.ITEM_TYPE and t.ROOT_ACTIVITY= ActivityEO.NAME    
  where 
 aa.end_date>to_date('2018-05-01','yyyy-mm-dd') and aa.end_date<to_date('2018-6-30','yyyy-mm-dd')  
 and aa.item_key=t.item_key and t.item_type ='CUXCOMM'  and t.root_activity='CUXPOSDHJS' --and t.item_key=322995
 and t.ROOT_ACTIVITY_VERSION=ActivityEO.VERSION
 --and ActivityEO.NAME='CUXPOSDHJS'
 --  and wf_fwkmon.getitemstatus(t.ITEM_TYPE, t.ITEM_KEY, t.END_DATE, t.ROOT_ACTIVITY, t.ROOT_ACTIVITY_VERSION)= 'COMPLETE'
/*     and wfpa.user_comment<>'������ȷ��' and  wfpa.user_comment<>'�鵵'  and display_name<>'֪ͨ' and wfpa.user_comment<>'�������޸�' 
   and wfpa.user_comment<>'�����˹鵵' and     wfpa.user_comment not like '%������%'
     and  wfpa.user_comment<>'��Ŀ����' and wfpa.user_comment not like '%���%' */
  --   and status='CLOSED'
     ;
     --CUXPOSSHTZ--�ͻ�֪ͨ
     --CUXPOSDHJS--��������
     --CUXPOSDZ--��������
     --CUXPOSFKSQ--��������
 

select distinct wav.DISPLAY_NAME,wav.NAME,wpa.user_comment ,wn.begin_date,wn.end_date -- ,fu.user_name,wn.message_name
, round((wn.end_date -wn.begin_date)*24,2) hours
,pf.LAST_NAME,wn.status,wn.subject,wn.from_user,wn.to_user,
wi.item_type,wi.root_activity,wias.activity_status,wias.activity_result_code
 from wf_items wi,wf_notifications wn, wf_item_activity_statuses wias,wf_process_activities wpa,WF_ACTIVITIES_VL wav  , fnd_user fu , PER_PEOPLE_F pf
  where wi.item_key=wn.item_key
  and wn.responder=fu.user_name
  and wi.ITEM_TYPE=wav.ITEM_TYPE and wi.ROOT_ACTIVITY= wav.NAME  and wi.root_activity_version=wav.VERSION
  and fu.employee_id=pf.PERSON_ID
  /*and pf.EFFECTIVE_START_DATE <sysdate
  and nvl(pf.EFFECTIVE_END_DATE,sysdate) >=sysdate  --��Ϊ�п�������ְ�ˣ����Բ���Ҫ������ݣ�����Ҫȥ��*/
  and wias.notification_id(+)=wn.notification_id
  and wias.process_activity=wpa.instance_id(+)
  and wn.end_date>to_date('2018-05-01','yyyy-mm-dd') and wn.end_date<to_date('2018-6-30','yyyy-mm-dd')
  and wpa.user_comment='�ƻ�����������'
  and wi.root_activity='CUXPOSDHJS' ;

  select * from wf_item_types_vl wit where wit.NAME='CUXCOMM' ;--���湤�����Ķ��壬����
select * from wf_items ;--����ʵ�ʵĹ�����������˵�������Ķ���ʵ��
select * from wf_item_attribute_values wiav where wiav.item_type='CUXCOMM';--���湤����ʵ����attribute����ֵ

select * from wf_item_activity_statuses ;--���湤����ʵ���ĸ���activity��״̬��������ɷ񣬷���ֵ

select * from wf_notifications ;--���湤����ʵ����notifications��Ϣ�������ǰ�˳��ģ����Կ�����˭��
select * from wf_roles ;--��ɫ��ͼ�����������ý�ɫ�����ݣ���mail��ַ����Ϣ
select * from wf_user_roles ;--�û��ͽ�ɫ��ϵ��ͼ�����������Ը��������С�Ⱥ����

select * from wf_process_activities;

select * from WF_ACTIVITIES_VL wav where wav.ITEM_TYPE='CUXCOMM'  --���еĹ����������а汾��˵��;
-- wf_items wi where  wi.ITEM_TYPE=wav.ITEM_TYPE and wi.ROOT_ACTIVITY= wav.NAME  and wi.root_activity_version=wav.VERSION
