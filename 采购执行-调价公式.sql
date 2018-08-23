select pha.po_header_id,pha.segment1,pla.po_line_id,pla.line_num,msib.segment1,msib.inventory_item_status_code,pla.item_id,pla.unit_price,pla.attribute11,pla.expiration_date
 from po_headers_all pha ,po_lines_all pla,mtl_system_items_b msib
  where pha.po_header_id=pla.po_header_id
  and msib.inventory_item_id=pla.item_id
  and msib.organization_id=460
  and pha.segment1='2016000321'---'000078'--2016000172
  --and pla.expiration_date is not null
  and msib.inventory_item_status_code ='Inactive'
  --and msib.segment1='3401010010007105'
  ;
	
	select trv.ten_vendor_status,(Case
                When Trv.Ten_Vendor_Status = 'APPROVED' Then
                 '否'
                Else
                 '是'
              End),trv.* from Cux_Ten_Pre_Vendor_Tmp trv where trv.vendor_name like '%诗尼曼%';
							
							  Select Tpv.Choose
            ,Tpv.Vendor_Name
            ,Tpv.Vendor_Id
            ,Tpv.Contact
            ,Tpv.Tel
            ,Tpv.Email
            ,Flv2.Meaning Vendor_Status_Dsp /*供应商状态*/
            ,Tpv.Evaluation_Score
            ,Tpv.Annual_Turnover /*年营业额*/
            ,Tpv.Remark
            ,Flv3.Meaning Cash_Deposit_Dsp /*需要缴纳保证金*/
            ,Flv1.Meaning Status_Dsp /*状态*/
            ,Flv4.Meaning Invitation_Dsp /*邀请函*/
					,	Tpv.Ten_Vendor_Status
            , (Case
                When Tpv.Ten_Vendor_Status like '%APPROVED%' Then
                 '否'
                Else
                 '是'
              End)
             /*  (CASE
               WHEN tpv.last_update_date >= tt.last_update_date THEN
                '是'
               ELSE
                '否'
             END)*/ Update_Dsp /*是否更新*/
            ,Row_Number() Over(Partition By Tpv.Prequalificate_Id Order By Tpv.Creation_Date) Row_Num
        From Cux.Cux_Ten_Pre_Vendor_Tmp Tpv
            ,Fnd_Lookup_Values_Vl       Flv1
            ,Fnd_Lookup_Values_Vl       Flv2
            ,Fnd_Lookup_Values_Vl       Flv3
            ,Fnd_Lookup_Values_Vl       Flv4
            ,Cux.Cux_Ten_Mat_Trial_Tmp  Tt
            ,Po_Vendors                 Pv
       Where 1 = 1
         And Tt.Prequalificate_Id = Tpv.Prequalificate_Id
         And Tpv.Status = Flv1.Lookup_Code(+)
         And Flv1.Lookup_Type(+) = 'CUX_QUALIFICATION_CHE_G_STATE'
         And Flv1.Enabled_Flag(+) = 'Y'
         And Pv.Vendor_Id = Tpv.Vendor_Id
         And Pv.Attribute3 = Flv2.Lookup_Code(+)
         And Flv2.Lookup_Type(+) = 'CUX_VENDOR_STATUS'
         And Flv2.Enabled_Flag(+) = 'Y'
         And Tpv.Need_Pay_Margin = Flv3.Lookup_Code(+)
         And Flv3.Lookup_Type(+) = 'CUX_PAYMENT_CASH_DEPOSIT'
         And Flv3.Enabled_Flag(+) = 'Y'
         And Tpv.Invitation_Confirm = Flv4.Lookup_Code(+)
         And Flv4.Lookup_Type(+) = 'CUX_QUA_CHE_INVITATION'
         And Flv4.Enabled_Flag(+) = 'Y'
         And Nvl(Tpv.Choose
                ,'Y') = 'Y'
         And Tpv.Prequalificate_Id = 5805
				 ;
				 
	select * from cux_ten_time_control_tmp ;
  
  select trunc(pla.expiration_date),pla.expiration_date,pla.* from po_lines_all pla where pla.expiration_date is not null;
  
  update po_lines_all pla set pla.expiration_date=trunc(pla.expiration_date) where pla.expiration_date is not null  ;
  
  cux_wf_html_pkg
  
  --INVENTORY_ITEM_STATUS_CODE_MIR
  select  msib.inventory_item_status_code,msib.* from mtl_system_items_b msib where msib.segment1='1199010030000002'
  


select * from srm_po_file_t t where t.fheader_id in (select t1.header_id
from cux_pr_plan_headers t1 where t1.plan_number='S201803163')