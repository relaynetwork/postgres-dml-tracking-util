require File.join( File.dirname(__FILE__), 'lib', 'postgres', 'dml')

#include Postgres::DML

namespace :postgres do
  namespace :dml do
    desc "Generate DML for dml_export_tracking table."
    task :gen_export_table, :schema, :table do |t,args|
      schema = args[:schema]
      table = args[:table]

      if table.nil? || schema.nil? 
        raise "You must specify both a table and a schema"
      end

      PostgresDML.create_dml_export_tracking_table schema, table
    end


    desc "Generate Reset Button."
     task :gen_reset, :schema, :table  do |t,args|
      schema = args[:schema]
      table = args[:table]

      if table.nil? || schema.nil? 
        raise "You must specify both a table and a schema"
      end
      dml_generater = PostgresDML.new( schema, table )
      dml_generater.create_reset_button
    end

    desc "Generate Exporter Tracking Files for table."
    task :gen_exporter, :schema, :table  do |t,args|
      schema = args[:schema]
      table = args[:table]

      if table.nil? || schema.nil? 
        raise "You must specify both a table and a schema"
      end

      dml_generater = PostgresDML.new( schema, table )

      dml_generater.create_dml_table 
      dml_generater.create_dml_trigger_fn
      dml_generater.create_dml_triggers
      dml_generater.create_export_fns      
      dml_generater.create_compute_export_column_order_fn

    end

    desc "Generate Importer Tracking Files for table."
    task :gen_importer, :schema, :table  do |t,args|
      schema = args[:schema]
      table = args[:table]

      if table.nil? || schema.nil? 
        raise "You must specify both a table and a schema"
      end

      dml_generater = PostgresDML.new( schema, table )

      dml_generater.create_dml_table 

      dml_generater.create_import_fn
    end
  end
end
