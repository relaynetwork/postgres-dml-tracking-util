--
-- target_host, target_db_name, schema, table_name, export_path
--
-- consult sysint.dml_export_tracking for target_host,target_db_name,schema.table_name to determine the ID range from "#{schema}.dml_#{table_name}" that must be exported
--
-- export the records within the id range to "#{export_path}/ids.#{schema_name}.#{table_name}.tab"
--
-- export the insert/update records to "#{export_path}/recs.#{schema_name}.#{table_name}.tab"

CREATE OR REPLACE FUNCTION dml_export_table_range( p_schema_name varchar, p_table_name varchar, p_min_dml_id bigint, p_max_dml_id bigint, p_export_path varchar ) RETURNS boolean AS
   $$
   DECLARE
      l_export_table varchar;
      l_target_file varchar;
      l_dml_table varchar;
   BEGIN
      l_export_table :=  (p_schema_name || '.' || p_table_name)::regclass;
      l_dml_table := (l_export_table || '_dml')::regclass;

      --export dml data
      l_target_file := p_export_path || '/' || 'dml.' || l_export_table || '.tab';
      EXECUTE
       'COPY (SELECT *
                FROM ' || l_dml_table || '
               WHERE id >  ' || p_min_dml_id || '
                 AND id <= ' || p_max_dml_id || ') 
       TO ''' || l_target_file || '''';

      --produce rows file
      l_target_file := p_export_path || '/' || l_export_table || '.tab';
      EXECUTE 'COPY (SELECT base_table.* 
                       FROM  ' || l_export_table ||  ' AS base_table
                      INNER JOIN ' || l_dml_table || ' AS dml_table
                         ON base_table.id = dml_table.source_id
                      WHERE dml_table.id > ' || p_min_dml_id || ' 
                        AND dml_table.id <= ' || p_max_dml_id || ')
                TO ''' || l_target_file  ||  '''';


      l_target_file := p_export_path || '/columns.txt';
      
      EXECUTE 'COPY (SELECT compute_export_column_order_fn( ''' || p_schema_name || ''',''' ||  p_table_name || ''')) 
                       TO ''' || l_target_file || '''' 
        USING p_schema_name, p_table_name;


      RETURN true;
   END;
   $$
   LANGUAGE 'plpgsql'
   SECURITY DEFINER;

