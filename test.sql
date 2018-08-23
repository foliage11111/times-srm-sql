SELECT mck.category_id
      ,fnd_flex_ext.get_segs('INV',
                             'MCAT',
                             mck.structure_id,
                             mck.category_id) concatenated_segments
      ,mc.description
FROM   mtl_categories_kfv        mck
      ,mtl_category_sets         mcs
      ,mtl_default_category_sets mdcs
      ,mtl_categories            mc
WHERE  mck.enabled_flag = 'Y'
AND    SYSDATE BETWEEN nvl(mck.start_date_active, SYSDATE) AND
       nvl(mck.end_date_active, SYSDATE)
AND    mcs.category_set_id = mdcs.category_set_id
AND    mdcs.functional_area_id = 2 --²É¹º·ÖÀà
AND    mck.structure_id = mcs.structure_id
AND    nvl(mck.disable_date, SYSDATE + 1) > SYSDATE
AND    (mcs.validate_flag = 'Y' AND
      mck.category_id IN
      (SELECT mcsv.category_id
         FROM   mtl_category_set_valid_cats mcsv
         WHERE  mcsv.category_set_id = mcs.category_set_id) OR
      mcs.validate_flag <> 'Y')
AND    mck.category_id = mc.category_id
AND    mc.description LIKE '%PVC%';
