/*1.       �ͻ�֪ͨ����
a)         ��Ŀ�������ڵ�ͣ��ʱ��
 
2.       ������������
a)         ��Ŀ�������ڵ�ͣ��ʱ��
b)         ���Ϲ������Ĺ�Ӧ�����ڵ������ڵ�ͣ��ʱ��
 
3.       ������������
a)         �ɱ��������ڵ�ͣ��ʱ��
b)         ���Ϲ������Ĺ�Ӧ�����ڵ������ڵ�ͣ��ʱ��
 
4.       ������������
a)         �ɱ��������ڵ�ͣ��ʱ��
b)         ���Ϲ������Ľڵ������ڵ�ͣ��ʱ��
c)         ���������ڵ�ͣ��ʱ��*/
--1a �ͻ�֪ͨ����

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
  --and wpa.user_comment='�ƻ�����������'
  and wi.root_activity='CUXPOSSHTZ' 
  -- and wias.activity_result_code <>'REJECTED'
  order by wn.begin_date desc ;
  

--2
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
  and wi.root_activity='CUXPOSDHJS'
   --and wias.activity_result_code <>'REJECTED'
  order by wn.subject desc
  --
   ;
   
   --���˵�
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
 -- and wpa.user_comment='�ƻ�����������'
  and wi.root_activity='CUXPOSDZ'
   -- and wias.activity_result_code <>'REJECTED'
  order by wn.subject desc
  
  ;
  
  
  --��������
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
 -- and wpa.user_comment='�ƻ�����������'
  and wi.root_activity='CUXPOSFKSQ'
 -- and wias.activity_result_code <>'REJECTED'
  order by wn.subject desc
  ;
