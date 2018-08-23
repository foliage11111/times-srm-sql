select * from cux_engineering_list;


-- Create table
create table CUX_ENGINEERING_LIST
(
  line_number      NUMBER,
  classify_code    VARCHAR2(200),
  classify_desc    VARCHAR2(200),
  project_number   VARCHAR2(50),
  project_name     VARCHAR2(4000),
  unit             VARCHAR2(50),
  project_charac   VARCHAR2(4000),
  engineering_rule VARCHAR2(4000),
  supply_type      VARCHAR2(50),
  first_cost       NUMBER,
  second_cost      NUMBER,
  manual_cost      NUMBER,
  machine_cost     NUMBER,
  indirect_cost    NUMBER,
  import_status    VARCHAR2(10),
  error_msg        VARCHAR2(4000)
)
tablespace APPS_TS_TX_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 128K
    next 128K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );
-- Create/Recreate indexes 
create unique index CUX_ENGINEERING_LIST_U1 on CUX_ENGINEERING_LIST (PROJECT_NUMBER)
  tablespace APPS_TS_TX_DATA
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 128K
    next 128K
    minextents 1
    maxextents unlimited
    pctincrease 0
  );