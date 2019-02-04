/*=============================================================================
 * File Name         :  Cursor.sql
 *
 * Description       :  An Oracle PL/SQL function which gets the 
 *                      datafile space and resizes it.  
 *
 * Input Parameters  :  None
 *
 * Output Parameters :  None
 *
 *=============================================================================
*/

-- For viewing the Output

SET SERVEROUTPUT ON                                     

-- Variables Declaration

DECLARE 
	i_count   	number(3);
	f_fileId  	dba_data_files.FILE_ID%TYPE;
	f_percent 	dba_data_files.BYTES%TYPE;
	f_total   	dba_data_files.BYTES%TYPE;
	f_used    	dba_data_files.BYTES%TYPE;
	f_free    	dba_free_space.BYTES%TYPE;
	f_candelete dba_free_space.BYTES%TYPE;
	v_fileName  dba_data_files.FILE_NAME%TYPE;
	v_command   varchar2(1000);                       

	-- Cursor Declaration
	
	CURSOR space_cursor is                             

		-- An Inline query

		select a.FILE_ID,
      		round(((a.BYTES-b.BYTES)/a.BYTES)*100,2) PERCENTAGE_USED,
	  		round(((a.BYTES)/1024/1024),2) TOTAL_IN_MB,
	  		round(((a.BYTES-b.BYTES)/1024/1024),2) USED_IN_MB,
	  		round(((b.BYTES)/1024/1024),2) FREE_SPACE
		from 
      	(	select file_id , sum(BYTES) BYTES
			from dba_data_files
			where tablespace_name in
			(select tablespace_name
			 from dba_tablespaces
			 where TABLESPACE_NAME != 'SYSTEM' and
			 TABLESPACE_NAME != 'SYSAUX' and 
			 CONTENTS != 'UNDO') 
			group by fIle_id
			
        ) a,
      	(   select file_id , sum(BYTES) BYTES 
			from dba_free_space
			where tablespace_name in
			(select tablespace_name
			 from dba_tablespaces
			 where TABLESPACE_NAME != 'SYSTEM' and
			 TABLESPACE_NAME != 'SYSAUX' and CONTENTS != 'UNDO') 
			 group by fIle_id

      	) b
		where  a.FILE_ID=b.FILE_ID
		order  by  PERCENTAGE_USED;                     
BEGIN
    
	-- Populating the count of files	

	select count(*) into i_count from dba_data_files;
	DBMS_OUTPUT.PUT_LINE('count ' || i_count);
	select count(*) into i_count from dba_data_files  where tablespace_name in (select tablespace_name from dba_tablespaces where TABLESPACE_NAME != 'SYSTEM' and TABLESPACE_NAME != 'SYSAUX' and CONTENTS != 'UNDO');
	DBMS_OUTPUT.PUT_LINE('count ' || i_count);

	-- Opening a Cursor

	OPEN space_cursor;                                 
	
	FOR i IN 1..i_count LOOP
		FETCH space_cursor into f_fileId,f_percent,f_total,f_used,f_free;
		DBMS_OUTPUT.PUT_LINE(f_fileId || ' ' || f_percent|| ' '  || f_total || ' '||  f_used || ' '  || f_free);

    -- fetching the files which are being used less than 70 percent		
	
	IF ceil(f_percent) < 70.00 then         

	-- allocating 10 MB more space

	    f_candelete := ceil(f_used + 10.00);
		select file_name into v_fileName from dba_data_files where file_id = f_fileId;
		DBMS_OUTPUT.PUT_LINE(v_fileName||' ');
	--	DBMS_OUTPUT.PUT_LINE(f_fileId || ' ' || f_percent|| ' '  || f_total || ' '||  f_used || ' '  || f_free);
		DBMS_OUTPUT.PUT_LINE('alter database datafile '''|| v_fileName || ''' resize ' || f_candelete || 'M');
       DBMS_OUTPUT.PUT_LINE('f_total' || f_total || ' f_candelete' || f_candelete); 
    
	-- Checking whether it already has the wanted size
	
	IF f_total <= f_candelete then

   		DBMS_OUTPUT.PUT_LINE('No Need To Alter');
    ELSE
		DBMS_OUTPUT.PUT_LINE('else');   
 	-- altering the datafile
	  execute immediate 'alter database datafile ''' || v_fileName || ''' resize ' || f_candelete || 'M';
    END IF;
  
	-- DBMS_OUTPUT.PUT_LINE('after');
	
	--	DBMS_OUTPUT.PUT_LINE(v_fileName||' ');
	--	 DBMS_OUTPUT.PUT_LINE(f_fileId || ' ' || f_percent|| ' '  || f_total || ' '||  f_used || ' '  || f_free); 

	END IF;
	END LOOP;

	-- closing the Cursor
 	
	CLOSE space_cursor;                             
END;	
/
