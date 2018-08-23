
select a.Fdeptid,--部门ID
a.Fpositionid,--岗位ID
a.Foperator --经办人ID
 from Wpc_Bom_t    a
where a.fnumber='QD-000493' for update

;

--查询部门ID
select  e.Organization_Id from Hr_All_Organization_Units e  where e.name='时代水岸（佛山）项目部(10093)'--172/1093

;
--查询岗位ID
select f.Position_Id from Per_All_Positions         f where f.name='泌冲合同录入员'--253086/73059

;

--查询经办人ID
select g.Person_Id  from Per_All_People_f          g  where g.Last_Name='余家珍'--9999/2478
;