--查询合同模板
select cth.fhcontid from  WPC_ContTempHeader_T cth where cth.fhname='总包合同材料过渡版';--2406
select * from WPC_ContTempHeader_T cth where cth.fhname='宝露-工地视频监控2016';--2385
select cth.fhcontid from  WPC_ContTempHeader_T cth where cth.fhname='消防过渡模板';--2422
select * from  WPC_ContTempHeader_T cth where cth.fhname='园林工程施工合同2016年';--2412
select * from  WPC_ContTempHeader_T cth where cth.fhname='土建安装总包合同(非挂靠)';--2396

--查询物料清单
select  bom.fbomid from wpc_bom_t bom  where bom.fname='桥南项目二标段水电甲供材料清单';--2467
select  bom.fbomid from wpc_bom_t bom  where bom.fnumber='QD-000605';--2568

--修改合同模板
select  T1.Fhcontid,--合同模板ID
t1.fbomid --物料清单ID
 from wpc_contract_t T1  where  T1.FNUMBER='gz01.SDSQ.01-园林工程类-2016-0010' for update

select  T1.Fhcontid,--合同模板ID
t1.fbomid --物料清单ID
 from wpc_contract_t T1  where  T1.Fname='东莞石排水贝村项目一期消防安装工程合同' for update
 
 
 
 
