--��ѯ��ͬģ��
select cth.fhcontid from  WPC_ContTempHeader_T cth where cth.fhname='�ܰ���ͬ���Ϲ��ɰ�';--2406
select * from WPC_ContTempHeader_T cth where cth.fhname='��¶-������Ƶ���2016';--2385
select cth.fhcontid from  WPC_ContTempHeader_T cth where cth.fhname='��������ģ��';--2422
select * from  WPC_ContTempHeader_T cth where cth.fhname='԰�ֹ���ʩ����ͬ2016��';--2412
select * from  WPC_ContTempHeader_T cth where cth.fhname='������װ�ܰ���ͬ(�ǹҿ�)';--2396

--��ѯ�����嵥
select  bom.fbomid from wpc_bom_t bom  where bom.fname='������Ŀ�����ˮ��׹������嵥';--2467
select  bom.fbomid from wpc_bom_t bom  where bom.fnumber='QD-000605';--2568

--�޸ĺ�ͬģ��
select  T1.Fhcontid,--��ͬģ��ID
t1.fbomid --�����嵥ID
 from wpc_contract_t T1  where  T1.FNUMBER='gz01.SDSQ.01-԰�ֹ�����-2016-0010' for update

select  T1.Fhcontid,--��ͬģ��ID
t1.fbomid --�����嵥ID
 from wpc_contract_t T1  where  T1.Fname='��ݸʯ��ˮ������Ŀһ��������װ���̺�ͬ' for update
 
 
 
 
