 /*物料审批*/
  Function cuxinvitem_html(p_Source_Header_Id In Number) Return Varchar2 Is
    v_Document Varchar2(32767) := '';
    Nl         Varchar2(1) := Fnd_Global.Newline; --换行
    
    v_business_type varchar2(150);
    v_attr_flag1    varchar2(50);
    v_attr_flag2    varchar2(50);
    v_attr_flag3    varchar2(50);
    v_attr_flag4    varchar2(50);
    v_attr_flag5    varchar2(50);
    v_attr_flag6    varchar2(50);
    v_attr_flag7    varchar2(50);
    v_attr_flag8    varchar2(50);
    v_attr_flag9    varchar2(50);
    v_attr_flag10    varchar2(50);
    v_attr_flag      varchar2(50);
    v_forth_class_code   varchar2(50);
    v_intf_id    Number := 0;

    Cursor csr_items_attr(l_Source_Header_Id In Number) Is--2018-01-24游标查询属性名称信息
      SELECT mce.intf_id
      ,mce.element_type
      ,mce.first_class_code
      ,mce.first_class_desc
      ,mce.second_class_code
      ,mce.second_class_desc
      ,mce.third_class_code
      ,mce.third_class_desc
      ,mce.forth_class_code
      ,mce.forth_class_desc
      ,mce.item_uom
      ,mce.mtl_attribute4
      ,mce.category_group_name
      ,mce.attr_name1
      ,mce.attr_name2
      ,mce.attr_name3
      ,mce.attr_name4
      ,mce.attr_name5
      ,mce.attr_name6
      ,mce.attr_name7
      ,mce.attr_name8
      ,mce.attr_name9
      ,mce.attr_name10
      ,mce.attr_name11
      ,mce.attr_name12
      ,mce.attr_name13
      ,mce.attr_name14
      ,mce.attr_name15
      ,mce.attr_name16
      ,mce.attr_name17
      ,mce.attr_name18
      ,mce.attr_name19
      ,mce.attr_name20
      ,mce.attr_name21
      ,mce.attr_name22
      ,mce.attr_name23
      ,mce.attr_name24
      ,mce.attr_name25
      ,mce.attr_name26
      ,mce.attr_name27
      ,mce.attr_name28
      ,mce.attr_name29
      ,mce.attr_name30
  FROM scux_mtl_catalog_element_temp mce
 WHERE mce.intf_batch_id = l_Source_Header_Id
 and mce.element_type is null
 and (mce.attr_name1 is not null or mce.attr_name2 is not null
 or mce.attr_name3 is not null or mce.attr_name4 is not null
 or mce.attr_name5 is not null or mce.attr_name6 is not null
 or mce.attr_name7 is not null)
 order by mce.intf_id;

    Cursor csr_items(l_Source_Header_Id In Number) Is
      SELECT mce.intf_id
      ,mce.element_type
      ,mce.first_class_code
      ,mce.first_class_desc
      ,mce.second_class_code
      ,mce.second_class_desc
      ,mce.third_class_code
      ,mce.third_class_desc
      ,mce.forth_class_code
      ,mce.forth_class_desc
      ,mce.item_uom
      ,mce.mtl_attribute4
      ,mce.category_group_name
      ,mce.attr_name1
      ,mce.attr_name2
      ,mce.attr_name3
      ,mce.attr_name4
      ,mce.attr_name5
      ,mce.attr_name6
      ,mce.attr_name7
      ,mce.attr_name8
      ,mce.attr_name9
      ,mce.attr_name10
      ,mce.attr_name11
      ,mce.attr_name12
      ,mce.attr_name13
      ,mce.attr_name14
      ,mce.attr_name15
      ,mce.attr_name16
      ,mce.attr_name17
      ,mce.attr_name18
      ,mce.attr_name19
      ,mce.attr_name20
      ,mce.attr_name21
      ,mce.attr_name22
      ,mce.attr_name23
      ,mce.attr_name24
      ,mce.attr_name25
      ,mce.attr_name26
      ,mce.attr_name27
      ,mce.attr_name28
      ,mce.attr_name29
      ,mce.attr_name30
  FROM scux_mtl_catalog_element_temp mce
 WHERE mce.intf_batch_id = l_Source_Header_Id
 and mce.element_type is not null
 order by mce.intf_id;/*2018-01-11物料审批表单有很多空数据，通过排序把有数据的显示在前面*/
  
    Cursor csr_projects(l_Source_Header_Id In Number) Is
SELECT pmt.first_class_code
      ,pmt.first_class_desc
      ,pmt.second_class_code
      ,pmt.second_class_desc
      ,pmt.third_class_code
      ,pmt.third_class_desc
      ,pmt.forth_class_code
      ,pmt.forth_class_desc
      ,pmt.item_code
      ,pmt.item_uom
      ,pmt.project_name
      ,pmt.project_characteristics
      ,pmt.counting_rules
      ,pmt.supply_type_name
      ,pmt.advocate_material_fee
      ,pmt.sup_material_fee
      ,pmt.artificial_cost
      ,pmt.machine_fee
      ,pmt.indirect_costs
  FROM scux_project_mtl_temp pmt
 WHERE pmt.intf_batch_id = l_source_header_id;
 
  Begin
    
  SELECT ibr.attribute1
    INTO v_business_type
    FROM cux_inv_batch_records ibr
   WHERE ibr.source_id = p_Source_Header_Id
     AND ibr.source_type = 'CUXINVITEM';
    
      v_Document := '<br>';
    
      if v_business_type = 'MATERIAL' then
        
      v_Document := v_Document ||
                    '<TABLE style="TEXT-ALIGN: left; WIDTH: 800px; BORDER-COLLAPSE: collapse;LINE-HEIGHT: 150%; FONT-FAMILY: 宋体; COLOR: black; FONT-SIZE: 9pt; mso-bidi-font-family: 宋体; mso-ansi-language: EN-US; mso-fareast-language: ZH-CN; mso-bidi-language: AR-SA"" border="1" cellSpacing="2" borderColor="black" cellPadding="3" bgColor="#ffffff" align="center">' || Nl;
      v_Document := v_Document || '<colgroup>' || Nl;
      v_Document := v_Document || '<col width="30px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="20px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '</colgroup>' || Nl;
      v_Document := v_Document || '<TBODY>' || Nl;
      v_Document := v_Document || '<TR>' || Nl;
      
      v_Document := v_Document ||
                    '<TD colSpan=16 align=middle><SPAN style="LINE-HEIGHT: 150%; FONT-FAMILY: 宋体; COLOR: black; FONT-SIZE: 20pt; mso-bidi-font-family: 宋体; mso-ansi-language: EN-US; mso-fareast-language: ZH-CN; mso-bidi-language: AR-SA"><STRONG><FONT style="FONT-SIZE: 20px">' ||
                    '物料新增审批' ||
                    '</FONT></STRONG></SPAN></TD></TR>' || Nl;
      
      v_Document := v_Document || '<TR>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1 rowspan="2"><STRONG>类型</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1 rowspan="2"><STRONG>一级分类</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1 rowspan="2"><STRONG>二级分类</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1 rowspan="2"><STRONG>三级分类</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1 rowspan="2"><STRONG>四级分类</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1 rowspan="2"><STRONG>单位(*)</STRONG></TD>' || Nl;
      v_Document := v_Document || '<TD style="text-align:center" colspan="10"><STRONG>红色字体标识为关键属性，黑色的为供应商属性</STRONG></TD></TR>' || Nl;
      v_Document := v_Document || '<TR>' || Nl;
    
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>属性名1</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>属性名2</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>属性名3</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>属性名4</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>属性名5</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>属性名6</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>属性名7</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>属性名8</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>属性名9</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>属性名10</STRONG></TD></TR>' || Nl;
    
      For Rec_Items In csr_items(p_Source_Header_Id)
      Loop
          
          For Rec_Items_Attr In csr_items_attr(p_Source_Header_Id)
          Loop
      
        If Lengthb(v_Document) >= 20000
        Then
          Exit;
        End If;
        --2018-01-24对所属分类下的属性名称进行关键属性与供应商属性的区分，关键属性用红色字体标识
        if (Rec_Items.Element_Type='分类' and Rec_Items.intf_id+1=Rec_Items_Attr.Intf_Id) then
          v_attr_flag1 :=Rec_Items.Attr_Name1;
          v_attr_flag2 :=Rec_Items.Attr_Name2;
          v_attr_flag3 :=Rec_Items.Attr_Name3;
          v_attr_flag4 :=Rec_Items.Attr_Name4;
          v_attr_flag5 :=Rec_Items.Attr_Name5;
          v_attr_flag6 :=Rec_Items.Attr_Name6;
          v_attr_flag7 :=Rec_Items.Attr_Name7;
          v_attr_flag8 :=Rec_Items.Attr_Name8;
          v_attr_flag9 :=Rec_Items.Attr_Name9;
          v_attr_flag10:=Rec_Items.Attr_Name10;
          Rec_Items.Attr_Name1 :=null;
          Rec_Items.Attr_Name2 :=null;
          Rec_Items.Attr_Name3 :=null;
          Rec_Items.Attr_Name4 :=null;
          Rec_Items.Attr_Name5 :=null;
          Rec_Items.Attr_Name6 :=null;
          Rec_Items.Attr_Name7 :=null;
          Rec_Items.Attr_Name8 :=null;
          Rec_Items.Attr_Name9 :=null;
          Rec_Items.Attr_Name10:=null;
            if upper(v_attr_flag1)='Y' then
                Rec_Items.Attr_Name1 := '<font color="red">'||Rec_Items_Attr.Attr_Name1||'</font>';
            elsif upper(v_attr_flag1)='N' then
                Rec_Items.Attr_Name1 := Rec_Items_Attr.Attr_Name1;
            End If;
            if upper(v_attr_flag2)='Y' then
                Rec_Items.Attr_Name2 := '<font color="red">'||Rec_Items_Attr.Attr_Name2||'</font>';
            elsif upper(v_attr_flag2)='N' then
                Rec_Items.Attr_Name2 := Rec_Items_Attr.Attr_Name2;
            End If;
            if upper(v_attr_flag3)='Y' then
                Rec_Items.Attr_Name3 := '<font color="red">'||Rec_Items_Attr.Attr_Name3||'</font>';
            elsif upper(v_attr_flag3)='N' then
                Rec_Items.Attr_Name3 := Rec_Items_Attr.Attr_Name3;
            End If;
            if upper(v_attr_flag4)='Y' then
                Rec_Items.Attr_Name4 := '<font color="red">'||Rec_Items_Attr.Attr_Name4||'</font>';
            elsif upper(v_attr_flag4)='N' then
                Rec_Items.Attr_Name4 := Rec_Items_Attr.Attr_Name4;
            End If;
            if upper(v_attr_flag5)='Y' then
                Rec_Items.Attr_Name5 := '<font color="red">'||Rec_Items_Attr.Attr_Name5||'</font>';
            elsif upper(v_attr_flag5)='N' then
                Rec_Items.Attr_Name5 := Rec_Items_Attr.Attr_Name5;
            End If;
            if upper(v_attr_flag6)='Y' then
                Rec_Items.Attr_Name6 := '<font color="red">'||Rec_Items_Attr.Attr_Name6||'</font>';
            elsif upper(v_attr_flag6)='N' then
                Rec_Items.Attr_Name6 := Rec_Items_Attr.Attr_Name6;
            End If;
            if upper(v_attr_flag7)='Y' then
                Rec_Items.Attr_Name7 := '<font color="red">'||Rec_Items_Attr.Attr_Name7||'</font>';
            elsif upper(v_attr_flag7)='N' then
                Rec_Items.Attr_Name7 := Rec_Items_Attr.Attr_Name7;
            End If;
            if upper(v_attr_flag8)='Y' then
                Rec_Items.Attr_Name8 := '<font color="red">'||Rec_Items_Attr.Attr_Name8||'</font>';
            elsif upper(v_attr_flag8)='N' then
                Rec_Items.Attr_Name8 := Rec_Items_Attr.Attr_Name8;
            End If;
            if upper(v_attr_flag9)='Y' then
                Rec_Items.Attr_Name9 := '<font color="red">'||Rec_Items_Attr.Attr_Name9||'</font>';
            elsif upper(v_attr_flag9)='N' then
                Rec_Items.Attr_Name9 := Rec_Items_Attr.Attr_Name9;
            End If;
            if upper(v_attr_flag10)='Y' then
                Rec_Items.Attr_Name10 := '<font color="red">'||Rec_Items_Attr.Attr_Name10||'</font>';
            elsif upper(v_attr_flag10)='N' then
                Rec_Items.Attr_Name10 := Rec_Items_Attr.Attr_Name10;
            End If;
            v_forth_class_code := Rec_Items.Forth_Class_Code;
        elsif (Rec_Items.Element_Type='分类' and Rec_Items.intf_id+1!=Rec_Items_Attr.Intf_Id) then
          continue;
        elsif (Rec_Items.Element_Type='物料' and v_forth_class_code != Rec_Items.Forth_Class_Code) then
          continue;
        elsif (Rec_Items.Element_Type='物料' and v_forth_class_code = Rec_Items.Forth_Class_Code 
          and v_intf_id=Rec_Items.intf_id) then
          continue;
        elsif (Rec_Items.Element_Type='物料' and v_forth_class_code = Rec_Items.Forth_Class_Code 
          and v_intf_id!=Rec_Items.intf_id) then
          v_intf_id := Rec_Items.intf_id;
        End If;
        
        v_Document := v_Document || '<TR>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Element_Type || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.First_Class_Desc || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Second_Class_Desc || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Third_Class_Desc || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Forth_Class_Desc || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Item_Uom || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Attr_Name1 || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Attr_Name2 || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Attr_Name3 || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Attr_Name4 || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Attr_Name5 || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Attr_Name6 || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Attr_Name7 || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Attr_Name8 || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Attr_Name9 || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Attr_Name10 || '</TD></TR>' || Nl;
         End Loop;
      End Loop;
    
      v_Document := v_Document || ' </table>';
      
      elsif v_business_type = 'ENGINEERING' then
        
        
      v_Document := v_Document ||
                    '<TABLE style="TEXT-ALIGN: left; WIDTH: 800px; BORDER-COLLAPSE: collapse;LINE-HEIGHT: 150%; FONT-FAMILY: 宋体; COLOR: black; FONT-SIZE: 9pt; mso-bidi-font-family: 宋体; mso-ansi-language: EN-US; mso-fareast-language: ZH-CN; mso-bidi-language: AR-SA"" border="1" cellSpacing="2" borderColor="black" cellPadding="3" bgColor="#ffffff" align="center">' || Nl;
      v_Document := v_Document || '<colgroup>' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="100px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="150px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '<col width="50px" />' || Nl;
      v_Document := v_Document || '</colgroup>' || Nl;
      v_Document := v_Document || '<TBODY>' || Nl;
      v_Document := v_Document || '<TR>' || Nl;
      
      v_Document := v_Document ||
                    '<TD colSpan=16 align=middle><SPAN style="LINE-HEIGHT: 150%; FONT-FAMILY: 宋体; COLOR: black; FONT-SIZE: 20pt; mso-bidi-font-family: 宋体; mso-ansi-language: EN-US; mso-fareast-language: ZH-CN; mso-bidi-language: AR-SA"><STRONG><FONT style="FONT-SIZE: 20px">' ||
                    '物料审批' ||
                    '</FONT></STRONG></SPAN></TD></TR>' || Nl;
    
      v_Document := v_Document || '<TR>' || Nl;
    
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>一级分类</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>二级分类</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>三级分类</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>四级分类</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>物料编码</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>单位(*)</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>工程项名称</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>供应方式</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>主材费</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>辅材费</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>人工费</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>机械费</STRONG></TD>' || Nl;
      v_Document := v_Document ||
                    '<TD style="text-align:center" colSpan=1><STRONG>间接费</STRONG></TD></TR>' || Nl;
    
      For Rec_Items In csr_projects(p_Source_Header_Id)
      Loop
      
        If Lengthb(v_Document) >= 20000
        Then
          Exit;
        End If;
      
        v_Document := v_Document || '<TR>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.First_Class_Desc || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Second_Class_Desc || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Third_Class_Desc || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Forth_Class_Desc || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Item_Code || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Item_Uom || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Project_Name || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Supply_Type_Name || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Advocate_Material_Fee || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Sup_Material_Fee || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Artificial_Cost || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Machine_Fee || '</TD>' || Nl;
      
        v_Document := v_Document ||
                      '<TD style="text-align:center" colSpan=1>' ||
                      Rec_Items.Indirect_Costs || '</TD></TR>' || Nl;
      
      End Loop;
    
      v_Document := v_Document || ' </table>';
      end if;
    
    Return v_Document;
  End;
  
  