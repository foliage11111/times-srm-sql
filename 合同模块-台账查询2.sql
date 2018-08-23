/*begin
  mo_global.init('M');
end;*/

select t4.NAME company,
       T3.FNAME PrjName,
       t1.fname ConName,
       t1.fnumber connumber,
       t1.fconid,
       t3.fprjid,
       pv.vendor_name,
       t1.fsecondparty,
       nvl(t1.fcontractmoney, 0) fcontractmoney,  --签约金额
       ccd.fchangemoney changamount,  --变更金额合计
       ccd.fsubcontractmoney supplyamount, ---补充协议金额
       ccd.frewardamount rewardamount, ---奖励金额
       ccd.fdebitamount debitamount,--扣款金额
       t1.fserviceterm,
       nvl(t1.fserviceamount, 0) fserviceamount,--保修金额
       nvl(t1.fservicebalance, 0) fservicebalance,--质保扣款
          
      (SELECT sum(nvl(decode(tp2.ffq_flag, 'Y', tp1.fpaidamount, tp1.fapplyamount),0))
          FROM WPC_PaymentApplyDetail_T tp1, WPC_PaymentApply_T tp2
         WHERE tp1.fpaid = tp2.fpaid and tp1.FConId =  t1.fconid
           and tp2.FWFLOWSTATE in  ('10','20')) sumpayamount,   --累计已申请
           
       (select nvl(sum(ca.famount), 0)
          from WPC_ContractAdvance_T ca
         where ca.fconid = t1.fconid) -
       (select nvl(sum(cr.famount), 0)
          from WPC_ContractRepayment_T cr
         where cr.fconid = t1.fconid) unrepayamount,
       t1.fismultiblock,
       t1.fsharingrule,
(select  nvl(sum(cc.fauditamount),0)
          from WPC_ChangeContract_t cc, WPC_CHANGEVISA_t cv
          ,WPC_ChangeConfirm_T ccf
         where cv.fcvid = cc.fcvid
           and cv.fwflowstate = '20'
           and cv.fchangetype = '20'
           and cc.fconid = t1.fconid
           and ccf.fchgconid(+) = cc.fchgconid
           ） changeamount, --罚款金额？
  (select  nvl(sum(nvl(ccf.fauditamount, ccf.frequestamount)),0)
          from WPC_ChangeContract_t cc, WPC_CHANGEVISA_t cv
          ,WPC_ChangeConfirm_T ccf
         where cv.fcvid = cc.fcvid
           and cv.fwflowstate = '20'
           and cv.fchangetype = '10'
           and cc.fconid = t1.fconid
           and ccf.fchgconid = cc.fchgconid
           and ccf.fwflowstate = '20'） visaamount,  -----现场签证金额
           t3.org_id,
    (select  nvl(sum(nvl(ccf.fauditamount, ccf.frequestamount)),0)
          from WPC_ChangeContract_t cc, WPC_CHANGEVISA_t cv
          ,WPC_ChangeConfirm_T ccf
         where cv.fcvid = cc.fcvid
           and cv.fwflowstate = '20'
           and cv.fchangetype not in ('10','20')
           and cc.fconid = t1.fconid
           and ccf.fchgconid = cc.fchgconid
           and ccf.fwflowstate = '20') otherchange, ---其他变更金额
    (select sum(fdeductamount) from wpc_servicebalance_input_t a
where a.fcontractnumber=t1.fnumber) fdeductamount, 
 
     t1.fissubcontract   
  from WPC_Contract_T             t1,
       WBD_ProjectBlock_T         t2,
       WBD_Project_T              t3,
       HR_ORGANIZATION_UNITS      T4,
       po_vendors                 pv,
       wpc_fcontractcostdetails_v ccd
where t1.fpbno = t2.fpbno
   and t3.fprjid = t2.fprjid
   AND T3.ORG_ID = T4.organization_id
   and pv.vendor_id(+) = t1.fsecondparty
   and t2.fpbid = 10116
   and t3.fiseffective = 1
   and t1.fwflowstate = '20'
   and t1.fconid = ccd.FCONID
   and nvl(t1.fisnoncontract, '0') = '0'  
   and t1.fisaccounting = '1'
   and nvl(t1.fsettlementstate, '0') = '0'
   and mo_global.check_access(t3.org_id) = 'Y'
   and  t1.fname='时代春树里项目交楼标准装修工程合同'
   and not exists
(select 1
          from wpc.WPC_ChangeContract_t cc, wpc.WPC_CHANGEVISA_t cv
          ,wpc.WPC_ChangeConfirm_T  ccf
         where cv.fcvid = cc.fcvid
           and cv.fchangetype = '20'
           and cc.fconid = t1.fconid
           and ccf.fchgconid(+) = cc.fchgconid
           and nvl(cv.fwflowstate,'00') <> '20'
        union
        select cc.fconid
          from WPC_ChangeContract_t cc,
               WPC_CHANGEVISA_t     cv,
               WPC_ChangeConfirm_T  ccf
         where cv.fcvid = cc.fcvid
           and ccf.fchgconid(+) = cc.fchgconid
           and (ccf.fwflowstate <> '20' or ccf.fwflowstate is null)
           and cv.fchangetype = '10'
           and cc.fconid = t1.fconid)
 ;
