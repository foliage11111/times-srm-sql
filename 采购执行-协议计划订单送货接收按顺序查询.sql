---协议计划订单送货接收按顺序查询
--送货部分可能会导致重复，因为一个订单可能多次送货。

SELECT cpph.plan_number 计划编号
       -- ,cpph.org_id
      ,hou.name         组织名称
      ,cpph.version_num 计划版本
      ,cpph.plan_status
       --  ,cpph.plan_type
      ,cpph.plan_name
       --  ,cpph.last_update_date
       -- ,cpph.operator_id
      ,fu.user_name
       --   ,pha.last_update_date
      ,pha.segment1             订单编号
      ,pha.authorization_status
       --  ,pha.cancel_flag
       -- ,cppl.ag_header_id
      ,pha2.segment1 协议编号
       --  ,cppl.ag_line_id
       --  ,pla.attribute9
      ,pv.vendor_name 供应商名称
       -- ,pv.vendor_id
       --  ,pha.po_header_id
       --  ,pla.item_id
      ,msib.segment1           物料编码
      ,pla.item_description    物料描述
      ,cppl.quantity           计划数量
      ,pla.attribute10         协议区域
      ,pla2.unit_price         协议不含税价
      ,pha2.attribute6         协议税率
      ,pla2.attribute11        协议含税价
      ,cppl.unit_price         计划价格
      ,pla.quantity            计划价格
      ,pla.unit_price          订单不含税价
      ,pla.attribute11         订单含税价
      ,cdhi.deliver_code       送货单号
      ,cdhi.approve_code       送货单状态
      ,cdli.delivery_lines_id  送货行d
      ,cdli.delivery_count     送货数量
      ,cprh.shipment_header_id 接收头
      ,cprh.receipt_num        接收号
      ,cprh.delivery_number    接收到货号
      ,cprh.approve_code       接收状态
      ,cprl.line_number 接收行号
      ,cprl.quantity_receiving 接收订单数量
   
 
FROM   po.po_headers_all         pha
      ,po.po_lines_all           pla
      ,fnd_user                  fu
      ,po_vendors                pv
      ,apps.mtl_system_items_b   msib
      ,cux.cux_pr_plan_headers   cpph
      ,cux.cux_pr_plan_lines     cppl
      ,po.po_headers_all         pha2
      ,po.po_lines_all           pla2
      ,hr_organization_units     hou
      ,po_line_locations_all     plla
      ,cux_delivery_headers_info cdhi
      ,cux_delivery_lines_info   cdli
      ,cux_po_receive_headers    cprh
      ,cux_po_receive_lines      cprl
   
WHERE  pla.po_header_id = pha.po_header_id
AND    pha.po_header_id = plla.po_header_id
AND    pla.po_line_id = plla.po_line_id
AND    cpph.header_id = cppl.header_id
AND    pla.attribute5 = cppl.line_id
AND    pha.type_lookup_code = 'STANDARD'
AND    pha2.po_header_id = cppl.ag_header_id
AND    pla2.po_line_id(+) = cppl.ag_line_id
AND    msib.inventory_item_id = pla.item_id
AND    cpph.operator_id = fu.user_id(+)
AND    cpph.org_id = hou.organization_id(+)
AND    msib.organization_id = 460
AND    pv.vendor_id = pha.vendor_id
      --and msib.segment1='3019110010000001'  --根据物料
AND    pha.segment1 = '2017003071' --PO
      
      --and pha2.segment1='2017000893'      ----根据协议
      --and cpph.plan_number='S201710246'
      --and pla.item_description like '%%'
      --and cpph.org_id=2153
AND    cdhi.po_header_id(+) = pha.po_header_id
AND    cdli.po_location_id(+) = plla.line_location_id
AND    cprh.po_header_id(+) = pha.po_header_id
 AND    cprl.line_location_id(+) = plla.line_location_id
