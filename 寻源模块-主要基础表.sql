select * from cux.cux_pon_bidding_plan cpbp where cpbp.plan_number='ZB2018181'; --8204
select * from cux.cux_pon
select ctft.tender_id,ctft.* from cux.CUX_TENDER_FILE_TMP  ctft where ctft.plan_id=8205  for update ;--招标文件基本信息表

 create table CUX_TEN_MATERIAL_TMP_085303 as select *   from cux.CUX_TEN_MATERIAL_TMP ctmt where ctmt.tender_id in (1710,1697);
select * from CUX_TEN_MATERIAL_TMP_085303;
select ctmt.tender_id,ctmt.ten_material_id,ctmt.* from cux.CUX_TEN_MATERIAL_TMP ctmt where ctmt.tender_id in (1710,1697) for update; --招标材料清单

select * from CUX_TEN_TIME_CONTROL_TMP ttct where ttct.tender_book_number='ZB20181810501' for update; -- 拟标发标基本信息表

select * from CUX_TEN_ANSWER_TMP ctat where ctat.receipt_number='ZB20181810501' ;--答疑基本信息

select * from cux.cux_ten_area_tmp  ctat where ctat.ten_material_id=751966 ;--招标文件区域表

select * from cux.CUX_QUOTE_PROPERTY_TMP cqpt where cqpt.ten_material_id=752184 for update;--招标文件属性表

create table CUX_GATEWAY_PROJECT_BASE_08531 as  select * from CUX_GATEWAY_PROJECT_BASE cgpb where cgpb.plan_id=8205;
select * from CUX_GATEWAY_PROJECT_BASE_08531;
select * from CUX_GATEWAY_PROJECT_BASE cgpb where cgpb.plan_id=8206 for update;

select * from CUX_GATEWAY_MATERIAL_QUOTE cgmq where cgmq.project_base_id in (8202,8207,8206) ;  --材料报价

select * from CUX_QUOTE_PROPERTY_TMP cqpt where cqpt.ten_material_id=751943
  ;--报价属性表
select * from CUX_TEN_PRO_INFORMATION_TMP ctpi where ctpi.plan_id=8204;

select * from CUX_PO_BID_PERSONNEL_TMP cpbpt where cpbpt.plan_id=8204;

CUX_TEN_MAT_RESULT_TMP
