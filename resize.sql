-- Jenny Sahaya Prabhu
-- This query is used to alter the database to resize the data file
-- Run this as "SYSTEM" user
-- file_size should be entered like 30M or 40M etc

-- Pass the table space that need to be resized as an input 

select tablespace_name, file_name, bytes/1024/1024 from dba_data_files where tablespace_name=upper('&tablespace_name')
/
alter database datafile '&datafile_absolute_path' resize &file_size
/
exit
/
