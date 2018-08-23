DECLARE
  CURSOR csr_headers IS
    SELECT DISTINCT cpb.org_name
                   ,cpb.po_number
                   ,cpb.vendor_name
                   ,cpb.vendor_site_name
                   ,cpb.agent_name
    FROM   cux_po_blanket_headers cpb
    WHERE  1 = 1
    AND    (cpb.status <> 'S' OR cpb.status IS NULL);

  --行数据
  CURSOR csr_lines(p_po_number IN NUMBER) IS
    SELECT cpb.item_code
          ,cpb.unit_price
          ,cpb.uom_code
          ,cpb.area_name
    FROM   cux_po_blanket_headers cpb
    WHERE  1 = 1
    AND    cpb.po_number = p_po_number
    AND    (cpb.status <> 'S' OR cpb.status IS NULL);

  l_org_id         NUMBER;
  l_vendor_id      NUMBER;
  l_vendor_site_id NUMBER;
  l_agent_id       NUMBER;
  l_person_id      NUMBER;

  l_item_id NUMBER;

  l_iface_rec        po.po_headers_interface%ROWTYPE;
  l_iface_lines_rec  po.po_lines_interface%ROWTYPE;
  l_line_number      NUMBER;
  v_request_id       NUMBER;
  l_return_msg       VARCHAR2(240);
  l_primary_uom_code VARCHAR2(240);
  v_count            NUMBER;
  l_po_count         NUMBER;
  l_description      VARCHAR2(240);
  l_count            NUMBER;
BEGIN

  l_line_number := 0;
  FOR rec_headers IN csr_headers LOOP
  
    /*获取org_id*/
    BEGIN
      SELECT hou.organization_id
      INTO   l_org_id
      FROM   hr_operating_units hou
      WHERE  hou.name = rec_headers.org_name;
    EXCEPTION
      WHEN OTHERS THEN
        l_org_id := NULL;
    END;
    /*获取vendor_id*/
    BEGIN
      SELECT pv.vendor_id
      INTO   l_vendor_id
      FROM   po_vendors pv
      WHERE  pv.vendor_name = rec_headers.vendor_name;
    EXCEPTION
      WHEN OTHERS THEN
        l_vendor_id := NULL;
    END;
 /*   l_vendor_id:=321;*/
  
    /*获取vendor_site_id*/
    BEGIN
      SELECT pvs.vendor_site_id
      INTO   l_vendor_site_id
      FROM   po_vendor_sites_all pvs
      WHERE  pvs.vendor_id = l_vendor_id
      AND    pvs.org_id = l_org_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_vendor_site_id := NULL;
    END;
  
    /*获取agent_id*/
    BEGIN
      SELECT ppf.person_id
      INTO   l_person_id
      FROM   per_all_people_f ppf
      WHERE  ppf.full_name = rec_headers.agent_name;
    EXCEPTION
      WHEN OTHERS THEN
        l_person_id := NULL;
    END;
  
    SELECT po_headers_interface_s.nextval
    INTO   l_iface_rec.interface_header_id
    FROM   dual;
    SELECT cux_tender_material_s.nextval
    INTO   l_iface_rec.batch_id
    FROM   dual;
  
    l_iface_rec.org_id                := l_org_id;
    l_iface_rec.process_code          := 'PENDING';
    l_iface_rec.action                := 'UPDATE';
    l_iface_rec.document_type_code    := 'BLANKET';
    l_iface_rec.document_subtype      := NULL;
    l_iface_rec.document_num          := rec_headers.po_number;
    l_iface_rec.approval_status       := 'APPROVED';
    l_iface_rec.agent_id              := l_person_id;
    l_iface_rec.vendor_id             := l_vendor_id;
    l_iface_rec.vendor_site_id        := l_vendor_site_id;
    l_iface_rec.interface_source_code := 'Test Only';
    l_iface_rec.global_agreement_flag := 'Y';
    l_iface_rec.creation_date         := SYSDATE;
    l_iface_rec.created_by            := -1;
    l_iface_rec.last_update_date      := SYSDATE;
    l_iface_rec.last_updated_by       := -1;
    l_iface_rec.last_update_login     := -1;
    INSERT INTO po.po_headers_interface VALUES l_iface_rec;
  
    --导入行
    FOR rec_lines IN csr_lines(rec_headers.po_number) LOOP
      --获取行的单位
      BEGIN
        SELECT muo.uom_code
        INTO   l_primary_uom_code
        FROM   mtl_units_of_measure_vl muo
        WHERE  1 = 1
        AND    muo.unit_of_measure = rec_lines.uom_code;
      EXCEPTION
        WHEN OTHERS THEN
          l_primary_uom_code := NULL;
      END;
      --获取物料ID
      BEGIN
        SELECT msib.inventory_item_id
        INTO   l_item_id
        FROM   mtl_system_items_b msib
        WHERE  msib.segment1 = rec_lines.item_code
        AND    rownum = 1;
      EXCEPTION
        WHEN OTHERS THEN
          l_item_id := NULL;
      END;
    
      --获取物料描述
      BEGIN
        SELECT msib.long_description
        INTO   l_description
        FROM   mtl_system_items_fvl msib
        WHERE  msib.inventory_item_id = l_item_id
        AND    rownum = 1;
      EXCEPTION
        WHEN OTHERS THEN
          l_description := NULL;
      END;
      l_iface_lines_rec.interface_header_id := l_iface_rec.interface_header_id;
      l_iface_lines_rec.process_code        := 'PENDING';
      l_iface_lines_rec.action              := 'ADD';
      l_line_number                         := l_line_number + 1;
      l_iface_lines_rec.line_num            := l_line_number;
      -- l_iface_lines_rec.uom_code            := l_Primary_Uom_Code;
      l_iface_lines_rec.item_id := l_item_id;
      --l_iface_lines_rec.category_id         := rec_lines.category_id;
      l_iface_lines_rec.item_description := l_description;
      l_iface_lines_rec.unit_price       := rec_lines.unit_price;
      l_iface_lines_rec.line_attribute10 := rec_lines.area_name;
      SELECT po_lines_interface_s.nextval
      INTO   l_iface_lines_rec.interface_line_id
      FROM   dual;
      INSERT INTO po_lines_interface VALUES l_iface_lines_rec;
    
    END LOOP;
  
    --初始化环境
    fnd_global.apps_initialize(user_id      => 8645,
                               resp_id      => 53386,
                               resp_appl_id => 201);
                               
                       
    mo_global.init('PO');
  
    po_docs_interface_sv5.process_po_headers_interface(x_selected_batch_id          => l_iface_rec.batch_id,
                                                       x_buyer_id                   => NULL,
                                                       x_document_type              => l_iface_rec.document_type_code,
                                                       x_document_subtype           => l_iface_rec.document_subtype,
                                                       x_create_items               => 'N',
                                                       x_create_sourcing_rules_flag => 'N',
                                                       x_rel_gen_method             => NULL,
                                                       x_approved_status            => l_iface_rec.approval_status,
                                                       x_commit_interval            => 1,
                                                       x_process_code               => 'PENDING',
                                                       x_interface_header_id        => l_iface_rec.interface_header_id,
                                                       x_org_id_param               => l_iface_rec.org_id,
                                                       x_ga_flag                    => NULL);
    BEGIN
      SELECT COUNT(1)
      INTO   l_count
      FROM   po_headers_all poh
      WHERE  1 = 1
      AND    poh.segment1 = rec_headers.po_number
      AND    rownum = 1;
    EXCEPTION
      WHEN OTHERS THEN
        l_count := NULL;
    END;
  
    IF l_count = 1 THEN
      UPDATE cux_po_blanket_headers cpb
      SET    cpb.status = 'S'
      WHERE  cpb.po_number = rec_headers.po_number;
      COMMIT;
    END IF;
  END LOOP;

END;
