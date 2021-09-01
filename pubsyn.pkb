whenever sqlerror exit failure
ALTER SESSION SET CURRENT_SCHEMA = &&userid_for_pubsyn ;
CREATE OR REPLACE PACKAGE BODY pubsyn AS

    FUNCTION get_owner(p_synonym_name    IN VARCHAR2)
    RETURN VARCHAR2
    IS
        v_table_owner   VARCHAR2(128);
    BEGIN
        SELECT table_owner INTO v_table_owner
        FROM dba_synonyms
        WHERE owner = 'PUBLIC'
            AND synonym_name = p_synonym_name;
        RETURN v_table_owner;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    END get_owner;

    PROCEDURE create_pub_syn(
        p_synonym_name      VARCHAR2
        ,p_object_name      VARCHAR2 DEFAULT NULL  -- same as synonym by default
        ,p_capitalize       BOOLEAN  DEFAULT TRUE  -- default is TO_UPPER on the object and synonym names
    ) 
    IS
        v_synonym_name  CONSTANT VARCHAR2(128) := CASE WHEN p_capitalize THEN UPPER(p_synonym_name) ELSE p_synonym_name END;
        v_owner         CONSTANT VARCHAR2(128) := get_owner(v_synonym_name);
        v_sess_user     CONSTANT VARCHAR2(128) := UPPER(SYS_CONTEXT('USERENV','SESSION_USER'));
        v_sql           VARCHAR2(1024);
    BEGIN
        IF v_owner != v_sess_user THEN -- NULL v_owner would mean does not exist which is fine
            RAISE_APPLICATION_ERROR(-20178, 'Synonym '||v_synonym_name||' is for object owned by '||v_owner||', not '||v_sess_user||'. It will not be overwritten');
        END IF;
        v_sql := 'CREATE OR REPLACE PUBLIC SYNONYM '||DBMS_ASSERT.enquote_name(v_synonym_name,p_capitalize)
            ||' FOR '||DBMS_ASSERT.enquote_name(v_sess_user, FALSE)
            ||'.'||DBMS_ASSERT.enquote_name(NVL(p_object_name,v_synonym_name),p_capitalize)
        ;
        DBMS_OUTPUT.put_line('Executing: '||v_sql);
        EXECUTE IMMEDIATE v_sql ;
    END create_pub_syn
    ;

    PROCEDURE drop_pub_syn(
        p_synonym_name      VARCHAR2
        ,p_capitalize       BOOLEAN DEFAULT TRUE  -- default is TO_UPPER on the object and synonym names
    ) IS
        v_synonym_name  CONSTANT VARCHAR2(128) := CASE WHEN p_capitalize THEN UPPER(p_synonym_name) ELSE p_synonym_name END;
        v_owner         CONSTANT VARCHAR2(30) := get_owner(v_synonym_name);
        v_sess_user     CONSTANT VARCHAR2(30) := UPPER(SYS_CONTEXT('USERENV','SESSION_USER'));
    BEGIN
        IF v_owner IS NOT NULL THEN -- do not care if attempt to drop one that does not exist
            IF v_owner != v_sess_user THEN
                RAISE_APPLICATION_ERROR(-20178, 'Synonym '||v_synonym_name||' is for object owned by '||v_owner||', not '||v_sess_user||'. It will not be dropped');
            END IF;
            EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM '||DBMS_ASSERT.enquote_name(v_synonym_name,FALSE);
            DBMS_OUTPUT.put_line('public synonym '||v_synonym_name||' is dropped');
        END IF;
    END drop_pub_syn;

END pubsyn;
/
show errors

