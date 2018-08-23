

select * from cux_pr_plan_headers cpph,cux_pr_plan_lines cppl where
 cpph.plan_number='S2018051235' and cppl.header_id=cpph.header_id;

select * from po_interface_errors pie,po_headers_interface phi,po_lines_interface pli ,
cux_pr_plan_headers cpph,cux_pr_plan_lines cppl where
  phi.interface_header_id=pli.interface_header_id and phi.interface_source_code='PR_PLAN'
  and cpph.plan_number='S2018051235' and cppl.header_id=cpph.header_id
 and pli.line_attribute5=cppl.line_id and pie.interface_header_id =pli.interface_header_id
;

truncate table po.po_lines_interface;

select * from po_interface_errors ;

create table po_headers_interface_180607 as 
select * from po_headers_interface phi 
;
create table po_lines_interface_180607 as
select * from po_lines_interface pli 
;
