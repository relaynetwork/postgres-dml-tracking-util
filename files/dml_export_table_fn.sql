CREATE OR REPLACE FUNCTION dml_export_table( p_target_host varchar, p_target_db varchar, p_schema_name varchar, p_table_name varchar, p_export_path varchar, p_txn_id bigint ) RETURNS boolean AS
   $$
   DECLARE
      l_export_min_id bigint;
      l_export_max_id bigint;
      l_dml_table varchar;
      l_dyn_sql varchar;
   BEGIN
     l_dml_table := (p_schema_name || '.' || p_table_name || '_dml')::regclass;

     SELECT max(dml_last_export_id)
            INTO l_export_min_id
            FROM rn_db.dml_export_tracking
           WHERE dml_schema_name = p_schema_name
             AND dml_table_name = p_table_name
             AND target_host = p_target_host
             AND target_db = p_target_db;

     IF l_export_min_id IS NULL THEN
        raise notice 'IN NOT FOUND';
        l_export_min_id := 0;
     END IF;

     l_dyn_sql := 'SELECT max(id) FROM ' || l_dml_table || ';';
     EXECUTE l_dyn_sql INTO l_export_max_id;

     IF l_export_max_id IS NULL  THEN
        l_export_max_id := 0;
     END IF;

     PERFORM dml_export_table_range( p_schema_name, p_table_name, l_export_min_id, l_export_max_id, p_export_path );

    raise notice 'done range export';
     --log dml export
     INSERT INTO rn_db.dml_export_tracking 
            (txn_id, target_host, target_db, dml_schema_name, dml_table_name, dml_last_export_id)
      VALUES (p_txn_id, p_target_host, p_target_db, p_schema_name, p_table_name, l_export_max_id);

     RETURN true;
   END;
   $$
   LANGUAGE 'plpgsql'
   SECURITY DEFINER;
