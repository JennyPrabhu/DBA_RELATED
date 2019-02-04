
-- This script helps in finding the status of all the data files being used
-- Mofification History     
-- Jenny Sahaya Prabhu


select a.FILE_ID,
            round(((a.BYTES-b.BYTES)/a.BYTES)*100,2) PERCENTAGE_USED,
            round(((a.BYTES)/1024/1024),2) TOTAL_IN_MB,
            round(((a.BYTES-b.BYTES)/1024/1024),2) USED_IN_MB,
            round(((b.BYTES)/1024/1024),2) FREE_SPACE
        from
        (
            select FILE_ID,sum(BYTES) BYTES
            from dba_data_files 
			where tablespace_name in
			(select tablespace_name
			 from dba_tablespaces
			 where TABLESPACE_NAME != 'SYSTEM' and
			 TABLESPACE_NAME != 'SYSAUX' and 
			 CONTENTS != 'UNDO') group by FILE_ID
        ) a,
        (
            select FILE_ID,sum(BYTES) BYTES
            from dba_free_space 
			where tablespace_name in
			(select tablespace_name 
			 from dba_tablespaces
			 where TABLESPACE_NAME != 'SYSTEM' and
			 TABLESPACE_NAME != 'SYSAUX' and
			 CONTENTS != 'UNDO') group  by FILE_ID
        ) b
        where  a.FILE_ID=b.FILE_ID  
        order  by  PERCENTAGE_USED;
