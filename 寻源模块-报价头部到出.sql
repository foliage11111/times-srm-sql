select * from cux.cux_pon_bidding_plan cpbp where cpbp.plan_number='ZB2018087'; --8204
select * from cux.cux_pon
select ctft.tender_id,ctft.* from cux.CUX_TENDER_FILE_TMP  ctft where ctft.plan_id=8205  for update ;--招标文件基本信息表

 create table CUX_TEN_MATERIAL_TMP_085303 as select *   from cux.CUX_TEN_MATERIAL_TMP ctmt where ctmt.tender_id in (1710,1697);
select * from CUX_TEN_MATERIAL_TMP_085303;
select ctmt.tender_id,ctmt.ten_material_id,ctmt.* from cux.CUX_TEN_MATERIAL_TMP ctmt where ctmt.tender_id in (1710,1697) for update; --招标材料清单

select * from CUX_TEN_TIME_CONTROL_TMP ttct where ttct.tender_book_number='ZB20181500401' for update; -- 拟标发标基本信息表

select * from cux.cux_ten_area_tmp  ctat where ctat.ten_material_id=751966 ;--招标文件区域表

select * from cux.CUX_QUOTE_PROPERTY_TMP cqpt where cqpt.ten_material_id=752184 for update;--招标文件属性表

---八戒
select cpbp.plan_number,cpbp.plan_name,cpbp.business_type ,av.vendor_name,av.vendor_number
,cgpb.plan_id,cgpb.tax_rate,cgpb.creation_date 创建时间
 ,cgpb.bid_num,cgpb.status 
,cgpb.last_update_date 提交时间

 from
CUX_GATEWAY_PROJECT_BASE cgpb ,
cux.cux_pon_bidding_plan cpbp,
ap_vendors_v av 
where 
cpbp.plan_id=cgpb.plan_id
and av.vendor_id=cgpb.vendor_id
and cpbp.plan_number='ZB2018087' ;

select * from CUX_GATEWAY_MATERIAL_QUOTE cgmq where cgmq.project_base_id in (8202,8207,8206) ;  --材料报价
