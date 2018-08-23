PL/SQL Developer Test script 3.0
56

Declare

  --l_Po_Header_Id         Number := &PO_header_id;

  l_Authorization_Status Varchar2(50);
  l_Return_Status        Varchar2(50);
  l_Exception_Msg        Varchar2(2000);
  l_Po_Header_Id         Number ;
  l_Po_segment           Varchar2(50) := '2018001054';       


Begin

  Begin

    Select nvl(t.Authorization_Status,'INCOMPLETE'), t.Po_Header_Id
      Into l_Authorization_Status,l_Po_Header_Id
      From Po_Headers_All  t
     Where t.segment1 = l_Po_segment;
  Exception
    When Others Then
      l_Authorization_Status := Null;
  End;

  Dbms_Output.Put_Line('l_Authorization_Status:' || l_Authorization_Status);

  If l_Authorization_Status <> 'APPROVED'

  Then
    -- Call the procedure
    Po_Document_Action_Pvt.Do_Approve(p_Document_Id      => l_Po_Header_Id
                                     ,p_Document_Type    => 'PA'
                                    ,p_Document_Subtype => 'BLANKET'
                                     ,p_Note             => l_Po_Header_Id || ' Approved'
                                     ,p_Approval_Path_Id => 1
                                     ,x_Return_Status    => l_Return_Status
                                     ,x_Exception_Msg    => l_Exception_Msg);

    --Dbms_Output.Put_Line('l_Return_Status:' || l_Return_Status);

    If l_Return_Status <> 'S'
    Then
      Dbms_Output.Put_Line('Error Status = ' || l_Return_Status ||
                           ',l_exception_msg:' || l_Exception_Msg);
    End If;
  If l_Return_Status = 'S'
 then
    Dbms_Output.Put_Line('l_Authorization_Status : S ' || l_Po_segment);
     end if;
  End If;

End;



0
0
