# config:utf-8

require "active_record"
require "fileutils"

module Todo

  # database connection module
  # @author yoshiso
  module DB

    # database connect and create table
    # @return [void]
    def self.prepare
      database_path = File.join(ENV['HOME'],'.todo','todo.sqlite3')

      connect_database database_path
      create_table_if_not_exists database_path
    end

    private

    def self.connect_database(path)
      spec = {adapter: 'sqlite3', database: path}
      ActiveRecord::Base.establish_connection spec
    end

    def self.create_table_if_not_exists(path)
      create_database_path path

      connection = ActiveRecord::Base.connection
      return if connection.table_exists?(:tasks)

      connection.create_table :tasks do |t|
        t.column :name , :string, null: false
        t.column :content, :text, null: false
        t.column :status, :integer,default: 0, null: false
        t.timestamps
      end
      connection.add_index :tasks, :status
      connection.add_index :tasks, :created_at
    end

    def self.create_database_path(path)
      FileUtils.mkdir_p File.dirname(path)
    end
  end
end