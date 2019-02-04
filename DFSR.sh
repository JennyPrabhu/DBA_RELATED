#!/bin/ksh
#------------------------------------------------------------------------------
# File Name   		:  ReduceDataFileSpace
# 
# Author Name 		:  Jenny Sahaya Prabhu
#
# Description 		:  To Reduce the data file Space (.dbf-Files) to get more 
#					   space
#
# Input Parameters  :  User Inputs
#
# Output Parameters :  Log Files
#------------------------------------------------------------------------------
clear
echo "\n\t\t"
echo "\t\t\t\t+----------------------------------------+"
echo "\t\t\t\t|         DataFile Space Reducer         |"
echo "\t\t\t\t+----------------------------------------+"
echo "\t\t\t\t|                                        |"
echo "\t\t\t\t|  Reduces the space of the DataFiles    |"
echo "\t\t\t\t|                                        |"
echo "\t\t\t\t+----------------------------------------+"

# exporting the date for logs

day=$(date +"%d%b%y")
export day


# Handling interrrupt
trap handleInterrupt  1 2 3 15

#--------------------------------------------------------------------
#
# Function Name      :	Handleinterrupt
#
# Description        :	This Function handles the software Interrupts
#                    	such as 1 2 3 15
#
# Input Parameters   :	SoftwareInterrupts
#
# Output Parameters  :  None
#
# Remarks            :	1 - HangUp (HUP)  
#					 	2 - ^C or Del (INT)
#                    	3 - ^[ (quit) core dump  
#					   15 - graceful termination (TERM)
#---------------------------------------------------------------------

handleInterrupt()
{
	echo "\t\tRecieved Interrupt..."
	echo "\t\tExiting...!"
	exit
}

#--------------------------------------------------------------------
#
# Function Name     :	 getInput
#
# Description       :	 This Function gets the choice from the user
#
# Input Parameters  :	 User Inputs 
#
# Output Parameters :	 None
#
#--------------------------------------------------------------------

getInput()
{
	# Checking the input of the user

	if 	 [ $choice = "Y" -o $choice = "y" ]; then
    	echo "\n\t Entering into $DB_Name "
  		echo "\n\n\t $ORACLE_SID"
	elif [ $choice = "N" -o $choice = "n" ]; then
		echo "\n\n\t Ok..  "
    	echo "    \t Exiting..! "
		exit
	else
    	echo "\n\n\t Invalid Choice..!"
		echo "  \n\t Exiting..! "
		exit
	fi	
}

#--------------------------------------------------------------------
#
# Function Name      :	validateDB
#
# Description        :	This Function validates the DB    
#
# Input Parameters   :	User Input
#
# Output Parameters  :	None
#
#--------------------------------------------------------------------

validateDB()
{
	# exporting the DataBase

	if [ "$DB_Name" = "JEN_SCHEMA" ]; then
 		echo "\n"
	else
 		echo "\n\t\t invalid DB Name..Exiting..!"
 		exit
	fi
}

#--------------------------------------------------------------------
#
# Function Name     :	 exportDB
#
# Description       :	 This Function exports the user desired DB
#
# Input Parameters  :	 User Input
#
# Output Parameters :	 None
#
#--------------------------------------------------------------------

exportDB() 
{
	export ORACLE_SID=$DB_Name
	export HOST_CONNECT_STR=\@$DB_Name
	export ORACLE_HOME=/oracle/ora10gr2

}

#--------------------------------------------------------------------
#
# Function Name      :	getMode
#
# Description        :	This Function gets the mode of operation
#
# Input Parameters   :	User Inputs
#
# Output Parameters  :	None
#
#--------------------------------------------------------------------

getMode()
{
	clear
	echo "\n\t\t\t\t+-----------------------------------+"	
	echo "\t\t\t\t|                                   |" 
	echo "\t\t\t\t|        Select the Mode            |"
	echo "\t\t\t\t+-----------------------------------+"
	echo "\t\t\t\t|                                   |" 
	echo "\t\t\t\t|    	 1. Status Inquiry        |"
	echo "\t\t\t\t|                                   |" 
	echo "\t\t\t\t|        2. Modify Space            |"
	echo "\t\t\t\t|                                   |" 
	echo "\t\t\t\t+-----------------------------------+" 
	echo "\n\t Mode : \c";read mode
		
}

#--------------------------------------------------------------------
#
# Function Name      : 	executeSql  
#
# Description        :	This Function handles the software Interrupts
#
# Input Parameters   : 	None
#
# Output Parameters  : 	None
#
#--------------------------------------------------------------------

executeSql()
{
  if [ $mode -eq 1 ]; then
	  status
  elif [ $mode -eq 2 ]; then
     modify
  else
	  echo "\n\t\tInvalid Choice"
	  echo "\t\texiting"	  
	  exit
  fi
}

#--------------------------------------------------------------------
#
# Function Name       :	status
#
# Description         :	This Function gets the status of the dbf files
#
# Input Parameters    :	None
#
# Output Parameters   : logs
#
#--------------------------------------------------------------------

status()
{
sqlplus schema/passwrd `$HOST_CONNECT_STR << EOT > SpaceStatus_$day.log 		
	start status.sql
	/
	exit
EOT
  echo "\t\tExecuted Succesfully."
  echo "\t\tPlease check the log file for further details"

}

#--------------------------------------------------------------------
#
# Function Name       :	modify
#
# Description         :	This Function modifies the dbf files
#
# Input Parameters    :	None
#
# Output Parameters   :	Logs
#
#--------------------------------------------------------------------

modify()
{
	#-----------------------
	#Logging into sql prompt
	#-----------------------
#spool /module104/mod104/JENNY/NEW/SpaceReducer_$day.log
sqlplus schema/passwrd `$HOST_CONNECT_STR << EOT > SpaceReducer_$day.log 
	start alterDataFile_Resize.sql
	/
	exit
EOT
  echo "\t\tExecuted Succesfully."
  echo "\t\tPlease check the log file for further details"

}
	
#-----------------
# Main Starts Here
#-----------------
	# Prompting the User For DataBase
	echo "\n\n\t Enter the DB in Which you want to run the tool: ";read DB_Name
	validateDB
	echo "\n\t Do you want to enter into $DB_Name ?(y/n):\c "
	read choice	
	getInput
	exportDB	
	getMode
	executeSql

exit
