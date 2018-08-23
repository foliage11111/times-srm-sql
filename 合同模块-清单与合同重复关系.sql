
select count(*) from wpc_contractbom_t wcb ;

select count(*) from wpc_contract_t;

select * from (
select wcb.fconid,count(*) cn from  wpc_contractbom_t wcb group by wcb.fconid) where cn>1
 
select 'update wpc_contractbom_t wcb set wcb.fbomid='||t.fbomid||' where wcb.fconid='||t.fconid,t.*
  from (select wc.fconid,
               wc.fbomid,
               wcb.fconid fconid2,
               wcb.fbomid fbomid2,
               wc.fnumber,
               wc.fname
          from wpc_contract_t wc, wpc_contractbom_t wcb
         where wc.fconid = wcb.fconid(+)
         and wc.fwflowstate in ('10', '20')) t
 where t.fbomid is not null
   and t.fbomid2 is null

;
select * from po_headers_all;
 
select wc.fconid,wc.fnumber,wc.fname,wc.fbomid,wc.fhcontid,wc.*
 from wpc_contract_t wc
 where 
 wc.fnumber='gz01.SDCD.02-装修工程类-2016-0005'
 ; 
 
 select  wc.Fhcontid,--合同模板ID
wc.fbomid ,--物料清单ID
wc.*
 from wpc.wpc_contract_t wc  where  wc.FNAME like '%时代长岛二期7-14%'

;
