-- caller will add current txid to export_path

-- target_host, target_db_name, schema, table_name, export_path

-- consult sysint.dml_export_tracking for target_host,target_db_name,schema.table_name to determine the ID range from "#{schema}.dml_#{table_name}" that must be exported

-- export the records within the id range to "#{export_path}/ids.#{schema_name}.#{table_name}.tab"

-- export the insert/update records to "#{export_path}/recs.#{schema_name}.#{table_name}.tab"

