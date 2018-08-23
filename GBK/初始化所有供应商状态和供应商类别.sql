--更新供应商状态和供应商类别
declare
  cursor csr_vendor is
    SELECT pv.attribute3,
           pv.attribute7,
           pv.attribute8,
           pv.attribute9,
           pv.vendor_name,
           pv.vendor_id,
           pv.segment1         vendor_code,
           flv.meaning         vendor_status,
           flv.lookup_code     vendor_status_code,
           ventype.meaning     vendor_type_name,
           ventype.lookup_code vendor_type_code
           /*  ,vencat.concatenated_segments cate_code
           ,vencat.description cate_desp*/,
           to_char(pv.creation_date, 'yyyy-mm-dd') creation_date,
           pv.party_id
      FROM po_vendors pv,
           fnd_lookup_values flv,
           (SELECT cpsi.vendor_id,
                   cpsi.vendor_type,
                   flv.lookup_code,
                   flv.meaning
              FROM cux_pos_sup_qualif_info cpsi, fnd_lookup_values flv
             WHERE cpsi.vendor_type = flv.lookup_code
               AND flv.lookup_type = 'CUX_FILE_SUPPLIER_TYPE'
               AND flv.language = userenv('LANG')
               AND flv.start_date_active <= SYSDATE
               AND nvl(flv.end_date_active, SYSDATE) >= SYSDATE) ventype
    /* ,(SELECT cpsr.vendor_id
          ,cmc.concatenated_segments concatenated_segments
          ,cpsr.status
          ,cpsr.remark
          ,cmc.description
          ,flv.meaning               status_dsp
          ,cmc.segment2_description
    FROM   cux.cux_pos_supp_category cpsr
          ,cux_mtl_second_category_v cmc
          ,fnd_lookup_values_vl      flv
    WHERE  cmc.segment1 = cpsr.segment1
    AND    cmc.segment2 = cpsr.segment2
    AND    flv.lookup_type = 'CUX_COOPERATION_STATUS'
    AND    flv.lookup_code = nvl(cpsr.status, 'NO')
    AND    cpsr.data_type = '2') vencat*/
     WHERE pv.attribute3 = flv.lookup_code(+)
       AND flv.language(+) = userenv('LANG')
       AND flv.lookup_type(+) = 'CUX_VENDOR_STATUS'
       AND pv.vendor_id = ventype.vendor_id(+);

  l_vendor_type_name varchar2(240);
  l_vendor_type      varchar2(240);
  l_count            number;
  l_count1           NUMBER;
begin

  for rec_vendor in csr_vendor loop
    --更新供应商状态
    if (rec_vendor.vendor_status is null) then
      update AP_SUPPLIERS ass
         set ass.attribute3 = 'INVESTIGATE'
       where ass.vendor_id = rec_vendor.vendor_id;
      commit;
    end if;
    begin
      select count(1)
        into l_count1
        from CUX.CUX_POS_SUP_QUALIF_INFO cps
       where cps.vendor_id = rec_vendor.vendor_id;
    exception
      when others then
        l_count1 := null;
    end;
    --更新供应商类别
    if (rec_vendor.vendor_type_name is null) then
      if (l_count1 <> 1) then
        insert into CUX.CUX_POS_SUP_QUALIF_INFO
          (VENDOR_ID, VENDOR_TYPE)
        values
          (rec_vendor.vendor_id, 1);
        commit;
      end if;
      if (l_count1 = 1) then
        update CUX.CUX_POS_SUP_QUALIF_INFO cps
           set cps.vendor_type = 1
         where cps.vendor_id = rec_vendor.vendor_id;
                                                          commit;
      end if;
      begin
        select wvv.vendortypename
          into l_vendor_type_name
          from wbd_vendorinfo_v wvv
         where wvv.FVENDOR_ID = rec_vendor.vendor_id;
      exception
        when others then
          l_vendor_type_name := null;
      end;
    
      if (l_vendor_type_name = '服务类') then
        l_vendor_type := 1;
      end if;
      if (l_vendor_type_name = '供货类') then
        l_vendor_type := 2;
      end if;
      if (l_vendor_type_name = '施工类') then
        l_vendor_type := 3;
      end if;
      begin
        select count(1)
          into l_count
          from wbd_vendorinfo_v wvv
         where wvv.FVENDOR_ID = rec_vendor.vendor_id;
      exception
        when others then
          l_count := null;
      end;
      if (l_count = 1) then
        update CUX.CUX_POS_SUP_QUALIF_INFO cps
           set cps.vendor_type = l_vendor_type
         where cps.vendor_id = rec_vendor.vendor_id;
        commit;
      end if;
    end if;
  end loop;
end;
