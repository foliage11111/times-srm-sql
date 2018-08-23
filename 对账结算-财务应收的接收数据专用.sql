Select Rt.Transaction_Date    事务处理日期,
       Msib.Segment1          物料编码,
       Msib.Description       物料描述,
       Msib.Primary_Uom_Code  单位,
       Rt.Quantity            数量,
       Pla.unit_price       材料公司采购未税价,
       Rt.Currency_Code       币种,
       pha.segment1           采购订单,
       Hou1.Name              项目公司,
       Cpcv.Project_Name      项目名称,
       Cpcv.Projectblock_Name 项目分期,
       Cpcv.Contract_Name     施工合同,
       Rt.Transaction_Id      后台接收ID,
       Mmt.Transaction_Id     后台事务ID,
       rt.attribute1          接收单号,
       rt.attribute2          接收日期,
       rt.attribute3          接收行号
  From Rcv_Transactions          Rt,
       Mtl_Material_Transactions Mmt,
       Po_Headers_All            Pha,
       Hr_Organization_Units     Hou,
       Po_Lines_All              Pla,
       Hr_Operating_Units        Hou1,
       Cux_Project_Contract_v    Cpcv,
       Mtl_System_Items_b        Msib
 Where 1 = 1
   And Rt.Transaction_Type = 'DELIVER'
   and pla.item_id = Msib.Inventory_Item_Id
   And Rt.Organization_Id = Msib.Organization_Id
   And Mmt.Rcv_Transaction_Id = Rt.Transaction_Id
   And Rt.Po_Header_Id = Pha.Po_Header_Id
   And Pha.Org_Id = Hou.Organization_Id
   And Rt.Po_Header_Id = Pla.Po_Header_Id
   And Rt.Po_Line_Id = Pla.Po_Line_Id
   And Pha.Attribute1 = Hou1.Organization_Id
      -- and pha.segment1 = '2017000043'  --PO编号
   and Hou1.Name in ('珠海顺晟投资有限公司')  -- 项目公司
   And Hou.Attribute13 = 'Y'
   And Pla.Attribute1 = Cpcv.Fprjno(+)
      -- and msib.segment1 = '3101010020000240'   --物理编码
   And Pla.Attribute2 = Cpcv.Fpbno(+)
   And Pla.Attribute3 = Cpcv.Fconid(+)

 order by Rt.Transaction_Date
