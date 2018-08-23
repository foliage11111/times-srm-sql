



create table pos_supplier_mappings20161122 as
select * from pos_supplier_mappings psm;


select * from pos_supplier_mappings20161122


DECLARE
  l_number   NUMBER;
  rec_header pos_supplier_mappings%ROWTYPE;
  CURSOR csr_psm IS
    SELECT pv.vendor_id
          ,pv.party_id
    FROM   ap_suppliers pv
    WHERE  1 = 1
    AND    NOT EXISTS (SELECT 1
            FROM   pos_supplier_mappings psm
            WHERE  1 = 1
            AND    psm.vendor_id = pv.vendor_id);

BEGIN
  l_number := 0;
  FOR rec_psm IN csr_psm LOOP
    SELECT pos_supplier_mapping_s.nextval INTO l_number FROM dual;
    rec_header.mapping_id        := l_number;
    rec_header.party_id          := rec_psm.party_id;
    rec_header.vendor_id         := rec_psm.vendor_id;
    rec_header.last_update_date  := SYSDATE;
    rec_header.last_updated_by   := -1;
    rec_header.last_update_login := -1;
    rec_header.creation_date     := SYSDATE;
    rec_header.created_by        := -1;
    INSERT INTO pos_supplier_mappings VALUES rec_header;
  END LOOP;

  COMMIT;
END;
