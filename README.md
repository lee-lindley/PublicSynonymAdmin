# Public Synonym Admin

*pubsyn* is a utility package deployed by DBA to give Development/Deployment accounts a safe way to manage Public Synonyms.

## Description

The package *pubsyn* gives schema owners with execute priviledge the ability to Create, Replace and Delete public
synonyms that point to objects in their own schema. The session user account is not able to manipulate
existing public synonyms that point to objects in other schemas, nor create or change one to point to objects
in another schema.

This addresses the issue that granting *CREATE PUBLIC SYNONYM* is too permissive for most organizations, while
avoiding an active role for the DBA to manage all public synonyms.

## Interface

```sql
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
```

## Usage

To create or replace a public synonym for a package with the same name as the package, all in upper case:
```sql
    execute pubsyn.create_pub_syn('myPackageName');
```
To create or replace a public synonym for a function with a different name from the function, all in upper case:
```sql
    execute pubsyn.create_pub_syn('PubFunctionName', 'myFuncName');
```
To create or replace a public synonym for a procedure with a different name from the procedure 
and both are case sensitive (meaning the user will put double quotes around the name):
```sql
    execute pubsyn.create_pub_syn('CaseSensitiveProcName', 'WeirdProcName', FALSE);
```
To create or replace a public synonym for a type with same name as type
and both are case sensitive (meaning the user will put double quotes around the name):
```sql
    execute pubsyn.create_pub_syn('CaseSensitiveTypeName', p_capitalize => FALSE);
```
To drop an existing public synonym that points to an object in your schema:
```sql
    execute pubsyn.drop_pub_syn('CaseSensitiveTypeName', FALSE);
```

## Deployment

The file *pubsyn_schema.sql* has commands to create a schema with minimal privlidges
required for package *pubsyn*. You probably have an existing schema for DBA provided
packages, but this shows the minimum required for this one.

Modify *pubsyn.pks* and *pubsyn.pkb* to suit then execute them. You may want to add audit logging.

Grant Execute on *pubsyn* to users or roles that the development and/or deployment team
or application accounts have for the database. 


## Credits

A search of the internet will yield multiple variants of this theme. I did not invent it. I packaged it
in a way that suited the needs of an organization for which I worked. As far as I am concerned this is
public domain.
