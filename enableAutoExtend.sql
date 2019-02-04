--Script to create commands for auto extending the datafile
-- Jenny Sahaya Prabhu

select 'alter  database datafile ''' ||  file_name   || ''' autoextend on;' from sys.dba_data_files
/
exit
/
