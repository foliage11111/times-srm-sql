
select bom.fbomid,bom.fhcontid,bom.* from wpc_bom_t bom  where bom.fnumber='QD-000639'  ;--fb:2665;fh:2459

select  wc.fprjid,wc.Fhcontid Fhcontid合同模板,wc.fbomid 物料清单id,wc.* from wpc_contract_t wc  where  wc.FNUMBER='fs01.BYDX.01-设备安装工程类-2017-0006' ; ---fconid=188248

update wpc_contract_t wc set wc.Fhcontid=2459,wc.fbomid=2665 where fconid= 188248;


--查询合同是否挂了清单
select  wc.Fhcontid,--合同模板ID
wc.fbomid ,--物料清单ID
wc.*
 from wpc_contract_t wc  where  wc.FNAME='时代长岛（广州南）二期园林工程施工合同'

;


--按合同编号查询合同
select  wc.Fhcontid Fhcontid合同模板,--合同模板ID
wc.fbomid 物料清单id,--物料清单ID
wc.*
 from wpc_contract_t wc  where  wc.FNUMBER='dg01.SPSB.01-土建工程类-2016-0002' 
; 

--查询合同模板
select cth.fhcontid from  WPC_ContTempHeader_T cth where cth.fhname='总包合同材料过渡版';--2406
select * from WPC_ContTempHeader_T cth where cth.fhname='宝露-工地视频监控2016';--2385
select cth.fhcontid from  WPC_ContTempHeader_T cth where cth.fhname='消防过渡模板';--2422
select * from  WPC_ContTempHeader_T cth where cth.fhname='园林工程施工合同2016年';--2412
select * from  WPC_ContTempHeader_T cth where cth.fhname='土建安装总包合同(非挂靠)';--2396

--查询物料清单
select  bom.fbomid from wpc_bom_t bom  where bom.fname='桥南项目二标段水电甲供材料清单';--2467
select  bom.fbomid from wpc_bom_t bom  where bom.fnumber='QD-000605';--2568


----查询合同对应的月度计划
select * from cux_pr_plan_headers cpph where cpph.PLAN_NUMBER='S201703034';

select * from cux_pr_plan_headers cpph where cpph.CONTRACT_ID=180268;
