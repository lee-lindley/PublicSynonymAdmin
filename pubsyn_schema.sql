-- USER SQL
CREATE USER &&userid_for_pubsyn IDENTIFIED BY "null"  
DEFAULT TABLESPACE "SYSAUX"
TEMPORARY TABLESPACE "TEMP"
PASSWORD EXPIRE 
ACCOUNT LOCK ;

-- QUOTAS

-- ROLES

-- SYSTEM PRIVILEGES
GRANT CREATE PUBLIC SYNONYM TO  &&userid_for_pubsyn ;
GRANT DROP PUBLIC SYNONYM TO &&userid_for_pubsyn ;

Grant select on dba_synonyms TO &&userid_for_pubsyn ;
