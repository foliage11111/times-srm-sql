
 ---sql
  ----计划里没有了，系统里还有，有订单，但是计划没匹配上
select cpph.plan_number,
       cpph.plan_name,
       cpph.plan_status,
       cppl.item_id,
       cppl.quantity,
       cppl.unit_price     tax_price,
       cppl.description,
       po.unit_price       untax_price,
       po.item_description,
       po.segment1
  from CUX_PR_PLAN_HEADERS cpph,
       cux_pr_plan_lines cppl,
       (select pla.item_id,
               pla.quantity,
               pla.unit_price,
               pla.item_description,
               pha.segment1
          from po.po_lines_all pla, po.po_headers_all pha
         where pla.po_header_id = pha.po_header_id
           and pha.segment1 = '2017000846'
          ) po
 where cpph.header_id = cppl.header_id
   and cppl.item_id (+)= po.item_id
   and cppl.quantity (+)= po.quantity
	 ;
	 
	 select pha.segment1,pha.po_header_id from po_headers_all pha where pha.po_header_id in(125148,125149,125150)
	 
	 
	 ;
	 
	----
	 select cpph.b$plan_number,
       cpph.b$plan_name,
       cpph.fuser_id,
       cpph.fuser_name,
       cpph.action,                  
       cpph.b$plan_status,
			 cpph.b$plan_type,
			 cpph.b$creation_date,
			 cpph.b$last_update_date,
			 cpph.b$version_num,
       cppl.b$item_id,
       cppl.b$quantity,
       cppl.b$unit_price     tax_price,
       cppl.b$description,
       po.unit_price       untax_price,
       po.item_description,
       po.segment1
  from aud.aud$CUX_PR_PLAN_HEADERS cpph,
       aud.aud$cux_pr_plan_lines cppl,
       (select pla.item_id,
               pla.quantity,
               pla.unit_price,
               pla.item_description,
               pha.segment1
          from po.po_lines_all pla, po.po_headers_all pha
         where pla.po_header_id = pha.po_header_id
           and pha.segment1 = '2018000124'
          ) po
 where cpph.b$header_id = cppl.b$header_id
   and cppl.b$item_id (+)= po.item_id
   and cppl.b$quantity (+)= po.quantity;
	 
	 
	 
	 ---计划里面没有，订单也空了
	     --127089,127088,119202
	select --pha.b$segment1,
	             pla.b$po_header_id,
	              pla.b$po_line_id,
	               pla.b$item_id,
               pla.b$quantity,
               pla.b$unit_price,
               pla.b$item_description,
               pp.*
          from aud.aud$po_lines_all pla,
					--aud.aud$po_headers_all pha,
					(select cpph.plan_number,cpph.version_num,cppl.item_id,cppl.line_id,cppl.quantity,cppl.description from cux_pr_plan_headers cpph,CUX_PR_PLAN_LINES cppl
 where cpph.header_id=cppl.header_id and cpph.plan_number='S201803180'
   and cpph.version_num=2
	) pp
         where --pla.b$po_header_id = pha.b$po_header_id
				   pp.item_id=pla.b$item_id(+)
				 and pp.quantity=pla.b$quantity(+)
	 ;
	 
	 
	 SELECT pohi.po_header_id
                       ,poli.process_code
                       ,poli.po_line_id
                       ,poli.line_attribute5
                       ,pohi.attribute9
											 ,poli.line_num
											 ,poli.quantity
											 ,poli.unit_price
											 ,poli.line_attribute10
											 ,poli.creation_date
                       ,pohi.from_header_id
											 ,pohi.interface_source_code
											 ,pohi.batch_id
                   FROM po_headers_interface pohi
                       ,po_lines_interface   poli
                  WHERE pohi.interface_header_id = poli.interface_header_id
                   -- AND pohi.batch_id = l_batch_id
									  and pohi.po_header_id=125148
								--	and poli.item_id=21962
								--	and poli.quantity=100
                    AND pohi.interface_source_code IN
                        ('INSPECTION_PLAN'
                        ,'ADDITIONAL_PLAN'
                        ,'PR_PLAN')
												
												;
												 cux_pr_demand_plan_pkg
												 
												 
												 select * from cux_po_lines_all cpla where cpla.po_header_id in (125148,125149,125150);
												 select * from po_line_locations_all plla where plla.po_header_id in (125148,125149,125150);
								
				insert into po_lines_all				select b.* from 				 
		( select cpph.plan_number,
		        cpph.version_num,
       cpph.plan_name,
       cpph.plan_status,
			 cppl.header_id,
			 cppl.line_id，
			 cppl.last_update_date,
       cppl.item_id,
       cppl.quantity,
			 cppl.need_by_date,
       cppl.unit_price     tax_price,
			 round(cppl.unit_price/1.17 ,4)    untax_price,
       cppl.description
     
  from CUX_PR_PLAN_HEADERS cpph,
       cux_pr_plan_lines cppl
		where cpph.header_id = cppl.header_id
		and cpph.plan_number='S201802140'
		and cpph.version_num=3
		) a,
		(  select *--cpla.po_header_id,cpla.attribute5,cpla.line_num, cpla.item_id,cpla.quantity,cpla.unit_price 
		from cux_po_lines_all cpla where cpla.po_header_id in (125148,125149,125150) )
		b
		where 
		a.item_id=b.item_id
		and a.quantity=b.quantity
		
		;
		
				update po_lines_all		pla set (pla.quantity,pla.attribute5)=
				(select t.quantity,t.line_id from  
				(select a.quantity,a.line_id,b.attribute5 from			 
		( select cpph.plan_number,
		        cpph.version_num,
       cpph.plan_name,
       cpph.plan_status,
			 cppl.header_id,
			 cppl.line_id，
			 cppl.last_update_date,
       cppl.item_id,
       cppl.quantity,
			 cppl.need_by_date,
       cppl.unit_price     tax_price,
			 round(cppl.unit_price/1.17 ,4)    untax_price,
       cppl.description
     
  from CUX_PR_PLAN_HEADERS cpph,
       cux_pr_plan_lines cppl
		where cpph.header_id = cppl.header_id
		and cpph.plan_number='S201802140'
		and cpph.version_num=3
		) a,
		(  select *--cpla.po_header_id,cpla.attribute5,cpla.line_num, cpla.item_id,cpla.quantity,cpla.unit_price 
		from cux_po_lines_all cpla where cpla.po_header_id in (125148,125149,125150) )
		b
		where 
		a.item_id=b.item_id
		and a.quantity=b.quantity
		) t where
		t.attribute5=pla.attribute5
		)
		where pla.po_header_id in (125148,125149,125150)
		
		;
		
		
		
		
		
		
		select * from po_headers_all pha where pha.po_header_id=125148;
	 
	 	select b.* from 				 
		( select cpph.plan_number,
		        cpph.version_num,
       cpph.plan_name,
       cpph.plan_status,
			 cppl.header_id,
			 cppl.line_id，
			 
       cppl.item_id,
       cppl.quantity,
			 cppl.need_by_date,
       cppl.unit_price     tax_price,
       cppl.description
     
  from CUX_PR_PLAN_HEADERS cpph,
       cux_pr_plan_lines cppl
		where cpph.header_id = cppl.header_id
		and cpph.plan_number='S201802140'
		and cpph.version_num=2 
		) a,
		( select cpph.plan_number,
		        cpph.version_num,
       cpph.plan_name,
       cpph.plan_status,
			 cppl.header_id,
			 cppl.line_id，
       cppl.item_id,
       cppl.quantity,
			 cppl.need_by_date,
       cppl.unit_price     tax_price,
       cppl.description
     
  from CUX_PR_PLAN_HEADERS cpph,
       cux_pr_plan_lines cppl
		where cpph.header_id = cppl.header_id
		and cpph.plan_number='S201802140'
		and cpph.version_num=1)
		b
		where 
		a.item_id=b.item_id
		and a.quantity=b.quantity
		;
		
		
												 