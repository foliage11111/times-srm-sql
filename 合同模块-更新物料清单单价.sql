Select a.fprice,a.fprdid,(select b.fnumber from Wbd_Material_t b where a.Fprdid = b.Fprdid)
  From Wpc_Bomlist_t a
--,Wbd_Material_t b
 Where --a.Fprdid = b.Fprdid
 1 = 1
 And a.Ftype = '0'
 and a.fbomid = 2005 for update
