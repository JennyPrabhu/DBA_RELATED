
#!/bin/sh

#  
# Jenny Sahaya Prabhu

sqlplus -s system/password@TESTDB <<  endplus > data_files_JENSCHEMA.lst
set space 0
set head off
set heading off
set linesize 5000
set pagesize 50000
set trimspool on
set feedback off
set verify off
select distinct b.file_name||'|'||b.bytes/1024/1024 from dba_tables a, dba_data_files b
where a.tablespace_name= b.tablespace_name
and a.owner='JENSCHEMA'
/
endplus

rm -f alterDataFile_JENSCHEMA.sql

# Remove the empty lines from the file
awk 'NF>0' data_files_JENSCHEMA.lst > dataFiles_JENSCHEMA.lst

noOfFiles=`cat dataFiles_JENSCHEMA.lst | wc -l`

altered=1
while [ "$altered" -le "$noOfFiles" ]
do
if [ $altered = 1 ]
then
	fileName=`cat dataFiles_JENSCHEMA.lst | head -"$altered" | cut -d "|" -f1`
	oldSize=`cat dataFiles_JENSCHEMA.lst  | head -"$altered" | cut -d "|" -f2`
	echo "FileName"
	echo $fileName
	echo "oldSize"
	echo $oldSize
else
	tailnum=1
	fileName=`cat dataFiles_JENSCHEMA.lst | head -"$altered" | tail -"$tailnum" | cut -d "|" -f1`
	oldSize=`cat dataFiles_JENSCHEMA.lst  | head -"$altered" | tail -"$tailnum" | cut -d "|" -f2`
	echo "FileName"
	echo $fileName
	echo "oldSize"
	echo $oldSize
fi

newSize=`expr $oldSize + 200`
echo $newSize
echo "alter database datafile '"$fileName"' resize "$newSize"M;" >> alterDataFile_JENSCHEMA.sql

altered=`expr $altered + 1`
echo "ALTERED"
echo $altered

done

rm -f data_files_JENSCHEMA.lst dataFiles_JENSCHEMA.lst
