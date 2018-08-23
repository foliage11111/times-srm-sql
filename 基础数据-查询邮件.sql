select * from cux.cux_email_msgs t ---
 where t.EMAIL_ADDRESS like 'PENGCHU888%'
 order by t.creation_date  desc;

 select t.email_id, t.title, t.url, t.sender_id, t.status, t.update_date from ams_email@mail.timesgroup.cn t --
where t.url like 'PENGCHU888%'
order by t.update_date desc;


select * from CUX_MAIL_MSG_TEM t 
 where t.EMAIL_ADDRESS like '65284863%'
order by t.temp_id desc ;



