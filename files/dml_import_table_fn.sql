-- schema, table_name, import_path

-- delete recs for each id in : "#{import_path}/ids.#{schema_name}.#{table_name}.tab"

-- append "#{import_path}/recs.#{schema_name}.#{table_name}.tab" to table

CREATE OR REPLACE FUNCTION dml_import_table( p_txn_id bigint, p_schema_name varchar, p_table_name varchar,  p_import_path varchar, p_columns varchar ) RETURNS boolean AS
   $$
   DECLARE
      l_dml_table      varchar;
      l_temp_dml_table varchar;
      l_import_table   varchar;
      l_dml_file_path  varchar;
      l_rec_file_path varchar;

      l_min_dml_id   bigint;
      l_max_dml_id   bigint;
   BEGIN
      l_import_table :=  (p_schema_name || '.' || p_table_name)::regclass;
      l_dml_table := (l_import_table || '_dml')::regclass;
      l_temp_dml_table := (l_import_table || '_dml_temp');
      l_dml_file_path :=  p_import_path  || '/' || 'dml.' || l_import_table || '.tab';
      l_rec_file_path :=  p_import_path  || '/' ||  l_import_table || '.tab';

      RAISE NOTICE 'l_dml_file_path %', l_dml_file_path;

      --create temp table
      EXECUTE 'CREATE TABLE ' || l_temp_dml_table || '
               (LIKE ' || l_dml_table || ');';

      --copy into dml temp table 
      EXECUTE 'COPY ' || l_temp_dml_table || '
                  FROM ''' ||  l_dml_file_path || ''''; 

      EXECUTE 'SELECT min(temp.id) 
                 FROM ' || l_temp_dml_table || ' AS temp
                 LEFT OUTER JOIN ' || l_dml_table || ' AS perm
                   ON temp.id = perm.id
                WHERE perm.id IS NULL;'
         INTO  l_min_dml_id;

      EXECUTE 'SELECT max(temp.id) 
                 FROM ' || l_temp_dml_table || ' AS temp
                 LEFT OUTER JOIN ' || l_dml_table || ' AS perm
                   ON temp.id = perm.id
                WHERE perm.id IS NULL;'
         INTO  l_max_dml_id;

      --copy into permanent dml table any dml we haven't already processed
      EXECUTE 'INSERT INTO ' || l_dml_table || '
                      (SELECT temp.* 
                         FROM ' || l_temp_dml_table || ' AS temp
                         LEFT OUTER JOIN ' || l_dml_table || ' AS perm 
                           ON temp.id = perm.id
                         WHERE perm.id IS NULL);';

      --delete recs with ids mentioned in the dml table
      EXECUTE 'DELETE FROM ' || l_import_table || ' 
                WHERE id IN (SELECT source_id
                               FROM ' || l_temp_dml_table || ');';
      --copy into recs table new recs
      EXECUTE 'COPY ' || l_import_table || '(' || p_columns || ') 
               FROM ''' ||  l_rec_file_path || ''''; 

      --insert into rn_db.dml_import_table if we actually imported dml
      IF l_min_dml_id IS NOT NULL AND l_max_dml_id IS NOT NULL THEN
        EXECUTE 'INSERT INTO rn_db.dml_import_table (txn_id, dml_schema_name, dml_table_name, dml_min_import_id, dml_max_import_id ) 
                      VALUES ( $1, $2, $3, $4, $5 )'
             USING p_txn_id, p_schema_name, p_table_name, l_min_dml_id, l_max_dml_id;  
      END IF;

      EXECUTE 'DROP TABLE ' || l_temp_dml_table || ';';

      RETURN true;
   END;
   $$
   LANGUAGE 'plpgsql'
   SECURITY DEFINER;
