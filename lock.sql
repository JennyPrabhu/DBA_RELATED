-- Below is the query to find the sessions that are still active

select
c.owner||'|'||c.object_name||'|'||c.object_type||'|'|| b.sid||'|'||b.serial#||'|'||b.status||'|'||b.osuser||'|'||b.machine
from
v$locked_object a ,
v$session b,
dba_objects c
where b.sid = a.session_id
and a.object_id = c.object_id
/

--below is the syntax to kill a session
--alter system kill session 'sid,serial#' immediate;
