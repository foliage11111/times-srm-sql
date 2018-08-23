create or replace PACKAGE cuxs_mfgr021_pkg IS
  /*===============================================
    Copyright (C) Hand Business Consulting Services
                AllRights Reserved
  ================================================
  * ===============================================
  *   PROGRAM NAME:
  *                CUXS_MFGR021_PKG
  *   DESCRIPTION:
  *                库存周转率报表
  *   HISTORY:
  *     1.00   2006-2-23   Jianping.ni@hand-china.com Creation
  *
  * ==============================================*/
  FUNCTION get_person_name(i_person_id IN NUMBER) RETURN VARCHAR2;
  
  FUNCTION get_item_description(i_item_catalog_group_id IN NUMBER)
    RETURN VARCHAR2;
    
  --获取库存现有量
  FUNCTION get_onhand_qty(i_organization_id   IN NUMBER
                         ,i_inventory_item_id IN NUMBER
                         ,i_subinventory_code IN VARCHAR2) RETURN NUMBER;
                         
  PROCEDURE main(errbuf              OUT VARCHAR2
                ,retcode             OUT VARCHAR2
                ,i_organization_id   IN NUMBER
                ,i_date_from         IN VARCHAR2
                ,i_date_to           IN VARCHAR2
                ,i_subinventory_from IN VARCHAR2
                ,i_subinventory_to   IN VARCHAR2
                ,i_item_number_from  IN VARCHAR2
                ,i_item_number_to    IN VARCHAR2
                ,i_slacken_time_flag IN VARCHAR2);
END;
