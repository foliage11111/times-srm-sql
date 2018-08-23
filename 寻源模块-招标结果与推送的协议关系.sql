 
 --如果是分类问题，通过item_class_all这个值集看下分类是否分好工程和材料
-- 要先确定物料是否正常生成，可以跑请求"%定标物料%"来生成物料，对应程序包cux_tender_item_import_pkg.item_import

--然后后台更新协议签订表中对应行的物料信息 ，对应的表cux.cux_ten_agr_information_tmp

--然后重推协议，cux_tender_po_purchase_pkg(材料和工程分别是不同方法)
 
 
    
       --  cux_tender_item_import_pkg 
  select * from cux.cux_pon_bidding_plan t where t.plan_number = 'ZB2017019';
   
 --select * FROM cux_gateway_material_quote;
 
      SELECT cii.category_id
            , --类别id
             cii.category_number
            ,cii.category_name description
          -- ,msib.inventory_item_id item_id
            ,cux_tender_item_import_pkg.get_item_des(cii.material_quote_id) long_description
            ,cii.material_id
            , --物料描述
             cii.unit
            , --单位
             cii.material_quote_id
            ,
             /* cii.category_name*/(SELECT mcv.attribute1
                FROM mtl_categories_v mcv
               WHERE mcv.category_concat_segs =
                     cii.category_number
                 AND rownum = 1) item_catalog_group_id /*item_catalog_group_name*/
            , --目录组名ID
             cii.category_number category_concat_segs
            , --类别编号
             cii.detail
            , --报价属性
             cii.attribute2 --导入标识
            ,cgp.vendor_id
            ,cii.attribute9
        FROM cux_gateway_material_quote cii
            ,cux_gateway_project_base   cgp
           --  ,mtl_system_items_tl msib
       WHERE 1 = 1
            -- and msib.long_description=cux_tender_item_import_pkg.get_item_des(cii.material_quote_id)
            --  and msib.organization_id=460
         AND cii.project_base_id = cgp.project_base_id
         AND cgp.status = 'SUBMITTED' --已提交
         AND NOT EXISTS
       (SELECT 1
                FROM cux_ten_time_control_tmp ctt
               WHERE ctt.tender_book_id = cgp.tender_book_id
                 AND (ctt.status = 'DRAFT' OR ctt.status = 'OVER'))
         AND EXISTS
       (SELECT 1
                FROM cux_ten_pro_information_tmp tpi
                    ,cux_ten_mat_result_tmp      tmr
               WHERE tmr.award_info_id = tpi.award_info_id
                 AND tpi.plan_id = cgp.plan_id
                 AND cgp.vendor_id = tmr.vendor_id
                 AND tmr.award_choose = 'true')
         AND (cii.material_id IS NULL OR cii.material_number IS NULL)
         
         AND cgp.plan_id = 2003;
          
         
				--然后后台更新协议签订表中对应行的物料信息 ，对应的表cux.cux_ten_agr_information_tmp
         
         SELECT * FROM cux.cux_ten_agr_information_tmp CTAI WHERE CTAI.Win_Id=504 for UPDATE;
         
         
         select * from CUX.Cux_Ten_Agr_Result_Tmp ctar where ctar.plan_id=2003 ;
         
         --select * from org_organization_definitions ood where ood.ORGANIZATION_NAME like '%主%' --460
         
         --这里物料超级难找--基本没有关联关系，实际物料的长描述也可能不一致，暂时没有找到关联关系
         --3014020130000002   --隐藏水箱及面板||科勒|K-6286T-NA/K-8854T-CP|塑料|白色    --173341
         --3014050070000004   --拖把盆龙头||科勒|K-13901T-B4-CP|全铜|镀铬    --173340
         
        -- select  * from cux_ten_agr_protocol_tmp ctap where ctap.plan_id=2003;
         
         SELECT * FROM cux_ten_mat_create_tmp ctmc WHERE CTMC.AGREEMENT_NUMBER='2017090009'; --包里面写是要这个表的agreement_ID
   
          --然后重推协议，cux_tender_po_purchase_pkg(材料和工程分别是不同方法)
          -- 这个调用的参数是个 agreement_id，但是不是po_header_id ，也不是什么 protcol_id
          
          DECLARE

  RECEPT_ID NUMBER;
   x_return_code  VARCHAR2(2000);
    x_return_msg   VARCHAR2(2000);
BEGIN
 

cux_tender_po_purchase_pkg.purchase_import(447,x_return_code,x_return_msg);

 
END;