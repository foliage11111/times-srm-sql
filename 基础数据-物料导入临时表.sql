select t.*, t.rowid from CUX.CUX_INV_ITEM_NEW_TEMPLATE t for update;


delete from CUX.CUX_INV_ITEM_NEW_TEMPLATE

commit;


select count(1) from CUX.CUX_INV_ITEM_NEW_TEMPLATE t where t.import_flag='E'

