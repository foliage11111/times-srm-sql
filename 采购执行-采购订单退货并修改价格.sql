SELECT 
      cpph.version_num 
      ,cpph.plan_status
       --  ,cpph.plan_type
      ,cpph.plan_name
       --  ,cpph.last_update_date
       -- ,cpph.operator_id
      ,fu.user_name
       --   ,pha.last_update_date
    
      ,pha.authorization_status
          ,pha.cancel_flag
       -- ,cppl.ag_header_id
      ,pha2.segment1 
       --  ,cppl.ag_line_id
       --  ,pla.attribute9
      ,pv.vendor_name 
       -- ,pv.vendor_id--
       --  ,pha.po_header_id
       --  ,pla.item_id
      ,msib.segment1           
      ,pla.item_description    
      ,cppl.quantity           
      ,pla.attribute10         
      ,pla2.unit_price         
      ,pha2.attribute6         
      ,pla2.attribute11        
     , cpph.plan_number 
       -- ,cpph.org_id
      ,hou.name         
      ,cppl.unit_price         a
      
      ,cppl.quantity            
      
        ,pha.segment1             
        ,pha.po_header_id 
      ,pla.unit_price          
      ,pla.attribute11         
      ,cdhi.deliver_code       
      ,cdhi.approve_code       
      ,cdli.delivery_lines_id  d
      ,cdli.delivery_count     
      ,cprh.shipment_header_id 
      ,cprh.receipt_num        
      ,cprh.delivery_number    
      ,cprh.approve_code       
      ,cprl.line_number 
      ,cprl.quantity_receiving 
      ,'create table cux_pr_plan_lines_'||cppl.line_id ||' as select * from cux_pr_plan_lines cppl where cppl.line_id='||cppl.line_id --backup plan
      ,'update cux.cux_pr_plan_lines   cppl set cppl.unit_price='||pla2.attribute11 || ' where cppl.line_id='||pla.attribute5--fix plan
      ,'create table po_lines_all_'||pla.po_line_id||' as select * from po_lines_all pla where pla.po_line_id='||pla.po_line_id --backup order
      ,'update po_lines_all pla  set pla.unit_price='||pla2.unit_price ||', pla.attribute11='||pla2.attribute11 || ' where pla.po_line_id='||pla.po_line_id  --fix order
   
 
FROM   po.po_headers_all         pha
      ,po.po_lines_all           pla
      ,fnd_user                  fu
      ,po_vendors                pv
      ,apps.mtl_system_items_b   msib
      ,cux.cux_pr_plan_headers   cpph
      ,cux.cux_pr_plan_lines     cppl
      ,po.po_headers_all         pha2
      ,po.po_lines_all           pla2
      ,hr_organization_units     hou
      ,po_line_locations_all     plla
      ,cux_delivery_headers_info cdhi
      ,cux_delivery_lines_info   cdli
      ,cux_po_receive_headers    cprh
      ,cux_po_receive_lines      cprl
   
WHERE  pla.po_header_id = pha.po_header_id
AND    pha.po_header_id = plla.po_header_id
AND    pla.po_line_id = plla.po_line_id
AND    cpph.header_id = cppl.header_id
AND    pla.attribute5 = cppl.line_id
AND    pha.type_lookup_code = 'STANDARD'
AND    pha2.po_header_id = cppl.ag_header_id
AND    pla2.po_line_id(+) = cppl.ag_line_id
AND    msib.inventory_item_id = pla.item_id
AND    cpph.operator_id = fu.user_id(+)
AND    cpph.org_id = hou.organization_id(+)
AND    msib.organization_id = 460
AND    pv.vendor_id = pha.vendor_id
--     and msib.segment1='3401160030000003'  --
   AND    pha.segment1 = '2018000277' --PO
      
     -- and pha2.segment1='2016000215'      ----
    -- and cpph.plan_number='S201801100'
      --and pla.item_description like '%%'
      --and cpph.org_id=2153
AND    cdhi.po_header_id(+) = pha.po_header_id
AND    cdli.po_location_id(+) = plla.line_location_id
AND    cprh.po_header_id(+) = pha.po_header_id
 AND    cprl.line_location_id(+) = plla.line_location_id

;
 

--z
select  'create table cux_check_vendor_account_180201   as select * from cux_check_vendor_account_temp ccva where ccva.vendor_account_id='||ccva.vendor_account_id --backup plan
        ,'create table cux_check_account_line_180201   as select * from cux_check_account_line_temp ccal where ccal.vendor_account_id='||ccva.vendor_account_id --backup plan
      ,'update cux.cux_check_vendor_account_temp   ccva set ccva.approve_code='||'''DRAFT'''||'  where ccva.vendor_account_id='||ccva.vendor_account_id--fix plan
, ccva.*,ccal.*    from cux_check_vendor_account_temp ccva,
                          cux_check_account_line_temp   ccal
                    where ccva.vendor_account_id = ccal.vendor_account_id
                      and ccva.check_account_num='C2017120231'
                      
                      ;
											
											
											
--z
select  'create table cux_check_vendor_account_180201   as select * from cux_check_vendor_account_temp ccva where ccva.vendor_account_id='||ccva.vendor_account_id --backup plan
        ,'create table cux_check_account_line_180201   as select * from cux_check_account_line_temp ccal where ccal.vendor_account_id='||ccva.vendor_account_id --backup plan
      ,'delete from cux.cux_check_vendor_account_temp   ccva   where ccva.vendor_account_id='||ccva.vendor_account_id--del header
			,'delete from cux.cux_check_account_line_temp   ccal   where ccal.vendor_account_id='||ccal.vendor_account_id--del liens
, ccva.*,ccal.*    from cux_check_vendor_account_temp ccva,
                          cux_check_account_line_temp   ccal
                    where ccva.vendor_account_id = ccal.vendor_account_id
                      and ccva.check_account_num='C2017120231'
											;
											---C2018030054
											
											select * from cux_check_vendor_account_temp ccva;

select * from cux_check_account_line_temp   ccal;

  select * from srm_po_file_t;
											
--att1-3


select rt.attribute1,rt.attribute2,rt.attribute3, rt.* from rcv_transactions rt where rt.attribute1='R2018010535' or  rt.po_header_id=111072;

--update rcv_transactions rt set  rt.attribute1=null,rt.attribute2=null,rt.attribute3=null where rt.attribute1='R2017120373' or  rt.po_header_id=111072;
                      
 
--             
select  'create table cux_po_receive_headers_180201   as select * from  cux.cux_po_receive_headers cprh where cprh.shipment_header_id='||cprh.shipment_header_id --backup plan
        ,'create table cux_po_receive_lines_180201   as select * from cux.cux_po_receive_lines cprl where cprl.shipment_header_id='||cprl.shipment_header_id --backup plan
      ,'update cux.cux_po_receive_headers   cprh set cprh.approve_code='||'''DRAFT'''||'  where cprh.shipment_header_id='||cprh.shipment_header_id--fix p
, cprh.*,cprl.*
 from cux.cux_po_receive_headers  cprh,cux.cux_po_receive_lines cprl
 where cprl.shipment_header_id=cprh.shipment_header_id and cprh.receipt_num='R2018030166';
 
 insert into cux_po_receive_lines r2 (shipment_line_id,shipment_header_id,delivery_lines_id,po_line_id,line_location_id,line_number,item_id
 ,item_code,item_description,unit_of_measure,quantity_shipped,quantity_received,quantity_ordered,
 quantity_receiving,quantity_delivery,project_org_id,project_org_name,project_name,project_peroid
 ,construction_contract,description,last_update_date,last_updated_by,creation_date,created_by
,last_update_login)  
   select r1.b$shipment_line_id,r1.b$shipment_header_id,r1.b$delivery_lines_id,r1.b$po_line_id,r1.b$line_location_id,r1.b$line_number,r1.b$item_id
 ,r1.b$item_code,r1.b$item_description,r1.b$unit_of_measure,r1.b$quantity_shipped,r1.b$quantity_received,r1.b$quantity_ordered,
 r1.b$quantity_receiving,r1.b$quantity_delivery,r1.b$project_org_id,r1.b$project_org_name,r1.b$project_name,r1.b$project_peroid
 ,r1.b$construction_contract,r1.b$description,r1.b$last_update_date,r1.b$last_updated_by,r1.b$creation_date,r1.b$created_by
,r1.b$last_update_login
 from aud.aud$cux_po_receive_lines r1 where r1.b$shipment_line_id=31514  and r1.fuser_id=-1 and r1.foperator='D'
  ;
 
-- delete from cux_po_receive_lines cprl where cprl.shipment_line_id=31514
 --             
select  'create table cux_po_receive_headers_180201   as select * from  cux.cux_po_receive_headers cprh where cprh.shipment_header_id='||cprh.shipment_header_id --backup plan
        ,'create table cux_po_receive_lines_180201   as select * from cux.cux_po_receive_lines cprl where cprl.shipment_header_id='||cprl.shipment_header_id --backup plan
      ,'delete from cux.cux_po_receive_headers   cprh   where cprh.shipment_header_id='||cprh.shipment_header_id--delete header
			,'delete from cux.cux_po_receive_lines   cprl   where cprl.shipment_header_id='||cprh.shipment_header_id--delete line
, cprh.*,cprl.*
 from cux.cux_po_receive_headers  cprh,cux.cux_po_receive_lines cprl
 where cprl.shipment_header_id=cprh.shipment_header_id and cprh.receipt_num='R2017120373';
 
  --             
select  'create table cux_delivery_headers_info_180201   as select * from  cux.cux_delivery_headers_info cpdi where cpdi.del_header_id='||cpdi.del_header_id --backup plan
        ,'create table cux_delivery_lines_info_180201   as select * from cux.cux_delivery_lines_info cpli where cpli.delivery_header_id='||cpli.delivery_header_id --backup plan
      ,'delete from cux.cux_delivery_headers_info cpdi  where cpdi.del_header_id='||cpdi.del_header_id--delete header
			,'delete from cux.cux_delivery_lines_info cpli  where cpli.delivery_header_id='||cpli.delivery_header_id--delete line
, cpdi.*,cpli.*
 from cux.cux_delivery_headers_info  cpdi,cux.cux_delivery_lines_info cpli
 where cpdi.del_header_id=cpli.delivery_header_id and cpdi.deliver_code='D2017120232';


2016000043，2016000078，2016000079，这三份协议需要延期到12月31

select * from po_headers_all pha where pha.segment1 in ('2016000043','2016000078','2016000079') for update;

select rt.attribute1,rt.attribute2,rt.attribute3, rt.* from rcv_transactions rt 
where rt.attribute1='R2018030166' or  rt.po_header_id=114364 and rt.quantity=1028;


select rt.attribute1,rt.attribute2,rt.attribute3, rt.* from rcv_transactions rt where rt.po_header_id=114364 and rt.quantity=1028 for update;

update cux.cux_po_receive_headers   cprh set cprh.approve_code=DRAFT  where cprh.shipment_header_id=4024
         
20170002795
