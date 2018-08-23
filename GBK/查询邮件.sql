select * from cux.cux_email_msgs t  order by t.creation_date  desc;
select * from CUX_MAIL_MSG_TEM t order by t.temp_id desc ;
select t.email_id, t.title, t.url, t.sender_id, t.status, t.update_date from ams_email@mail.timesgroup.cn t order by t.update_date desc
