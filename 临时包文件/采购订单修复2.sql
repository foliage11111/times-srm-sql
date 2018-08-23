 select * from po_headers_all pha where pha.po_header_id in (127089,127088);
   
      --127089,127088,119202
  select --pha.b$segment1,
               pla.b$po_header_id,
                pla.b$po_line_id,
                 pla.b$item_id,
               pla.b$quantity,
               pla.b$unit_price,
               pla.b$item_description,
							 pla.b$creation_date,
               pp.*
          from aud.aud$po_lines_all pla,
          --aud.aud$po_headers_all pha,
          (select cpph.plan_number,cpph.version_num,cppl.item_id,cppl.line_id,cppl.quantity,cppl.description
					 from cux_pr_plan_headers cpph,CUX_PR_PLAN_LINES cppl
 where cpph.header_id=cppl.header_id and cpph.plan_number='S201802140'
   and cpph.version_num=3
  ) pp
         where --pla.b$po_header_id = pha.b$po_header_id
           pp.item_id=pla.b$item_id(+)
         and pp.quantity=pla.b$quantity(+)
   ;
	 
	 
	 select --pha.b$segment1,
               pla.a$po_header_id,
                pla.a$po_line_id,
                 pla.a$item_id,
               pla.a$quantity,
               pla.a$unit_price,
               pla.a$item_description,
							 pla.a$creation_date,
							 pla.a$attribute5,
							 pp.line_id,
               pp.*
          from aud.aud$po_lines_all pla,
          --aud.aud$po_headers_all pha,
          (select cpph.plan_number,cpph.version_num,cppl.item_id,cppl.line_id,cppl.quantity,cppl.description
					 from cux_pr_plan_headers cpph,CUX_PR_PLAN_LINES cppl
 where cpph.header_id=cppl.header_id and cpph.plan_number='S201802140'
   and cpph.version_num=1
  ) pp
         where --pla.b$po_header_id = pha.b$po_header_id
           pp.item_id=pla.a$item_id(+)
         and pp.quantity=pla.a$quantity(+)
   ;
	 
	  select --pha.b$segment1,
               pla.a$po_header_id,
                pla.a$po_line_id,
                 pla.a$item_id,
               pla.a$quantity,
               pla.a$unit_price,
               pla.a$item_description,
							 pla.a$creation_date,
							 pla.a$last_update_date,
							 
							 pla.a$attribute5,
               pp.*
          from aud.aud$po_lines_all pla,
          --aud.aud$po_headers_all pha,
          (select cpph.plan_number,cpph.version_num,cppl.item_id,cppl.line_id,cppl.quantity,cppl.description
					 from cux_pr_plan_headers cpph,CUX_PR_PLAN_LINES cppl
 where cpph.header_id=cppl.header_id and cpph.plan_number='S201802140'
   and cpph.version_num=3
  ) pp
         where --pla.b$po_header_id = pha.b$po_header_id
           pp.item_id=pla.a$item_id(+)
         and pp.quantity=pla.a$quantity(+)
	 and  pla.a$attribute5=pp.line_id
	 
	;
	
	
	  select --pha.b$segment1,
               pla.b$po_header_id,
                pla.b$po_line_id,
                 pla.b$item_id,
               pla.b$quantity,
               pla.b$unit_price,
               pla.b$item_description,
							 pla.b$creation_date,
							 pla.b$last_update_date,
							 
							 pla.b$attribute5,
               pp.*
          from aud.aud$po_lines_all pla,
          --aud.aud$po_headers_all pha,
          (select cpph.plan_number,cpph.version_num,cppl.item_id,cppl.line_id,cppl.quantity,cppl.description
					 from cux_pr_plan_headers cpph,CUX_PR_PLAN_LINES cppl
 where cpph.header_id=cppl.header_id and cpph.plan_number='S201802140'
   and cpph.version_num=1
  ) pp
         where --pla.b$po_header_id = pha.b$po_header_id
           pp.item_id=pla.b$item_id(+)
         and pp.quantity=pla.b$quantity(+)
	 and  pla.a$attribute5=pp.line_id
	 
	;
	
	 select* from(
	 select pha.segment1,pha.po_header_id,pha.approved_flag,pha.cancel_flag,pha.creation_date
	 ,pha.created_by,pha.last_update_date,pha.last_updated_by,pla.po_line_id,pla.line_num
	 ,pla.item_id,pla.quantity,pla.unit_price from po_headers_all pha ,po_lines_all pla 
	 where pha.po_header_id=pla.po_header_id(+)
	 and pha.type_lookup_code='STANDARD'
	 and pha.creation_date>to_date('2017-12-1','YYYY-MM-DD')
	 )t
	 where t.po_line_id is null
	 ;
	 
	select cpph.plan_number,cpph.version_num,cppl.item_id,cppl.line_id,cpph.header_id,cppl.header_id,cppl.quantity,cppl.description
					 from cux_pr_plan_headers cpph,CUX_PR_PLAN_LINES cppl
 where cpph.header_id=cppl.header_id and cpph.plan_number='S201802140'
   and cpph.version_num=3
	 
	 ;