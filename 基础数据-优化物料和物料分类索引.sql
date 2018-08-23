ALTER INDEX CUX.CUX_MTL_SYSTEM_ITEM_N01 REBUILD tablespace CUX_DATA;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_N10 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_N2 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_N3 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_N9 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_N13 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_N14 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_N7 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_U1 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_N11 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_N12 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_N8 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_N15 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_N16 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_N6 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_N1 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_N4 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_B_N5 REBUILD tablespace APPS_TS_TX_IDX;


exec dbms_stats.gather_table_stats(ownname => 'INV',tabname => 'MTL_SYSTEM_ITEMS_B',estimate_percent => 10,method_opt=>'for all columns size 1',cascade=>TRUE);


analyze table INV.MTL_SYSTEM_ITEMS_B compute statistics;


ALTER INDEX INV.SCUX_ITEM_DESC_N1 REBUILD tablespace APPS_TS_TX_DATA;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_TL_N1 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_SYSTEM_ITEMS_TL_U1 REBUILD tablespace APPS_TS_TX_IDX;


exec dbms_stats.gather_table_stats(ownname => 'INV',tabname => 'MTL_SYSTEM_ITEMS_TL',estimate_percent => 10,method_opt=>'for all columns size 1',cascade=>TRUE);


analyze table INV.MTL_SYSTEM_ITEMS_TL compute statistics;


ALTER INDEX INV.MTL_ITEM_CATEGORIES_N4 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_ITEM_CATEGORIES_N3 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_ITEM_CATEGORIES_U1 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_ITEM_CATEGORIES_N1 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_ITEM_CATEGORIES_N2 REBUILD tablespace APPS_TS_TX_IDX;

exec dbms_stats.gather_table_stats(ownname => 'INV',tabname => 'MTL_ITEM_CATEGORIES',estimate_percent => 10,method_opt=>'for all columns size 1',cascade=>TRUE);


analyze table INV.MTL_ITEM_CATEGORIES compute statistics;


ALTER INDEX INV.MTL__CATEGORIES_B_N2 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_CATEGORIES_B_N1 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_CATEGORIES_B_U1 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX APPS.CUX_MTL_CATEGORIES_B_N3 REBUILD tablespace CUX_INDEX;

analyze table INV.MTL_CATEGORIES_B compute statistics;

exec dbms_stats.gather_table_stats(ownname => 'INV',tabname => 'MTL_CATEGORIES_B',estimate_percent => 10,method_opt=>'for all columns size 1',cascade=>TRUE);


ALTER INDEX INV.MTL_CATEGORIES_TL_U1 REBUILD tablespace APPS_TS_TX_IDX;

analyze table INV.MTL_CATEGORIES_TL compute statistics;

exec dbms_stats.gather_table_stats(ownname => 'INV',tabname => 'MTL_CATEGORIES_TL',estimate_percent => 10,method_opt=>'for all columns size 1',cascade=>TRUE);


ALTER INDEX INV.MTL_ITEM_CATALOG_GROUPS_B_N1 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX INV.MTL_ITEM_CATALOG_GROUPS_B_U1 REBUILD tablespace APPS_TS_TX_IDX;

analyze table INV.MTL_ITEM_CATALOG_GROUPS_B compute statistics;

exec dbms_stats.gather_table_stats(ownname => 'INV',tabname => 'MTL_ITEM_CATALOG_GROUPS_B',estimate_percent => 10,method_opt=>'for all columns size 1',cascade=>TRUE);


ALTER INDEX INV.MTL_ITEM_CATALOG_GROUPS_TL_U1 REBUILD tablespace APPS_TS_TX_IDX;

analyze table INV.MTL_ITEM_CATALOG_GROUPS_TL compute statistics;

exec dbms_stats.gather_table_stats(ownname => 'INV',tabname => 'MTL_ITEM_CATALOG_GROUPS_TL',estimate_percent => 10,method_opt=>'for all columns size 1',cascade=>TRUE);


ALTER INDEX INV.MTL_DESCRIPTIVE_ELEMENTS_U1 REBUILD tablespace APPS_TS_TX_IDX;

analyze table INV.MTL_DESCRIPTIVE_ELEMENTS compute statistics;

exec dbms_stats.gather_table_stats(ownname => 'INV',tabname => 'MTL_DESCRIPTIVE_ELEMENTS',estimate_percent => 10,method_opt=>'for all columns size 1',cascade=>TRUE);


ALTER INDEX APPLSYS.FND_FLEX_VALUES_U1 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX APPLSYS.FND_FLEX_VALUES_N1 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX APPLSYS.FND_FLEX_VALUES_N2 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX APPLSYS.FND_FLEX_VALUES_U2 REBUILD tablespace APPS_TS_TX_IDX;

analyze table APPLSYS.FND_FLEX_VALUES compute statistics;

exec dbms_stats.gather_table_stats(ownname => 'APPLSYS',tabname => 'FND_FLEX_VALUES',estimate_percent => 10,method_opt=>'for all columns size 1',cascade=>TRUE);

ALTER INDEX APPLSYS.FND_FLEX_VALUES_TL_N1 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX APPLSYS.FND_FLEX_VALUES_TL_N2 REBUILD tablespace APPS_TS_TX_IDX;
ALTER INDEX APPLSYS.FND_FLEX_VALUES_TL_U1 REBUILD tablespace APPS_TS_TX_IDX;

analyze table APPLSYS.FND_FLEX_VALUES_TL compute statistics;

exec dbms_stats.gather_table_stats(ownname => 'APPLSYS',tabname => 'FND_FLEX_VALUES_TL',estimate_percent => 10,method_opt=>'for all columns size 1',cascade=>TRUE);


