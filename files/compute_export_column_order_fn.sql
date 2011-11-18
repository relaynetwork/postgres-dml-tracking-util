CREATE OR REPLACE FUNCTION compute_export_column_order_fn( p_schema_name varchar, p_table_name varchar ) RETURNS varchar AS
$$
DECLARE
   l_stmt varchar;
   l_col_name varchar;
BEGIN
   l_stmt := '';
   FOR l_col_name IN 
        SELECT column_name 
          FROM information_schema.columns 
         WHERE table_schema = p_schema_name
           AND table_name = p_table_name
         ORDER BY ordinal_position LOOP
     l_stmt := l_stmt || l_col_name || ',';
   END LOOP;
  
   return substring(l_stmt, 1, length(l_stmt) - 1 );
END;
$$
LANGUAGE 'plpgsql'
