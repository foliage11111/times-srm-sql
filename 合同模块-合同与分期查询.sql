---�������������鷳�����⣬��ͬ���Ի�������������ݾ�Ȼ��һ��
--�����Ը�ΪӢ�
ALTER SESSION SET NLS_LANGUAGE=american;

--�������ΪӢ�ģ�
ALTER SESSION SET NLS_TERRITORY=america;

--�����ԸĻ����ģ�
ALTER SESSION SET NLS_LANGUAGE='SIMPLIFIED CHINESE';

--�������Ϊ���ģ�
ALTER SESSION SET NLS_TERRITORY=CHINA;



--��Ŀ����
SELECT wpt.FPRJID,---primary key
  wpt.FPRJNO,--contract no  for version control
  wpt.FVERSION ,---version 
  wpt.FISEFFECTIVE,--is enable
  wpt.FNUMBER,
  wpt.org_id,
  wpt.FNAME,
  wpt.creation_date,
  wpt.*
FROM WBD.WBD_PROJECT_T wpt,WBD_PROJECTBLOCK_T wpb
WHERE wpt.FNAME     ='ʱ���й�����ά����Ŀ' and wpt.FPRJID=wpb.FPRJID
AND wpt.FISEFFECTIVE=1;

--2735
--780

select��* from hr_organization_units hou where hou.organization_id in (2735,780);

---����
SELECT wpb.FPRJID,
  wpb.FPBID, --���� id?
  wpb.FPBNO,--���ڱ��?
  wpb.FNUMBER,--������ʾ�ڼ�������
  wpb.FNAME,---��������
  wpb.*
FROM WBD.WBD_PROJECTBLOCK_T wpb
WHERE wpb.FPBID=5314;

---���?
select wpdt.fname,wpdt.fproductfeature,wpdt.fnumber,wbt.* from WBD.WBD_BLOCKBUILDING_T wbt,WBD.WBD_PRODUCT_T wpdt 
where wbt.FPBID=649 and wpdt.fprdid=wbt.fprdid;

select * from WBD.WBD_BLOCKBUILDING_T wbt;

select * from WBD.WBD_PRODUCT_T wpdt where wpdt.FPRDID=256;


--��ͬ����
select  wc.fprjid,wc.Fhcontid Fhcontid��ͬģ��,wc.fbomid �����嵥id,wc.* from wpc_contract_t wc  
where  wc.FNUMBER='fs01.BYDX.01-�豸��װ������-2017-0006';

select * from cux_pr_plan_lines ;


--����Э���ѯ������Դ��
select cpph.plan_number,cpph.plan_name,cpph.plan_status ,pha.segment1
,pla.item_id,pla.item_description,pla.unit_price from 
 po.po_lines_all   pla,
       po.po_headers_all pha ,
        cux_pr_plan_headers cpph,
         wpc_contract_t wc,
          WBD.WBD_PROJECTBLOCK_T wpb, 
          CUX.CUX_RESOURCE_ALLOCATION_TMP cra ,
  CUX_TEN_DIS_RESOURCES_TMP ctd
WHERE ctd.RESOURCE_DIS_ID=cra.RESOURCE_DIS_ID 
 and cpph.contract_id=wc.fconid and wpb.fpbid=wc.fpbid
 and ctd.project_block_id=wpb.fpbid
 and ctd.agreement_number= pha.segment1
 and pha.po_header_id = pla.po_header_id 
 and pha.type_lookup_code='BLANKET'
 and cpph.plan_number='S201706028'
 and pla.item_description like '%ǽ%'
;


select cppl.ITEM_ID,msib.SEGMENT1,cpph.CONTRACT_ID,cppl.UNIT_PRICE,cppl.PLAN_QUANTITY,cpph.PLAN_NUMBER,cpph.CONTRACT_ID ,
cppl.AG_HEADER_ID,cppl.AG_LINE_ID
from cux_pr_plan_headers cpph,CUX.CUX_PR_PLAN_LINES cppl,mtl_system_items_b msib 
where cpph.HEADER_ID=cppl.HEADER_ID and  msib.inventory_item_id = cppl.item_id 
and msib.ORGANIZATION_ID=460
and cpph.PLAN_NUMBER='S201706036';


 select  wpb.FPBID,wpb.FPRJID,wpb.FBLOCKSTAGE,ctd.BLOCK_DIVISION,ctd.AGREEMENT_NUMBER,ctd.VENDOR_ID,ctd.VENDOR_NAME ,wct.FCONID,wct.FNAME,cpph.PLAN_NUMBER,cpph.HEADER_ID,cpph.VERSION_NUM
 from  WBD.WBD_PROJECTBLOCK_T wpb, CUX_TEN_DIS_RESOURCES_TMP ctd ,wpc_contract_t wct,CUX.CUX_PR_PLAN_HEADERS cpph,CUX.CUX_PR_PLAN_LINES cppl,mtl_system_items_b msib
 where wpb.FPBID=ctd.PROJECT_BLOCK_ID and wct.FPBID=wpb.FPBID and cpph.CONTRACT_ID=wct.FCONID 
 and cpph.PLAN_NUMBER='S201706036'
 ;
 select cppl.ITEM_ID,msib.SEGMENT1,cpph.CONTRACT_ID,cppl.UNIT_PRICE,cppl.PLAN_QUANTITY,wpb.FPBID,wpb.FPRJID,wpb.FBLOCKSTAGE,ctd.BLOCK_DIVISION,ctd.AGREEMENT_NUMBER,ctd.VENDOR_ID,ctd.VENDOR_NAME ,wct.FCONID,wct.FNAME,cpph.PLAN_NUMBER,cpph.HEADER_ID,cpph.VERSION_NUM
 from  WBD.WBD_PROJECTBLOCK_T wpb, CUX_TEN_DIS_RESOURCES_TMP ctd ,wpc_contract_t wct,CUX.CUX_PR_PLAN_HEADERS cpph,CUX.CUX_PR_PLAN_LINES cppl,mtl_system_items_b msib
 where wpb.FPBID=ctd.PROJECT_BLOCK_ID and wct.FPBID=wpb.FPBID and cpph.CONTRACT_ID=wct.FCONID and cpph.HEADER_ID=cppl.HEADER_ID and  msib.inventory_item_id = cppl.item_id 
and msib.ORGANIZATION_ID=460
 and cpph.PLAN_NUMBER='S201706036'
 ;
 
 select * from CUX.CUX_PR_PLAN_HEADERS cpph where cpph.PLAN_NUMBER='S201706036';--contract_id=179237
 select wc.FPBID,wc.FPRJID,wc.* from wpc_contract_t wc where wc.FCONID=179237; --fpbid=4514,fprjid=3372
 select * from WBD_PROJECTBLOCK_T wpb where wpb.FPBID=4514; ---fname='��ˮ��ӯ����Ŀһ��'
 select * from CUX_TEN_DIS_RESOURCES_TMP ctd where  ctd.PROJECT_BLOCK_ID=4141;
 
 
 select * from CUX_TEN_DIS_RESOURCES_TMP ctd,WBD_PROJECTBLOCK_T wpb,wpc_contract_t wc ,CUX_PR_PLAN_HEADERS cpph
 where ctd.PROJECT_BLOCK_ID=wpb.FPBID and wpb.FPBID=wc.FPBID   and wc.FCONID=cpph.CONTRACT_ID  
 
 ;

---�ƻ�������Դ����Э���
select cpph.plan_number,
       cpph.contract_id,
       wc.fconid,
       wc.fprjno,
       wc.fpbno,
       wc.fpbid,
       wc.fnumber,
       wc.fname,
       wpb.fpbid,
       wpb.fnumber,
       wpb.fname,
       
       cra.resource_number,
       cra.status,
       cra.project_name,
       ctd.vendor_name,
       ctd.vendor_id,
       ctd.block_division
       ,ctd.project_block_id
       ,ctd.project_block_name
       ,ctd.agreement_number
       ,ctd.effective_time
       ,ctd.entrance_time
  from cux_pr_plan_headers cpph, wpc_contract_t wc, WBD.WBD_PROJECTBLOCK_T wpb, CUX.CUX_RESOURCE_ALLOCATION_TMP cra ,
  CUX_TEN_DIS_RESOURCES_TMP ctd
WHERE ctd.RESOURCE_DIS_ID=cra.RESOURCE_DIS_ID 
 and cpph.contract_id=wc.fconid and wpb.fpbid=wc.fpbid
 and ctd.project_block_id=wpb.fpbid
 and cpph.plan_number='S201706028'
 ;


---��ͬ�嵥
select bom.fbomid,bom.fhcontid,bom.* from wpc_bom_t bom  where bom.fnumber='QD-000639'  ;--fb:2665;fh:2459

----project*block*building*product 
select  wpt.FPRJID,---primary key
  wpt.FPRJNO,--contract no  for version control
  wpt.FVERSION ,---version 
  wpt.FISEFFECTIVE PrjStauts,--is enable
  wpt.FNUMBER prjNO,
  wpt.FNAME prjName,
  wpb.FPBID  ,--���� id?
  wpb.FPBNO ,--���ڱ��?
  wpb.FNUMBER fenqiBianhao,--������ʾ�ڼ�������
  
  wpb.FNAME fenqiName,---��������
 wbt.FPRDID ,
 wbt.FNUMBER duanFNUMBER,--
 wbt.FTENDER ,
 wpdt.fname,
 wpdt.fproductfeature,
 wpdt.fnumber
  from WBD.WBD_PROJECT_T wpt,WBD.WBD_PROJECTBLOCK_T wpb ,WBD_BLOCKBUILDING_T wbt,WBD.WBD_PRODUCT_T wpdt 
where wpt.FPRJID=wpb.FPRJID and wpt.FISEFFECTIVE=1
and wpb.FPBID=wbt.FPBID  and wpdt.fprdid=wbt.fprdid
and wpb.FNAME='ʱ�������������ϣ�����'

;

