whenever sqlerror exit failure
ALTER SESSION SET CURRENT_SCHEMA = &&userid_for_pubsyn ;
CREATE OR REPLACE PACKAGE pubsyn AS
    PROCEDURE create_pub_syn(
        p_synonym_name      VARCHAR2
        ,p_object_name      VARCHAR2 DEFAULT NULL  -- same as synonym by default
        ,p_capitalize       BOOLEAN  DEFAULT TRUE  -- default is UPPER on the object and synonym names
    ); 
    PROCEDURE drop_pub_syn(
        p_synonym_name      VARCHAR2
        ,p_capitalize       BOOLEAN  DEFAULT TRUE 
    );
END pubsyn;
/
show errors
CREATE OR REPLACE PUBLIC SYNONYM pubsyn FOR &&userid_for_pubsyn..pubsyn;
prompt grant execute on &&userid_for_pubsyn.pubsyn to whoever needs it or better yet to a role granted developer application schema owners.
