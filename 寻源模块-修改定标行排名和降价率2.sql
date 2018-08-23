
--如果后台插入调整价的时候，二次议价。
declare
  cursor csr_bid is
    select bid.award_bid_id,
           bid.down_rate,
           rank() over(order by bid.down_rate desc) rank1
    
      from (select ctm.quality,
                   ctm.price_rank,
                   ctm.award_bid_id,
                   saaf_generate_tender_code.getAdjustPrice(ctm.vendor_id,
                                                            ctp1.plan_id,
                                                            '111') adjust_price,
                   ctp1.no_tax_money,
                   round((ctp1.no_tax_money -
                         saaf_generate_tender_code.getAdjustPrice(ctm.vendor_id,
                                                                   ctp1.plan_id,
                                                                   '111')) /
                         ctp1.no_tax_money,
                         2) * 100 down_rate
              from CUX_TEN_MAT_RESULT_TMP      ctm,
                   CUX_TEN_PRO_INFORMATION_TMP ctp1
             where ctm.award_info_id =
                   (select ctp.award_info_id
                      from CUX_TEN_PRO_INFORMATION_TMP ctp
                     where ctp.plan_id =
                           (select ctt.plan_id
                              from cux_ten_time_control_tmp ctt
                             where ctt.tender_book_number = 'ZB20160050401'))--需要填写的标书编号
               and ctm.award_info_id = ctp1.award_info_id
               and ctm.price_rank <> 0) bid
     where 1 = 1;
  i NUMBER;

begin
  i := 0;

  for rec_bid in csr_bid loop
    i := i + 1;
    update CUX_TEN_MAT_RESULT_TMP ctm
       set ctm.down_rate = rec_bid.down_rate, ctm.price_rank = rec_bid.rank1
     where ctm.award_bid_id = rec_bid.award_bid_id;
    dbms_output.put_line(i);
  end loop;
end;






--筛入了竞价的时候，等比例下调
declare
  cursor csr_bid is
    select bid.award_bid_id,
           bid.down_rate,
           rank() over(order by bid.down_rate desc) rank1
    
      from (select ctm.quality,
                   ctm.price_rank,
                   ctm.award_bid_id,
                   saaf_generate_tender_code.getBidPrice(ctm.vendor_id,
                                                            161) adjust_price,
                   ctp1.no_tax_money,
                   round((ctp1.no_tax_money -
                         saaf_generate_tender_code.getBidPrice(ctm.vendor_id,
                                                                   161)) /   --标书的id
                         ctp1.no_tax_money,
                         2) * 100 down_rate
              from CUX_TEN_MAT_RESULT_TMP      ctm,
                   CUX_TEN_PRO_INFORMATION_TMP ctp1
             where ctm.award_info_id =
                   (select ctp.award_info_id
                      from CUX_TEN_PRO_INFORMATION_TMP ctp
                     where ctp.plan_id =
                           (select ctt.plan_id
                              from cux_ten_time_control_tmp ctt
                             where ctt.tender_book_number = 'ZB20160050401'))----需要填写的标书编号
               and ctm.award_info_id = ctp1.award_info_id
               and ctm.price_rank <> 0) bid
     where 1 = 1;
  i NUMBER;

begin
  i := 0;

  for rec_bid in csr_bid loop
    i := i + 1;
    update CUX_TEN_MAT_RESULT_TMP ctm
       set ctm.down_rate = rec_bid.down_rate, ctm.price_rank = rec_bid.rank1
     where ctm.award_bid_id = rec_bid.award_bid_id;
    dbms_output.put_line(i);
  end loop;
end;

