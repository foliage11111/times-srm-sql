create table cux.cux_inv_item_new_template(
  inventory_item_id     NUMBER,--物料ID
  organization_id       NUMBER,--库存组织ID
  organization_name     VARCHAR2(100),--库存组织名
  organization_code     VARCHAR2(100),--库存组织代码
  template_id           NUMBER,
  template_name         VARCHAR2(100),--模板名
  segment1              VARCHAR2(40),--物料
  description           VARCHAR2(240),--物料描述
  primary_uom_code      VARCHAR2(3),--单位
  item_catalog_group_id    NUMBER,--物料目录组ID
  item_catalog_group_name  VARCHAR2(100),--物料目录组
  element_value1           VARCHAR2(100),--组值1
  element_value2           VARCHAR2(100),--组值2
  element_value3          VARCHAR2(100),--组值3
  element_value4           VARCHAR2(100),--组值4
  element_value5           VARCHAR2(100),--组值5
  long_description      VARCHAR2(4000),
  category_id           NUMBER,--类别ID
  category_concat_segs  VARCHAR2(163),
  category_concat_des   VARCHAR2(240),
  import_flag           VARCHAR2(50),
  last_update_date       DATE,
  last_updated_by        NUMBER,
  creation_date          DATE,
  created_by             NUMBER,
  last_update_login      NUMBER,
  attribute_category     VARCHAR2(30),
  attribute1             VARCHAR2(150),
  attribute2             VARCHAR2(150),
  attribute3             VARCHAR2(150),
  attribute4             VARCHAR2(150),
  attribute5             VARCHAR2(150),
  attribute6             VARCHAR2(150),
  attribute7             VARCHAR2(150),
  attribute8             VARCHAR2(150),
  attribute9             VARCHAR2(150),
  attribute10            VARCHAR2(150),
  attribute11            VARCHAR2(150),
  attribute12            VARCHAR2(150),
  attribute13            VARCHAR2(150),
  attribute14            VARCHAR2(150),
  attribute15            VARCHAR2(150)
);


--drop table cux.cux_inv_item_new_template;


create synonym cux_inv_item_new_template for cux.cux_inv_item_new_template;
