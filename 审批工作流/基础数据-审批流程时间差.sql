
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
/*     and wfpa.user_comment<>'发起人确认' and  wfpa.user_comment<>'归档'  and display_name<>'通知' and wfpa.user_comment<>'发起人修改' 
   and wfpa.user_comment<>'经办人归档' and     wfpa.user_comment not like '%经办人%'
     and  wfpa.user_comment<>'项目助理' and wfpa.user_comment not like '%会计%' */
  --   and status='CLOSED'
     ;
     --CUXPOSSHTZ--送货通知
     --CUXPOSDHJS--到货接受
     --CUXPOSDZ--对账审批
     --CUXPOSFKSQ--付款申请
 

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
  and nvl(pf.EFFECTIVE_END_DATE,sysdate) >=sysdate  --因为有可能人离职了，所以不能要这个数据，但是要去重*/
  and wias.notification_id(+)=wn.notification_id
  and wias.process_activity=wpa.instance_id(+)
  and wn.end_date>to_date('2018-05-01','yyyy-mm-dd') and wn.end_date<to_date('2018-6-30','yyyy-mm-dd')
  and wpa.user_comment='计划经办人审批'
  and wi.root_activity='CUXPOSDHJS' ;

  select * from wf_item_types_vl wit where wit.NAME='CUXCOMM' ;--保存工作流的定义，即类
select * from wf_items ;--保存实际的工作流，或者说工作流的对象实例
select * from wf_item_attribute_values wiav where wiav.item_type='CUXCOMM';--保存工作流实例的attribute最新值

select * from wf_item_activity_statuses ;--保存工作流实例的各个activity的状态，比如完成否，返回值

select * from wf_notifications ;--保存工作流实例的notifications消息，基本是按顺序的，可以看发给谁了
select * from wf_roles ;--角色视图，工作流引用角色的依据，有mail地址等信息
select * from wf_user_roles ;--用户和角色关系视图，工作流可以根据它进行“群发”

select * from wf_process_activities;

select * from WF_ACTIVITIES_VL wav where wav.ITEM_TYPE='CUXCOMM'  --现行的工作流，还有版本的说法;
-- wf_items wi where  wi.ITEM_TYPE=wav.ITEM_TYPE and wi.ROOT_ACTIVITY= wav.NAME  and wi.root_activity_version=wav.VERSION
