require 'rubygems'
require 'erb'

class PostgresDML
    def initialize schema, table
      @table = table
      @schema = schema
      @project_dir = File.join( File.dirname(__FILE__), '..', '..' )
      @template_dir = File.join( @project_dir, 'templates')
      @files_dir = File.join( @project_dir, 'files')

      @tracked_table =  "#{@schema}.#{@table}"
      @dml_table = "#{@tracked_table}_dml"
      @sequence = "#{@dml_table}_id_seq"
      @dml_trigger_fn = "#{@dml_table}_tracking"
      #change this name please
      @fn_signature = "#{@dml_trigger_fn}()"
      @trigger_name = "#{@table}_dml_trigger"

      @export_sql_file = File.new( File.join( @project_dir, "export_side.sql" ), 'w' )
      @import_sql_file = File.new( File.join( @project_dir, "import_side.sql" ), 'w' )
    end

    def create_dml_table
      sql = ERB.new( File.read(File.join(@template_dir, 'create_dml_table.erb' ) ) ).result(binding) 
      #outf = File.new( File.join( @project_dir, "create_#{@dml_table}_table.sql" ), 'w' )
      #@export_sql_file.puts sql
      #@import_sql_file.puts sql
      puts sql
    end

    def create_dml_trigger_fn
      sql = ERB.new( File.read(File.join(@template_dir, 'dml_trigger_fn.erb' ) ) ).result(binding) 
      #@export_sql_file.puts sql
      puts sql
    end

    def create_dml_triggers
      sql = ERB.new( File.read(File.join(@template_dir, 'dml_trigger.erb' ) ) ).result(binding) 
      #@export_sql_file.puts sql
      puts sql
    end

    def create_reset_button
      sql = ERB.new( File.read(File.join(@template_dir, 'reset_button.erb' ) ) ).result(binding) 
      #outf = File.new( File.join( @project_dir, "#{@tracked_table}_reset_button.sql" ), 'w' )
      #outf.puts sql
      puts sql
    end

    def create_compute_export_column_order_fn
      sql = File.read(File.join(@files_dir, 'compute_export_column_order_fn.sql')) 
      #@export_sql_file.puts sql
      puts sql
    end

    def create_export_fns
      sql = File.read(File.join(@files_dir, 'dml_export_table_range_fn.sql')) 
      #@export_sql_file.puts sql
      puts sql
      sql = File.read(File.join(@files_dir, 'dml_export_table_fn.sql')) 
      #@export_sql_file.puts sql
      puts sql
    end

    def create_import_fn
      sql = File.read(File.join(@files_dir, 'dml_import_table_fn.sql')) 
      #@import_sql_file.puts sql
      puts sql
    end

    def self.create_dml_export_tracking_table schema, table
      sequence = "#{schema}.#{table}_id_seq"
      project_dir  = File.join( File.dirname(__FILE__), '..', '..')
      template_dir = File.join(project_dir, 'templates')
      sql = ERB.new( File.read(File.join(template_dir, 'create_dml_export_tracking_table.erb' ) ) ).result(binding) 
      outf = File.new( File.join( project_dir, "create_dml_export_tracking_table.sql" ), 'w' )
      outf.puts sql
    end
end
