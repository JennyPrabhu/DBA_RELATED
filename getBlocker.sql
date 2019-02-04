-- For enq TM contention

SELECT l.sid, s.blocking_session blocker, s.event, l.type, l.lmode, l.request, o.object_name, o.object_type
FROM v$lock l, dba_objects o, v$session s
WHERE UPPER(s.username) = 'MIGADM'
AND   l.id1        = o.object_id (+)
AND   l.sid        = s.sid
ORDER BY sid, type;
