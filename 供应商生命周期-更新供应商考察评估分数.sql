DECLARE

  l_score          NUMBER;
  l_review_score   NUMBER;
  l_vendor_status  VARCHAR2(100);
  l_insp_mat_score NUMBER;
  l_insp_eng_score NUMBER;

BEGIN

  BEGIN
    SELECT fnd_profile.value('CUX_SLC_ASS_SCORE')
    INTO   l_review_score
    FROM   dual;
  EXCEPTION
    WHEN OTHERS THEN
      l_review_score := 0;
  END;

  FOR r1 IN (SELECT t.vendor_id
                   ,t.vendor_name
                   ,t.eng_score
                   ,t.material_score
                   ,t.level_date
                   ,t.vendor_status
                   ,t.remark
             FROM   cux_po_vendors_scores t
             WHERE  t.flag = 'N') LOOP
  
    BEGIN
      SELECT pv.attribute3
      INTO   l_vendor_status
      FROM   po_vendors pv
      WHERE  pv.vendor_id = r1.vendor_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_vendor_status := NULL;
    END;
  
    IF to_number(r1.material_score) >= l_review_score
       OR to_number(r1.eng_score) >= l_review_score THEN
      IF l_vendor_status = 'INVESTIGATE' THEN
        /*待考察*/
        IF r1.eng_score IS NULL THEN
          /*材料*/
          UPDATE po_vendors pv
          SET    pv.attribute3 = 'ALTERNATIVE'
                ,pv.attribute9 = r1.material_score
                ,pv.attribute7 = r1.level_date
          WHERE  pv.vendor_id = r1.vendor_id;
        ELSE
          /*工程*/
          UPDATE po_vendors pv
          SET    pv.attribute3 = 'ALTERNATIVE'
                ,pv.attribute8 = r1.eng_score
                ,pv.attribute7 = r1.level_date
          WHERE  pv.vendor_id = r1.vendor_id;
        END IF;
      ELSIF l_vendor_status = 'ALTERNATIVE' THEN
        /*备选*/
        IF r1.eng_score is null THEN
          /*材料*/
          -- 获取原评估分数
          BEGIN
            SELECT pv.attribute9
            INTO   l_insp_mat_score
            FROM   po_vendors pv
            WHERE  pv.vendor_id = r1.vendor_id;
          EXCEPTION
            WHEN OTHERS THEN
              l_insp_mat_score := 0;
          END;
          -- 如果评估分数大于原来的更新，否则不更新
          IF to_number(r1.material_score) > to_number(l_insp_mat_score) THEN
            UPDATE po_vendors pv
            SET    pv.attribute7 = r1.level_date
                  ,pv.attribute9 = r1.material_score
            WHERE  pv.vendor_id = r1.vendor_id;
          ELSE
            UPDATE po_vendors pv
            SET    pv.attribute7 = r1.level_date
            WHERE  pv.vendor_id = r1.vendor_id;
          END IF;
        ELSE
          /*工程*/
          -- 获取原评估分数
          BEGIN
            SELECT pv.attribute8
            INTO   l_insp_eng_score
            FROM   po_vendors pv
            WHERE  pv.vendor_id = r1.vendor_id;
          EXCEPTION
            WHEN OTHERS THEN
              l_insp_eng_score := 0;
          END;
          -- 如果评估分数大于原来的更新，否则不更新
          IF to_number(r1.eng_score) > to_number(l_insp_eng_score) THEN
            UPDATE po_vendors pv
            SET    pv.attribute7 = r1.level_date
                  ,pv.attribute8 = r1.eng_score
            WHERE  pv.vendor_id = r1.vendor_id;
          ELSE
            UPDATE po_vendors pv
            SET    pv.attribute7 = r1.level_date
            WHERE  pv.vendor_id = r1.vendor_id;
          END IF;
        END IF;
      END IF;
    
      UPDATE cux_po_vendors_scores t
      SET    t.flag = 'Y'
      WHERE  t.vendor_id = r1.vendor_id;
    END IF;
  
  END LOOP;
  COMMIT;
END;
