
SELECT MCK.CATEGORY_ID
      ,FND_FLEX_EXT.GET_SEGS('INV'
                            ,'MCAT'
                            ,MCK.STRUCTURE_ID
                            ,MCK.CATEGORY_ID) CONCATENATED_SEGMENTS
      ,MC.DESCRIPTION
FROM   MTL_CATEGORIES_KFV        MCK
      ,MTL_CATEGORY_SETS         MCS
      ,MTL_DEFAULT_CATEGORY_SETS MDCS
      ,MTL_CATEGORIES            MC
WHERE  MCK.ENABLED_FLAG = 'Y'
AND    SYSDATE BETWEEN NVL(MCK.START_DATE_ACTIVE, SYSDATE) AND
       NVL(MCK.END_DATE_ACTIVE, SYSDATE)
AND    MCS.CATEGORY_SET_ID = MDCS.CATEGORY_SET_ID
AND    MDCS.FUNCTIONAL_AREA_ID = 2 --�ɹ�����
AND    MCK.STRUCTURE_ID = MCS.STRUCTURE_ID
AND    NVL(MCK.DISABLE_DATE, SYSDATE + 1) > SYSDATE
AND    (MCS.VALIDATE_FLAG = 'Y' AND
      MCK.CATEGORY_ID IN
      (SELECT MCSV.CATEGORY_ID
         FROM   MTL_CATEGORY_SET_VALID_CATS MCSV
         WHERE  MCSV.CATEGORY_SET_ID = MCS.CATEGORY_SET_ID) OR
      MCS.VALIDATE_FLAG <> 'Y')
AND    MCK.CATEGORY_ID = MC.CATEGORY_ID;
