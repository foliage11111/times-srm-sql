select a.Fdeptid,--����ID
a.Fpositionid,--��λID
a.Foperator --������ID
 from Wpc_Bom_t    a
where a.fnumber='QD-000493' for update

--��ѯ����ID
select  e.Organization_Id from Hr_All_Organization_Units e  where e.name='ʱ��ˮ������ɽ����Ŀ��(10093)'--172/1093


--��ѯ��λID
select f.Position_Id from Per_All_Positions         f where f.name='�ڳ��ͬ¼��Ա'--253086/73059



--��ѯ������ID
select g.Person_Id  from Per_All_People_f          g  where g.Last_Name='�����'--9999/2478
