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
  V_ITEM_CATALOG_GROUP_ID NUMBER; --物料目录组ID
  V_ORGANIZATION_ID       NUMBER; --库存组织ID
  V_CATEGORY_ID           NUMBER; --物料类别ID
  V_ITEM_ID               NUMBER;
  V_SET_PRCS_ID           NUMBER;
  L_ELEMENT_SEQUENCE      NUMBER;
  L_PRIMARY_UOM_CODE      VARCHAR2(100);
  X_ERRBUF                VARCHAR2(4000);
  X_RETCODE               VARCHAR2(4000);
  cursor csr_item1 is
    select cii.element_value1,
           cii.element_value2,
           cii.element_value3,
           cii.element_value4,
           cii.element_value5,
           cii.element_value6,
           cii.element_value7,
           cii.element_value8,
           cii.element_value9,
           cii.segment1,
           cii.inventory_item_id
      from CUX_INV_ITEM_NEW_TEMPLATE cii
     where 1 = 1
       and (cii.attribute1 <> 'Y' or cii.attribute1 is null); --没更新过目录组

  /* cursor csr_item2(V_ITEM_ID IN NUMBER) is
  select mdev.element_sequence
    from MTL_DESCR_ELEMENT_VALUES MDEV
   where mdev.inventory_item_id = V_ITEM_ID
     and mdev.default_element_flag = 'Y'
   order by mdev.element_sequence asc;*/

BEGIN

  /*更新组值*/
  FOR rec_item1 IN csr_item1 LOOP
    --获取物料ID
    BEGIN
      SELECT MSIB.INVENTORY_ITEM_ID
        INTO V_ITEM_ID
        FROM MTL_SYSTEM_ITEMS_B MSIB
       WHERE 1 = 1
         AND MSIB.SEGMENT1 = REC_ITEM1.SEGMENT1
         AND ROWNUM = 1;
    EXCEPTION
      WHEN OTHERS THEN
        V_ITEM_ID := NULL;
    END;
  
    UPDATE MTL_DESCR_ELEMENT_VALUES MDEV
       SET MDEV.ELEMENT_VALUE = rec_item1.element_value1
     WHERE 1 = 1
       and mdev.element_sequence =
           (select element2.element_sequence
              from (select element1.element_sequence, rownum row_num
                      from (select mdev.element_sequence, rownum row_num
                              from MTL_DESCR_ELEMENT_VALUES MDEV
                             where mdev.inventory_item_id = V_ITEM_ID
                               and mdev.default_element_flag = 'Y'
                             order by mdev.element_sequence asc) element1
                     where 1 = 1) element2
             where 1 = 1
               and element2.row_num = 1)
       AND MDEV.INVENTORY_ITEM_ID = V_ITEM_ID;
  
    UPDATE MTL_DESCR_ELEMENT_VALUES MDEV
       SET MDEV.ELEMENT_VALUE = rec_item1.element_value2
     WHERE 1 = 1
       and mdev.element_sequence =
           (select element2.element_sequence
              from (select element1.element_sequence, rownum row_num
                      from (select mdev.element_sequence, rownum row_num
                              from MTL_DESCR_ELEMENT_VALUES MDEV
                             where mdev.inventory_item_id = V_ITEM_ID
                               and mdev.default_element_flag = 'Y'
                             order by mdev.element_sequence asc) element1
                     where 1 = 1) element2
             where 1 = 1
               and element2.row_num = 2)
       AND MDEV.INVENTORY_ITEM_ID = V_ITEM_ID;
  
    UPDATE MTL_DESCR_ELEMENT_VALUES MDEV
       SET MDEV.ELEMENT_VALUE = rec_item1.element_value3
     WHERE 1 = 1
       and mdev.element_sequence =
           (select element2.element_sequence
              from (select element1.element_sequence, rownum row_num
                      from (select mdev.element_sequence, rownum row_num
                              from MTL_DESCR_ELEMENT_VALUES MDEV
                             where mdev.inventory_item_id = V_ITEM_ID
                               and mdev.default_element_flag = 'Y'
                             order by mdev.element_sequence asc) element1
                     where 1 = 1) element2
             where 1 = 1
               and element2.row_num = 3)
       AND MDEV.INVENTORY_ITEM_ID = V_ITEM_ID;
  
    UPDATE MTL_DESCR_ELEMENT_VALUES MDEV
       SET MDEV.ELEMENT_VALUE = rec_item1.element_value4
     WHERE 1 = 1
       and mdev.element_sequence =
           (select element2.element_sequence
              from (select element1.element_sequence, rownum row_num
                      from (select mdev.element_sequence, rownum row_num
                              from MTL_DESCR_ELEMENT_VALUES MDEV
                             where mdev.inventory_item_id = V_ITEM_ID
                               and mdev.default_element_flag = 'Y'
                             order by mdev.element_sequence asc) element1
                     where 1 = 1) element2
             where 1 = 1
               and element2.row_num = 4)
       AND MDEV.INVENTORY_ITEM_ID = V_ITEM_ID;
  
    UPDATE MTL_DESCR_ELEMENT_VALUES MDEV
       SET MDEV.ELEMENT_VALUE = rec_item1.element_value5
     WHERE 1 = 1
       and mdev.element_sequence =
           (select element2.element_sequence
              from (select element1.element_sequence, rownum row_num
                      from (select mdev.element_sequence, rownum row_num
                              from MTL_DESCR_ELEMENT_VALUES MDEV
                             where mdev.inventory_item_id = V_ITEM_ID
                               and mdev.default_element_flag = 'Y'
                             order by mdev.element_sequence asc) element1
                     where 1 = 1) element2
             where 1 = 1
               and element2.row_num = 5)
       AND MDEV.INVENTORY_ITEM_ID = V_ITEM_ID;
  
    UPDATE MTL_DESCR_ELEMENT_VALUES MDEV
       SET MDEV.ELEMENT_VALUE = rec_item1.element_value6
     WHERE 1 = 1
       and mdev.element_sequence =
           (select element2.element_sequence
              from (select element1.element_sequence, rownum row_num
                      from (select mdev.element_sequence, rownum row_num
                              from MTL_DESCR_ELEMENT_VALUES MDEV
                             where mdev.inventory_item_id = V_ITEM_ID
                               and mdev.default_element_flag = 'Y'
                             order by mdev.element_sequence asc) element1
                     where 1 = 1) element2
             where 1 = 1
               and element2.row_num = 6)
       AND MDEV.INVENTORY_ITEM_ID = V_ITEM_ID;
  
    UPDATE MTL_DESCR_ELEMENT_VALUES MDEV
       SET MDEV.ELEMENT_VALUE = rec_item1.element_value7
     WHERE 1 = 1
       and mdev.element_sequence =
           (select element2.element_sequence
              from (select element1.element_sequence, rownum row_num
                      from (select mdev.element_sequence, rownum row_num
                              from MTL_DESCR_ELEMENT_VALUES MDEV
                             where mdev.inventory_item_id = V_ITEM_ID
                               and mdev.default_element_flag = 'Y'
                             order by mdev.element_sequence asc) element1
                     where 1 = 1) element2
             where 1 = 1
               and element2.row_num = 7)
       AND MDEV.INVENTORY_ITEM_ID = V_ITEM_ID;
  
    UPDATE MTL_DESCR_ELEMENT_VALUES MDEV
       SET MDEV.ELEMENT_VALUE = rec_item1.element_value8
     WHERE 1 = 1
       and mdev.element_sequence =
           (select element2.element_sequence
              from (select element1.element_sequence, rownum row_num
                      from (select mdev.element_sequence, rownum row_num
                              from MTL_DESCR_ELEMENT_VALUES MDEV
                             where mdev.inventory_item_id = V_ITEM_ID
                               and mdev.default_element_flag = 'Y'
                             order by mdev.element_sequence asc) element1
                     where 1 = 1) element2
             where 1 = 1
               and element2.row_num = 8)
       AND MDEV.INVENTORY_ITEM_ID = V_ITEM_ID;
  
    UPDATE MTL_DESCR_ELEMENT_VALUES MDEV
       SET MDEV.ELEMENT_VALUE = rec_item1.element_value9
     WHERE 1 = 1
       and mdev.element_sequence =
           (select element2.element_sequence
              from (select element1.element_sequence, rownum row_num
                      from (select mdev.element_sequence, rownum row_num
                              from MTL_DESCR_ELEMENT_VALUES MDEV
                             where mdev.inventory_item_id = V_ITEM_ID
                               and mdev.default_element_flag = 'Y'
                             order by mdev.element_sequence asc) element1
                     where 1 = 1) element2
             where 1 = 1
               and element2.row_num = 9)
       AND MDEV.INVENTORY_ITEM_ID = V_ITEM_ID;
       
    COMMIT;
  END LOOP;

END;
