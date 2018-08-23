DECLARE
  L_ITEM_REC              INV_ITEM_GRP.ITEM_REC_TYPE;
  X_ERROR_TBL             INV_ITEM_GRP.ERROR_TBL_TYPE;
  X_ITEM_REC              INV_ITEM_GRP.ITEM_REC_TYPE;
  X_RETURN_STATUS         VARCHAR2(10);
  X_RETURN_STATUS2        VARCHAR2(10);
  X_MSG_COUNT             NUMBER;
  X_MSG_DATA              VARCHAR2(4000);
  L_ERRORCODE             VARCHAR2(100);
  L_OLD_CATEGORY_ID       NUMBER;
  V_ITEM_CATALOG_GROUP_ID NUMBER; --����Ŀ¼��ID
  V_ORGANIZATION_ID       NUMBER; --�����֯ID
  V_CATEGORY_ID           NUMBER; --�������ID
  V_ITEM_ID               NUMBER;
  V_SET_PRCS_ID           NUMBER;
  L_ELEMENT_SEQUENCE      NUMBER;
  L_PRIMARY_UOM_CODE      VARCHAR2(100);
  X_ERRBUF                VARCHAR2(4000);
  X_RETCODE               VARCHAR2(4000);
  CURSOR CSR_ITEM IS
    SELECT DISTINCT CIIT.TEMPLATE_NAME,
                    CIIT.ORGANIZATION_NAME, --�����֯�� 
                    CIIT.SEGMENT1, --���ϱ���
                    CIIT.DESCRIPTION, --��������
                    CIIT.PRIMARY_UOM_CODE, --��λ
                    CIIT.ITEM_CATALOG_GROUP_NAME, --Ŀ¼����
                    CIIT.LONG_DESCRIPTION,
                    CIIT.CATEGORY_CONCAT_SEGS, --���
                    CIIT.IMPORT_FLAG, --�����ʶ
                    CIIT.CUQUAN --��ͭ��
      FROM cux_inv_item_engineer_template CIIT
     WHERE 1 = 1
       AND (CIIT.IMPORT_FLAG IS NULL OR CIIT.IMPORT_FLAG='U');

  /*cursor csr_item1(p_item_code IN VARCHAR2) is
    select cii.element_value1,
           cii.element_value2,
           cii.element_value3,
           cii.element_value4,
           cii.element_value5
      from cux_inv_item_engineer_template cii
     where cii.segment1 =p_item_code;*/

  /* --�����֯�α�
  cursor csr_org is
    select ood.ORGANIZATION_ID, ood.ORGANIZATION_NAME
      from org_organization_definitions ood
     where ood.ORGANIZATION_CODE = 'MST'
    union all
    select ood.ORGANIZATION_ID, ood.ORGANIZATION_NAME
      from org_organization_definitions ood
     where ood.ORGANIZATION_CODE <> 'MST';*/

BEGIN
  L_ELEMENT_SEQUENCE := 0;
  --��ʼ����
  FOR REC_ITEM IN CSR_ITEM LOOP
    --��ȡ�����֯ID
    BEGIN
      SELECT OOD.ORGANIZATION_ID
        INTO V_ORGANIZATION_ID
        FROM ORG_ORGANIZATION_DEFINITIONS OOD
       WHERE OOD.ORGANIZATION_NAME = REC_ITEM.ORGANIZATION_NAME;
    EXCEPTION
      WHEN OTHERS THEN
        V_ORGANIZATION_ID := NULL;
    END;
    --��ȡ����Ŀ¼��ID
    BEGIN
      SELECT MTC.ITEM_CATALOG_GROUP_ID
        INTO V_ITEM_CATALOG_GROUP_ID
        FROM MTL_ITEM_CATALOG_GROUPS_B MTC
       WHERE MTC.SEGMENT1 = REC_ITEM.ITEM_CATALOG_GROUP_NAME;
    EXCEPTION
      WHEN OTHERS THEN
        V_ITEM_CATALOG_GROUP_ID := NULL;
    END;
    --��ȡ���ϵ�λ
    BEGIN
      SELECT MUO.UOM_CODE
        INTO L_PRIMARY_UOM_CODE
        FROM MTL_UNITS_OF_MEASURE_VL MUO
       WHERE 1 = 1
         AND MUO.UNIT_OF_MEASURE = REC_ITEM.PRIMARY_UOM_CODE;
    EXCEPTION
      WHEN OTHERS THEN
        L_PRIMARY_UOM_CODE := NULL;
    END;
    --��ȡ�������ID
    BEGIN
      SELECT MC.CATEGORY_ID
        INTO V_CATEGORY_ID
        FROM MTL_CATEGORIES_B_KFV MC
      
       WHERE 1 = 1
         AND MC.CONCATENATED_SEGMENTS = REC_ITEM.CATEGORY_CONCAT_SEGS;
    EXCEPTION
      WHEN OTHERS THEN
        V_CATEGORY_ID := NULL;
    END;
  
    /* for rec_org in csr_org loop*/
    L_ITEM_REC.ORGANIZATION_ID       := V_ORGANIZATION_ID;
    L_ITEM_REC.SEGMENT1              := REC_ITEM.SEGMENT1;
    L_ITEM_REC.DESCRIPTION           := REC_ITEM.DESCRIPTION;
    L_ITEM_REC.PRIMARY_UOM_CODE      := L_PRIMARY_UOM_CODE;
    L_ITEM_REC.ITEM_CATALOG_GROUP_ID := V_ITEM_CATALOG_GROUP_ID;
    L_ITEM_REC.LONG_DESCRIPTION      := REC_ITEM.LONG_DESCRIPTION;
    L_ITEM_REC.ATTRIBUTE4            := REC_ITEM.CUQUAN;
    --����Create_Item��������
    INV_ITEM_GRP.CREATE_ITEM(P_TEMPLATE_NAME => REC_ITEM.TEMPLATE_NAME,
                             P_ITEM_REC      => L_ITEM_REC,
                             X_ITEM_REC      => X_ITEM_REC,
                             X_RETURN_STATUS => X_RETURN_STATUS,
                             X_ERROR_TBL     => X_ERROR_TBL);
  
    /*    dbms_output.put_line('��������' || x_Return_Status);*/
  
    /*FOR V_INDEX IN x_Error_Tbl.FIRST .. x_Error_Tbl.LAST LOOP
          DBMS_OUTPUT.PUT_LINE('����' || Rec_Item.Segment1 || '  ' || x_Error_Tbl(V_INDEX)
                               .MESSAGE_TEXT);
    END LOOP;*/
  
    IF X_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
      --success;
      COMMIT;
    
      /*��ȡ�ѵ������ϵ�ID*/
      --��ȡ����ID
      BEGIN
        SELECT MSIB.INVENTORY_ITEM_ID
          INTO V_ITEM_ID
          FROM MTL_SYSTEM_ITEMS_B MSIB
         WHERE 1 = 1
           AND MSIB.SEGMENT1 = REC_ITEM.SEGMENT1
           AND ROWNUM = 1;
      EXCEPTION
        WHEN OTHERS THEN
          V_ITEM_ID := NULL;
      END;
    
      BEGIN
        --l_Old_Category_Id := 4123;
        SELECT MIC.CATEGORY_ID
          INTO L_OLD_CATEGORY_ID
          FROM MTL_ITEM_CATEGORIES_V MIC
         WHERE MIC.CATEGORY_SET_ID = 1
           AND MIC.INVENTORY_ITEM_ID = V_ITEM_ID
           AND MIC.ORGANIZATION_ID = V_ORGANIZATION_ID;
      EXCEPTION
        WHEN OTHERS THEN
          L_OLD_CATEGORY_ID := NULL;
      END;
    
      DBMS_OUTPUT.PUT_LINE('�����������ID' || V_CATEGORY_ID);
    
      INV_ITEM_CATEGORY_PUB.UPDATE_CATEGORY_ASSIGNMENT(P_API_VERSION       => '1.0',
                                                       P_INIT_MSG_LIST     => FND_API.G_TRUE,
                                                       P_COMMIT            => FND_API.G_FALSE,
                                                       X_RETURN_STATUS     => X_RETURN_STATUS2,
                                                       X_ERRORCODE         => L_ERRORCODE,
                                                       X_MSG_COUNT         => X_MSG_COUNT,
                                                       X_MSG_DATA          => X_MSG_DATA,
                                                       P_OLD_CATEGORY_ID   => L_OLD_CATEGORY_ID,
                                                       P_CATEGORY_ID       => V_CATEGORY_ID,
                                                       P_CATEGORY_SET_ID   => 1,
                                                       P_INVENTORY_ITEM_ID => V_ITEM_ID,
                                                       P_ORGANIZATION_ID   => V_ORGANIZATION_ID);
      /*    dbms_output.put_line('�����������' || x_Return_Status2);*/
    END IF;
    
  
    /*������ʱ��״̬*/
  
    UPDATE cux_inv_item_engineer_template CIIT
       SET CIIT.IMPORT_FLAG           = X_RETURN_STATUS,
           CIIT.INVENTORY_ITEM_ID     = V_ITEM_ID,
           CIIT.ORGANIZATION_ID       = V_ORGANIZATION_ID,
           CIIT.ITEM_CATALOG_GROUP_ID = V_ITEM_CATALOG_GROUP_ID,
           CIIT.CATEGORY_ID           = V_CATEGORY_ID
     WHERE CIIT.SEGMENT1 = REC_ITEM.SEGMENT1;
    COMMIT;
  
    /*������ֵ*/
  /*  FOR rec_item2 IN csr_item1(REC_ITEM.SEGMENT1) LOOP
      -- l_element_sequence := l_element_sequence + 10;
       UPDATE MTL_DESCR_ELEMENT_VALUES MDEV
         SET MDEV.ELEMENT_VALUE = rec_item2.element_value1
       WHERE 1 = 1
         and mdev.element_sequence = 10
         AND MDEV.INVENTORY_ITEM_ID = V_ITEM_ID;
    
      UPDATE MTL_DESCR_ELEMENT_VALUES MDEV
         SET MDEV.ELEMENT_VALUE = rec_item2.element_value2
       WHERE 1 = 1
         and mdev.element_sequence = 20
         AND MDEV.INVENTORY_ITEM_ID = V_ITEM_ID;
    
      UPDATE MTL_DESCR_ELEMENT_VALUES MDEV
         SET MDEV.ELEMENT_VALUE = rec_item2.element_value3
       WHERE 1 = 1
         and mdev.element_sequence = 30
         AND MDEV.INVENTORY_ITEM_ID = V_ITEM_ID;
    
      UPDATE MTL_DESCR_ELEMENT_VALUES MDEV
         SET MDEV.ELEMENT_VALUE = rec_item2.element_value4
       WHERE 1 = 1
         and mdev.element_sequence = 40
         AND MDEV.INVENTORY_ITEM_ID = V_ITEM_ID;
    
      UPDATE MTL_DESCR_ELEMENT_VALUES MDEV
         SET MDEV.ELEMENT_VALUE = rec_item2.element_value5
       WHERE 1 = 1
         and mdev.element_sequence = 50
         AND MDEV.INVENTORY_ITEM_ID = V_ITEM_ID;
      COMMIT;
    END LOOP;*/
    --����������֯
   /* CUX_MTL_ITEMS_GENERATE_PKG.ASSIGN_ITEM(X_ERRBUF          => X_ERRBUF,
                                           X_RETCODE         => X_RETCODE,
                                           P_ITEM_NUMBER     => REC_ITEM.SEGMENT1,
                                           P_ORGANIZATION_ID => NULL);*/
    /* end loop;*/
  END LOOP;

END;
