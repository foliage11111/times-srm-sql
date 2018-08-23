Select Rt.Transaction_Date    ����������,
       Msib.Segment1          ���ϱ���,
       Msib.Description       ��������,
       Msib.Primary_Uom_Code  ��λ,
       Rt.Quantity            ����,
       Pla.unit_price       ���Ϲ�˾�ɹ�δ˰��,
       Rt.Currency_Code       ����,
       pha.segment1           �ɹ�����,
       Hou1.Name              ��Ŀ��˾,
       Cpcv.Project_Name      ��Ŀ����,
       Cpcv.Projectblock_Name ��Ŀ����,
       Cpcv.Contract_Name     ʩ����ͬ,
       Rt.Transaction_Id      ��̨����ID,
       Mmt.Transaction_Id     ��̨����ID,
       rt.attribute1          ���յ���,
       rt.attribute2          ��������,
       rt.attribute3          �����к�
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
      -- and pha.segment1 = '2017000043'  --PO���
   and Hou1.Name in ('�麣˳��Ͷ�����޹�˾')  -- ��Ŀ��˾
   And Hou.Attribute13 = 'Y'
   And Pla.Attribute1 = Cpcv.Fprjno(+)
      -- and msib.segment1 = '3101010020000240'   --�������
   And Pla.Attribute2 = Cpcv.Fpbno(+)
   And Pla.Attribute3 = Cpcv.Fconid(+)

 order by Rt.Transaction_Date
