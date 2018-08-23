 
--先查出供应商的D
select pv.VENDOR_ID from po_vendors pv where pv.VENDOR_NAME = '广州市承泽科技企业孵化器有限公司'
--若供应商类别为空，则插入数据
insert into CUX.CUX_POS_SUP_QUALIF_INFO(VENDOR_ID,VENDOR_TYPE)  values(314588,1);
commit;

--若供应商类别不为空，则修改数据
update CUX.CUX_POS_SUP_QUALIF_INFO  cps set cps.vendor_type=1
where cps.vendor_id=31532  ;
commit;

--供应商三证信息
select* from cux_pos_sup_qualif_info ;

SELECT pv.vendor_name AS vendorname 
          ,pv.vendor_id AS vendorid 
          ,pv.party_id AS partyid 
          ,pv.segment1 AS segment1 
          ,psm.mapping_id AS mappingid 
          ,hp.duns_number_c AS dunsnumberc 
          ,hp.province AS province 
          ,hp.city AS city 
          ,hp.county AS county 
          ,hp.address1 AS address 
          ,hp.known_as AS hzpartyalias 
          ,pv.num_1099 AS taxpayerid 
          ,decode(pv.federal_reportable_flag, 
                  'Y', 
                  ait.description, 
                  'y', 
                  ait.description, 
                  '') AS type1099 
          ,zptp.country_code AS taxcountrycode 
          ,pv.attribute3
          ,cpsq.vendor_category 
          ,flv.meaning vendor_status 
          ,cpsq.license_num licensenum 
          ,cpsq.legal_rep_name legalrepname 
          ,cpsq.sup_org_code suporgcode 
          ,cpsq.tax_reg_num taxregnum 
          ,cpsq.is_unify_flag 
          ,cpsq.supplier_short_name 
          ,cpsq.org_type
          ,cpsq.org_type_dsp
          ,cpsq.vendor_category_dsp 
          ,cpsq.affiliated_vendor_id 
          ,cpsq.vendor_name affiliated_vendor_name 
          ,cpsq.administator_count 
          ,cpsq.skill_worker_count 
          ,cpsq.employee_sum 
          ,cpsq.bank_account_name 
          ,cpsq.bank_account_number 
          ,cpsq.bank_branch_name 
    FROM  ap_suppliers pv 
          ,pos_supplier_mappings psm 
          ,hz_parties hp 
          ,ap_income_tax_types ait 
          ,zx_party_tax_profile zptp 
          ,(SELECT cpsqi.vendor_id 
                  ,cpsqi.license_num 
                  ,cpsqi.legal_rep_name 
                  ,cpsqi.sup_org_code 
                  ,cpsqi.tax_reg_num 
                  ,cpsqi.is_unify_flag 
                  ,cpsqi.supplier_short_name 
                  ,cpsqi.vendor_type          vendor_category 
                  ,cpsqi.affiliated_vendor_id 
                  ,cpsqi.administator_count 
                  ,cpsqi.skill_worker_count 
                  ,cpsqi.employee_sum 
                  ,affiliate.vendor_name 
                  ,cpsqi.org_type
                  ,flv.meaning                org_type_dsp 
                  ,flv1.meaning               vendor_category_dsp 
                  ,cpsqi.bank_account_name 
                  ,cpsqi.bank_account_number 
                  ,cpsqi.bank_branch_name 
            FROM  cux_pos_sup_qualif_info cpsqi 
                  ,ap_suppliers            affiliate 
                  ,fnd_lookup_values_vl    flv 
                  ,fnd_lookup_values_vl    flv1 
            WHERE  affiliate.vendor_id(+) = cpsqi.affiliated_vendor_id 
            AND    flv.lookup_type(+) = 'CUX_FILE_COMPANY_TYPE' 
            AND    flv.lookup_code(+) =cpsqi.org_type
            AND    flv1.lookup_type(+) = 'CUX_FILE_SUPPLIER_TYPE' 
            AND    flv1.lookup_code(+) = cpsqi.vendor_type) cpsq 
          ,fnd_lookup_values_vl flv 
    WHERE  pv.vendor_id = cpsq.vendor_id(+) 
    AND    hp.party_id = pv.party_id 
    AND    psm.vendor_id(+) = pv.vendor_id 
    AND    ait.income_tax_type(+) = pv.type_1099 
    AND    zptp.party_id(+) = pv.party_id 
    AND    zptp.party_type_code(+) = 'THIRD_PARTY' 
    AND    zptp.rep_registration_number(+) = pv.vat_registration_num 
    AND    flv.lookup_type(+) = 'CUX_VENDOR_STATUS' 
    AND    flv.lookup_code(+) = pv.attribute3
    and pv.segment1='902208'
 		;