SELECT wb.fpbno,wb.*
FROM   wbd.wbd_project_t      wt
      ,wbd.wbd_projectblock_t wb
WHERE  wb.fprjid = wt.fprjid
AND    wt.fiseffective = '1'
AND    wb.fname = '佛山海三路项目一期';
