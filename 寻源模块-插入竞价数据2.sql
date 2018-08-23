--查询标书id
select ctt.tender_book_id
                  from cux_ten_time_control_tmp ctt
                 where ctt.tender_book_number = 'ZB20160050401'


--插入定标行，按比例的修改
select ctm.vendor_name,--供应商名称
ctm.vendor_id,
 ctm.bid_no_tax --竞价不含税价格
  from CUX_TEN_MAT_RESULT_TMP ctm
 where ctm.award_info_id =
       (select ctp.award_info_id
          from CUX_TEN_PRO_INFORMATION_TMP ctp
         where ctp.plan_id =
               (select ctt.plan_id
                  from cux_ten_time_control_tmp ctt
                 where ctt.tender_book_number = 'ZB20160050401')) for update
                 
                 
                 
--插入竞价表
insert into CUX.CUX_PO_BID_PERSONNEL_TMP
  (AUCTION_NUMBER,
   TENDER_NO_TAX,
   TENDER_TAX,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN,
   VENDOR_ID,
   ATTRIBUTE1,
   status,  
   TENDER_UPDATE_ID,
   TENDER_BLIND_ID,
   PLAN_ID)
values
  (1,
  90648395.99,
  106058623.31,
  sysdate,
  -1,
  sysdate,
  -1,
  -1,
  293523,
  'VALID',
  'IN_THE_BIDDING',
  CUX_PO_BID_PERSONNEL_TMP_s.Nextval,
  CUX_CLTEN_PO_VENDOR_TMP_s.Nextval,
  161
  );
  
  
  
  insert into CUX.CUX_PO_BID_PERSONNEL_TMP
  (AUCTION_NUMBER,
   TENDER_NO_TAX,
   TENDER_TAX,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN,
   VENDOR_ID,
   ATTRIBUTE1,
   status,  
   TENDER_UPDATE_ID,
   TENDER_BLIND_ID,
   PLAN_ID)
values
  (1,
  61538461.54,
  72000000,
  sysdate,
  -1,
  sysdate,
  -1,
  -1,
  3491,
  'VALID',
  'IN_THE_BIDDING',
  CUX_PO_BID_PERSONNEL_TMP_s.Nextval,
  CUX_CLTEN_PO_VENDOR_TMP_s.Nextval,
  161
  );
  
  
    insert into CUX.CUX_PO_BID_PERSONNEL_TMP
  (AUCTION_NUMBER,
   TENDER_NO_TAX,
   TENDER_TAX,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN,
   VENDOR_ID,
   ATTRIBUTE1,
   status,  
   TENDER_UPDATE_ID,
   TENDER_BLIND_ID,
   PLAN_ID)
values
  (1,
  55470085.47,
  64900000,
  sysdate,
  -1,
  sysdate,
  -1,
  -1,
  193205,
  'VALID',
  'IN_THE_BIDDING',
  CUX_PO_BID_PERSONNEL_TMP_s.Nextval,
  CUX_CLTEN_PO_VENDOR_TMP_s.Nextval,
  161
  );
  
  
  
   insert into CUX.CUX_PO_BID_PERSONNEL_TMP
  (AUCTION_NUMBER,
   TENDER_NO_TAX,
   TENDER_TAX,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN,
   VENDOR_ID,
   ATTRIBUTE1,
   status,  
   TENDER_UPDATE_ID,
   TENDER_BLIND_ID,
   PLAN_ID)
values
  (1,
  52700854.7,
  61660000,
  sysdate,
  -1,
  sysdate,
  -1,
  -1,
  2149,
  'VALID',
  'IN_THE_BIDDING',
  CUX_PO_BID_PERSONNEL_TMP_s.Nextval,
  CUX_CLTEN_PO_VENDOR_TMP_s.Nextval,
  161
  );



   insert into CUX.CUX_PO_BID_PERSONNEL_TMP
  (AUCTION_NUMBER,
   TENDER_NO_TAX,
   TENDER_TAX,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_LOGIN,
   VENDOR_ID,
   ATTRIBUTE1,
   status,  
   TENDER_UPDATE_ID,
   TENDER_BLIND_ID,
   PLAN_ID)
values
  (1,
  61538461.54,
  67600000,
  sysdate,
  -1,
  sysdate,
  -1,
  -1,
  5404,
  'VALID',
  'IN_THE_BIDDING',
  CUX_PO_BID_PERSONNEL_TMP_s.Nextval,
  CUX_CLTEN_PO_VENDOR_TMP_s.Nextval,
  161
  );
  


--------------------------------------------