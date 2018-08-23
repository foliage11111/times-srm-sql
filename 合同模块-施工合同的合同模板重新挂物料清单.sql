

--查询要修改的数据，先确认合同现在有么有挂清单
select bom.fbomid,bom.fhcontid,bom.* from wpc_bom_t bom  where bom.fnumber='QD-000639'--fb:2665;fh:2459查物料清单
select  wc.Fhcontid Fhcontid合同模板,wc.fbomid 物料清单id,wc.* from wpc_contract_t wc  
where  wc.FNUMBER='fs01.BYDX.01-设备安装工程类-2017-0006' ; ---fconid=188248 查要挂的合同


--更新合同主表
update wpc_contract_t wc set 
wc.Fhcontid=2459 --更新模板id
,wc.fbomid=2665 --更新清单id
 where fconid= 188248---合同id
 ；

--确认有没有关联关系，如果有就update，如果么有就insert
select * from wpc_contractbom_t wcb where wcb.fconid=188248；

--更新关联关系表
update wpc_contractbom_t wcb set 
wcb.fbomid=2665  --
where wcb.fconid=188248；

插入值
insert into wpc_contractbom_t （fbomid,fconid） values （2665,188248）;


