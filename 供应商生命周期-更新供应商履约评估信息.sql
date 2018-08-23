--���¹�Ӧ����Լ������Ϣ

--��ѯ��Ӧ��ID

SELECT t.vendor_id   ��Ӧ��id
      ,t.segment1    ��Ӧ�̱��
      ,t.vendor_name ��Ӧ������
  FROM po_vendors t
 WHERE t.vendor_name LIKE '�㶫�����������������޹�˾';



--1.�Ȱ�����д����ʱ��cux_po_vendors_scores��

 select * from cux_po_vendors_scores order by imp_id desc for update ;
 

--����������ֵ�ķ�ʽ 
insert into cux_po_vendors_scores
(imp_id,vendor_id,vendor_name,eng_score,material_score,level_date,flag)
values(704,308466,'�㶫�����������������޹�˾',83.74,null,'2017-2-14','N') ;

/*vendor_id ��Ӧ��ID                       
vendor_name ��Ӧ������
eng_score ���̷�
material_score ���Ϸ�
level_date �ȼ���Ч��
flag �Ƿ��Ѵ�����N */
 


--2.���ݹ�Ӧ������

CREATE TABLE po_vendors_17071301 AS
  SELECT *
    FROM po_vendors pv
   WHERE EXISTS (SELECT 1
            FROM cux.cux_po_vendors_scores t
           WHERE pv.vendor_id = t.vendor_id
             AND t.flag = 'N');           
-- 3��test��ִ�нű�
DECLARE

  l_score          NUMBER;
  l_review_score   NUMBER;
  l_vendor_score   NUMBER;
  l_vendor_status  VARCHAR2(100);
  l_insp_mat_score NUMBER;
  l_insp_eng_score NUMBER;

BEGIN

  FOR r1 IN (SELECT t.rowid
                   ,t.vendor_id
                   ,t.vendor_name
                   ,t.eng_score
                   ,t.material_score
                   ,t.level_date
                   ,t.vendor_status
                   ,t.remark
               FROM cux_po_vendors_scores t
              WHERE trunc(t.creation_date) = trunc(SYSDATE)
                AND t.flag = 'N') LOOP
  
    l_vendor_score := greatest(to_number(nvl(r1.eng_score
                                            ,0))
                              ,to_number(nvl(r1.material_score
                                            ,0)));
    dbms_output.put_line('����Ӧ��:'||r1.vendor_name||to_char(r1.eng_score)||to_char(r1.material_score)||to_char(r1.vendor_status));
    SELECT flv.lookup_code
      INTO l_vendor_status
      FROM fnd_lookup_values_vl flv
     WHERE flv.lookup_type = 'CUX_VENDOR_STATUS'
       AND nvl(to_number(flv.attribute1)
              ,0) <= l_vendor_score
       AND nvl(to_number(flv.attribute2)
              ,100) > l_vendor_score
       AND (flv.attribute1 IS NOT NULL OR flv.attribute2 IS NOT NULL);
  
    UPDATE po_vendors pv
       SET pv.attribute3 = l_vendor_status
          ,pv.attribute7 = r1.level_date
          ,pv.attribute8 = r1.eng_score
          ,pv.attribute9 = r1.material_score
     WHERE pv.vendor_id = r1.vendor_id;
  
    UPDATE cux_po_vendors_scores t
       SET t.flag = 'Y'
     WHERE t.rowid = r1.rowid;
  
  END LOOP;
  COMMIT;
END;



