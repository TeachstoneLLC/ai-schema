-- Running the following two queries to have some useful visual output in case
-- there are missing comments in the database schema.
with tables as (select distinct table_name from information_schema.columns
where table_schema = 'public')
select table_name, obj_description(('public.'||table_name)::regclass, 'pg_class') as comment
from tables
where obj_description(('public.'||table_name)::regclass, 'pg_class') is null;

SELECT c.relname, a.attname As column_name,  d.description as comment
   FROM pg_class As c
    INNER JOIN pg_attribute As a ON c.oid = a.attrelid
   LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
   LEFT JOIN pg_tablespace t ON t.oid = c.reltablespace
   LEFT JOIN pg_description As d ON (d.objoid = c.oid AND d.objsubid = a.attnum)
   inner join information_schema.columns As ic_cols on c.relname = ic_cols.table_name and a.attname = ic_cols.column_name 
   WHERE  c.relkind IN('r', 'v') AND  n.nspname = 'public' --AND c.relname in (select distinct 'edge'
   and d.description is null
   and column_name not in ('id', 'key', 'uuid', 'created_at', 'updated_at', 'deleted_at', 'description')
   ORDER BY n.nspname, c.relname, a.attname;

do $$
<<missing_comments_block>>
    declare missing_table_comments integer := 0;
	declare missing_column_comments integer := 0;
begin
    select count(*) into missing_table_comments from (with tables as (select distinct table_name from information_schema.columns
        where table_schema = 'public')
        select table_name, obj_description(('public.'||table_name)::regclass, 'pg_class') as table_comment
        from tables
        where obj_description(('public.'||table_name)::regclass, 'pg_class') is null);
    select count(*) into missing_column_comments from (SELECT c.relname, a.attname As column_name,  d.description
    FROM pg_class As c
        INNER JOIN pg_attribute As a ON c.oid = a.attrelid
        LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
        LEFT JOIN pg_tablespace t ON t.oid = c.reltablespace
        LEFT JOIN pg_description As d ON (d.objoid = c.oid AND d.objsubid = a.attnum)
        inner join information_schema.columns As ic_cols on c.relname = ic_cols.table_name and a.attname = ic_cols.column_name 
    WHERE  c.relkind IN('r', 'v') AND  n.nspname = 'public' --AND c.relname in (select distinct 'edge'
        and d.description is null
        and column_name not in ('id', 'key', 'uuid', 'created_at', 'updated_at', 'deleted_at', 'description')
    ORDER BY n.nspname, c.relname, a.attname) ;
    if missing_table_comments + missing_column_comments > 0 then
        raise 'There are % tables or columns missing comments', missing_table_comments + missing_column_comments;
    end if;
 end missing_comments_block $$;