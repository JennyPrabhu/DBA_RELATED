set feedback off
Prompt GATHERING SCHEMA STATS OF SCHEMA

exec dbms_stats.gather_schema_stats(ownname => 'SCHEMA',estimate_percent => 20, cascade => TRUE,no_invalidate => FALSE,method_opt => 'FOR ALL COLUMNS SIZE 1',degree => 5)

Prompt DONE


exit
