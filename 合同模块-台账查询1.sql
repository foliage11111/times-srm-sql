/*begin
  mo_global.init('M');
end;*/

select t1.rowid row_id,
       t1.fcsid, --结算ID
       t1.fconid, --合同ID
       t1.fnumber, --结算编码
    --'22' fnumber,
       t1.fsettledate, --结算日期
       t1.fprjid,
       t1.fprjno,
       c.Fpjnumber Prjnumber, --项目编码
       c.fpjname prjname, --项目名称
       t1.fpbid,
       t1.fpbno,
       c.pb_globalnumber, --分期全称
       c.fpbnumber FPBNumber,--分期编码
       c.fpbname pbname, --分期名称
       c.org_id, --组织ID
       c.org_name Company, --项目公司名称
       c.fnumber Connumber, --合同编码
       c.fname CONName, --合同名称
       c.fcontracttype, --合同类型CODE
       c.fcontracttypename, --合同类型名称
       c.fsecondpartyname suppliers, --供应商名称
       c.fismultiblock, --是否跨期
       c.fsharingrule fsharingrule, --分摊原则
       nvl(t1.fnewcost, 0) fnewcost, --最新造价

  --  555 fnewcost,
       nvl(t1.fauditamount, 0) fauditamount, --结算金额
   --   222 fauditamount,

       nvl(t1.FContractAmount, 0) FContractAmount, --合同金额
    -- 333 FContractAmount,
       nvl(t1.FSubContractAmount, 0) FSubContractAmount, --补充协议金额
       nvl(t1.frewardamount, 0) frewardamount, --奖励金额
       nvl(t1.fdebitamount, 0) fdebitamount, --扣款金额
       nvl(t1.fadjustamount, 0) fadjustamount, --调整金额
       t1.fadjustnote, --调整原因
       c.fserviceterm, --质保期限
       nvl(c.fserviceamount, 0) fserviceamount, --质保金额
       nvl(c.fservicebalance, 0) fservicebalance, --质保金余额
     --  nvl(pay.fapplyamount, 0) sumpayamount, --累计已请款

/*       decode(t1.fwflowstate,'00',
(select sum(decode(wp.ffq_flag,'Y',nvl(wp.fapplyamount,0)-nvl(pca.ffq_amount,0),nvl(wp.FApplyAmount,0))) from wpc_paymentapply_t wp
        ,wpc_paymentcheck_apply_t pca
        where wp.FConId =  t1.fconid and pca.fapply_id(+)=wp.fpaid
           and wp.fwflowstate in ('10','20'))
           ,t1.fsumapplyamount) sumpayamount, --累计已请款*/

----begin update by suwenlong 20170707
/*       decode(t1.fwflowstate,'00',
(SELECT sum(nvl(decode(tp2.ffq_flag, 'Y', tp1.fpaidamount, tp1.fapplyamount),0))
          FROM WPC_PaymentApplyDetail_T tp1, WPC_PaymentApply_T tp2
         WHERE tp1.fpaid = tp2.fpaid and tp1.FConId =  t1.fconid
           and tp2.FWFLOWSTATE in  ('10','20'))
           ,t1.fsumapplyamount) sumpayamount, --累计已请款*/
 decode(t1.fwflowstate,'00',
(SELECT nvl(SUM(decode(ffq_flag, 'Y', tp2. FPaidAmount, tp2.FApplyAmount)), 0) FSUMApplyAmount
  FROM  WPC_PaymentApply_T tp2
 WHERE  tp2.fconid =t1.fconid
 and tp2.FWFLOWSTATE in  ('10','20')
       )
,t1.fsumapplyamount) sumpayamount, --累计已请款

----end update by suwenlong 20170707

       (select nvl(sum(ca.famount), 0)
          from WPC_ContractAdvance_T ca
         where ca.fconid = t1.fconid) -
       (select nvl(sum(cr.famount), 0)
          from WPC_ContractRepayment_T cr
         where cr.fconid = t1.fconid) unrepayamount, --财务垫付
       t1.fistemptermine, --是否临时终止
       t1.foperator, --经办人ID
       pe.GLOBAL_NAME operatorname, --经办人姓名
       t1.foperateadmin, --经办部门ID
       op.name foperateadminname, --经办部门名称
       t1.fpostid, --经办岗位
       ps.name fpostname, --经办岗位名称
       t1.fdescription, --说明
       t1.fwflowstate, --流程状态
       wf_approve_pkg.GET_APPROVE_STATUS_NAME(t1.fwflowstate) fwflowstatename, --流程状态
       t1.attribute1,
       t1.attribute2,
       t1.attribute3,
       t1.attribute4,
       t1.attribute5,
       t1.attribute6,
       t1.attribute7,
       t1.attribute8,
       t1.attribute9,
       t1.attribute10,
       t1.attribute11,
       t1.attribute12,
       t1.attribute13,
       t1.attribute14,
       t1.attribute15,
       t1.attribute16,
       t1.attribute17,
       t1.attribute18,
       t1.attribute19,
       t1.attribute20,
       t1.context,
       t1.last_update_date,
       t1.last_updated_by,
       t1.creation_date,
       t1.created_by,
       t1.last_update_login,
       sj_chg.changeamount changeamount,
       qz_chg.visaamount visaamount,
       ot_chg.otherchange otherchange,
       nvl(sj_chg.changeamount, 0) + nvl(qz_chg.visaamount, 0) +
       nvl(ot_chg.otherchange, 0) fchangeamount,
       c.FISSUBCONTRACT,
       t1.fwftype,
       (select sum(fdeductamount) from wpc_servicebalance_input_t where fcontractnumber=c.FNUMBER) fdeductamount,
       flv.MEANING fwftypename
  from wpc_contractsettlement_t t1,
       wpc_contract_v c,
       HR_ORGANIZATION_UNITS op, --经办组织
       WBD_HR_POSITIONS_Effective_V ps, --经办职位
       WBD_HR_PERSON_Effective_V pe, --经办人
       (select cc.fconid, nvl(sum(ccf.fauditamount), 0) visaamount
          from WPC_ChangeContract_t cc,
               WPC_CHANGEVISA_t     cv,
               WPC_ChangeConfirm_T  ccf
         where cv.fcvid = cc.fcvid
           and ccf.fchgconid = cc.fchgconid
           and cv.fwflowstate = '20'
           and ccf.fwflowstate = '20'
           and cv.fchangetype = '10'
         group by cc.fconid) qz_chg, --现场签证
       (select cc.fconid, nvl(sum(cc.fauditamount), 0) changeamount
          from WPC_ChangeContract_t cc,
               WPC_CHANGEVISA_t     cv,
               WPC_ChangeConfirm_T  ccf
         where cv.fcvid = cc.fcvid
           and ccf.fchgconid(+) = cc.fchgconid
           and cv.fwflowstate = '20'
           --and ccf.fwflowstate = '20'
           and cv.fchangetype = '20'
         group by cc.fconid) sj_chg, --设计变更
       (select fconid,decode(fwflowstate,'00',otherchange1,'10',otherchange1,'20',otherchange2,otherchange1) otherchange
 from (select cc.fconid,ccf.fwflowstate,nvl(sum(cc.fauditamount), 0) otherchange1,nvl(sum(ccf.fauditamount), 0) otherchange2
          from WPC_ChangeContract_t cc,
               WPC_CHANGEVISA_t     cv,
               WPC_ChangeConfirm_T  ccf
         where cv.fcvid = cc.fcvid
           and ccf.fchgconid(+) = cc.fchgconid
           and cv.fwflowstate = '20'
           --and ccf.fwflowstate = '20'
           and cv.fchangetype not in ('10', '20')
          -- and cc.fconid=175444
         group by cc.fconid,ccf.fwflowstate) ) ot_chg, --其他变更
       (SELECT fconid, sum(p.fapplyamount) fapplyamount
          FROM Wpc_Paymentapply_t p
         WHERE (p.fwflowstate = '10' or p.fwflowstate = '20')
         GROUP BY p.fconid) pay, --付款申请
         fnd_lookup_values_vl flv
 where t1.fconid = c.fconid
   and t1.foperateadmin = op.organization_id(+) --经办人部门
   and t1.fpostid = ps.position_id(+) --经办职位
   and t1.foperator = pe.PERSON_ID(+) --经办人
   and t1.fconid = qz_chg.fconid(+)
   and t1.fconid = sj_chg.fconid(+)
   and t1.fconid = ot_chg.fconid(+)
   and t1.fconid = pay.fconid(+)
   and t1.fwftype = flv.LOOKUP_CODE(+)
   and flv.LOOKUP_TYPE(+)= 'WPC_CONTRACTSETTLEMENT_WFTYPE'
   and c.FNAME= '时代春树里项目交楼标准装修工程合同'
   ;

SELECT ROW_ID,
       FCSID,
       FCONID,
       FCHANGEAMOUNT,
       FREWARDAMOUNT,
       FDEBITAMOUNT,
       FADJUSTAMOUNT,
       FADJUSTNOTE,
       FISTEMPTERMINE,
       FOPERATOR,
       FOPERATEADMIN,
       FDESCRIPTION,
       ATTRIBUTE1,
       ATTRIBUTE2,
       ATTRIBUTE3,
       ATTRIBUTE4,
       ATTRIBUTE5,
       ATTRIBUTE6,
       ATTRIBUTE7,
       ATTRIBUTE8,
       ATTRIBUTE9,
       ATTRIBUTE10,
       ATTRIBUTE11,
       ATTRIBUTE12,
       ATTRIBUTE13,
       ATTRIBUTE14,
       ATTRIBUTE15,
       ATTRIBUTE16,
       ATTRIBUTE17,
       ATTRIBUTE18,
       ATTRIBUTE19,
       ATTRIBUTE20,
       CONTEXT,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       SUPPLIERS,
       FPBID,
       FPBNO,
       FCONTRACTAMOUNT,
       FSUBCONTRACTAMOUNT,
       FSERVICETERM,
       FSERVICEAMOUNT,
       FSERVICEBALANCE,
       SUMPAYAMOUNT,
       UNREPAYAMOUNT,
       FPRJID,
       FPRJNO,
       FISMULTIBLOCK,
       FSHARINGRULE,
       COMPANY,
       PRJNUMBER,
       PRJNAME,
       PBNAME,
       FNUMBER,
       CONNUMBER,
       CONNAME,
       FSETTLEDATE,
       FAUDITAMOUNT,
       FNEWCOST,
       OPERATORNAME,
       FOPERATEADMINNAME,
       FWFLOWSTATE
  FROM WPC_CONTRACTSETTLEMENT_V
 WHERE (CONNAME = '时代春树里项目交楼标准装修工程合同');
