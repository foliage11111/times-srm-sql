Declare
  l_Matprice_Fbomlistid  Number;
  l_Matprice_Fprdid      Number;
  l_Matprice_Fbomorderid Number;
  l_Bom_Persion_Id       Number;
  l_Bom_org_Id           Number;
  l_Bom_Position_Id      Number;
  l_bom_FHCONTID         number;
  l_Matprice_Fbomid      Number := 2005;
  l_Matprice_Fnumber     Varchar2(20) := '31.01.02';
  l_Matprice_Amount      Number := 2917865.54;
  l_Bom_Persion_Name     Varchar2(20) := '余家珍';
  l_bom_org_name         Varchar2(90) := '时代水岸（佛山）项目部(10093)';
  l_bom_Position_name    Varchar2(90) := '泌冲合同录入员';
  l_contract_fnumber     Varchar2(90) := 'fs01.MXX2.01-土建工程类-2016-0003';

Begin

  --fnd_standard.set_who;

  Select Paa.Person_Id, hou.organization_id, paa.Position_Id
    Into l_Bom_Persion_Id, l_Bom_org_Id, l_Bom_Position_Id
    From Hr_Organization_Units_v Hou,
         Per_All_Assignments_f   Paa,
         Per_People_f            Ppf,
         Hr_All_Positions_f      Hr
   Where Hou.Organization_Id = Paa.Organization_Id
     And Paa.Person_Id = Ppf.Person_Id
     And Paa.Position_Id = Hr.Position_Id
     And Paa.Position_Id Is Not Null
     And Paa.Effective_Start_Date <= Sysdate
     And Paa.Effective_End_Date >= Sysdate
     And Hr.Effective_Start_Date <= Sysdate
     And Hr.Effective_End_Date >= Sysdate
     And Ppf.First_Name || Ppf.Last_Name = l_Bom_Persion_Name
     and hr.name = l_bom_Position_name
     and hou.name = l_bom_org_name
     And Rownum = 1;

--修改经办人

  Update Wpc_Bom_t
     Set Foperator   = l_Bom_Persion_Id,
         fdeptid     = l_Bom_org_Id,
         fpositionid = l_Bom_Position_Id
   Where Fbomid = l_Matprice_Fbomid;

--关联合同起草

  select FHCONTID
    into l_bom_FHCONTID
    from Wpc_Bom_t
   Where Fbomid = l_Matprice_Fbomid;

  update wpc.wpc_contract_t t
     set t.fbomid = l_Matprice_Fbomid, t.FHCONTID = l_bom_FHCONTID
   where t.fnumber = l_contract_fnumber;

----插入控价-材料清单

    If l_Matprice_Fbomlistid Is Null
    Then
      Select Wpc_Bomlist_s.Nextval Into l_Matprice_Fbomlistid From Sys.Dual;
    End If;
  
    Select Fprdid
      Into l_Matprice_Fprdid
      From Wpc.Wbd_Material_t t
     Where Fnumber = l_Matprice_Fnumber;
  
    Select Fbomorderid
      Into l_Matprice_Fbomorderid
      From Wpc_Bomorder_t
     Where Fbomid = l_Matprice_Fbomid;
  
  
  
    Insert Into Wpc_Bomlist_t
      (Fbomlistid
      ,Fbomid
      ,Fprdid
      ,Ftype
      ,Fquantity)
    Values
      (l_Matprice_Fbomlistid
      ,l_Matprice_Fbomid
      ,l_Matprice_Fprdid
      ,2
      ,0);

#NAME?
    Insert Into Wpc_Bomorderlist_t
      (Fbomorderid
      ,Fbomid
      ,Fbomlistid
      ,Fquantity)
    Values
      (l_Matprice_Fbomorderid
      ,l_Matprice_Fbomid
      ,l_Matprice_Fbomlistid
      ,l_Matprice_Amount);


  -- Commit;
End Insert_Row;
