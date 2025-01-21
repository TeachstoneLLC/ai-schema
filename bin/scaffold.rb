#!/usr/bin/env ruby

##
# This script is a "Scaffold" script for creating DDL to define tables. It prints the generated 
# SQL to STDOUT.
#
# Usage:
#   scaffold.rb <table_name>[:table_comment] [+]<column_name>:<type>[:<size>][:<comment>]
# where:
#   <table_name> is the name of the table to create
#   <table_comment> is an optional comment for the table
#   a + sign indicates the column is not nullable
#   <column_name> is the name of the column to create
#   <type> is the data type of the column
#   <size> is the optional size of the column
#   <comment> is an optional comment for the column
#
# Timestamp columns (created_at, deleted_at, updated_at) will be automatically added. The primary key will always be 'id SERIAL PRIMARY KEY'.
# Comments statements are provided for the table and columns, except for the primary key and timestamps.
#
# Example:
#   scaffold.rb users:'Table to track users' +id:integer +name:string:50:'User name' \
#               +email:string:100:'User email' archived_at:timestamp:'Date user was archived'
#
# Output:
#   CREATE TABLE users (
#     id SERIAL PRIMARY KEY,
#     name VARCHAR(50) NOT NULL,
#     email VARCHAR(100) NOT NULL,
#     archived_at TIMESTAMP WITHOUT TIME ZONE,
#     created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
#     updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
#     deleted_at TIMESTAMP WITHOUT TIME ZONE
#   );
#   COMMENT ON TABLE users IS 'Table to track users';
#   COMMENT ON COLUMN users.name IS 'User name';
#   COMMENT ON COLUMN users.email IS 'User email';
#   COMMENT ON COLUMN users.archived_at IS 'Date user was archived';


##
# This class represents a column in a table

class Column
    attr_accessor :name, :type, :size, :comment, :nullable

    INTEGER_TYPE = 'integer'
    STRING_TYPE = 'string'
    TEXT_TYPE = 'text'
    TIMESTAMP_TYPE = 'timestamp'
    UUID_TYPE = 'uuid'
    TYPES = [INTEGER_TYPE, STRING_TYPE, TEXT_TYPE, TIMESTAMP_TYPE, UUID_TYPE]
    
    def initialize(name, type, size, comment, nullable)
        @name = name.downcase
        @type = type
        @size = size
        @comment = comment
        @nullable = nullable

        @standard_type = standard_type
    end

    def standard_type
        if !TYPES.include?(@type.downcase)
            raise "Invalid type: #{@type}"
        end
        case @type
        when INTEGER_TYPE
            'INTEGER'
        when STRING_TYPE
            'VARCHAR'
        when TEXT_TYPE
            'TEXT'
        when TIMESTAMP_TYPE
            'TIMESTAMP WITHOUT TIME ZONE'
        when UUID_TYPE
            'UUID'
        end
    end

    def has_size?
        [STRING_TYPE, TEXT_TYPE].include?(@type) and !@size.nil?
    end
    
    def to_s
        "#{@name} #{@type}#{size}#{nullable}"
    end
    
    def size
        @size.nil? ? '' : "(#{@size})"
    end
    
    def nullable
        @nullable ? '' : ' NOT NULL'
    end

    def type_sql
        sql = "#{@standard_type}"
        if has_size?
            sql += "(#{@size})"
        end
        sql
    end

    def nullity_sql
        @nullable ? '' : ' NOT NULL'
    end

    def to_sql
        "#{@name} #{type_sql}#{nullity_sql}"
    end

    def comment_sql(table_name)
        @comment ? "COMMENT ON COLUMN #{table_name}.#{@name} IS '#{@comment}';" : ''
    end
end
    
##
# This class represents a table in a database

class Table
    attr_accessor :name, :comment, :columns
    
    def initialize(name, comment, column_strings = [])
        raise 'Table name is required' if name.nil?
        @name = name.downcase
        @comment = comment
        raise 'Table must have at least one column' if column_strings.empty?
        @column_strings = column_strings

        @columns = @column_strings.map do |column_string|
            column_name, column_type, column_size, column_comment = column_string.split(':')
            nullable = column_name[0] != '+'
            column_name = column_name[1..-1] if !nullable
            Column.new(column_name, column_type, column_size, column_comment, nullable)
        end
    end
    
    def to_sql
        sql = "CREATE TABLE #{@name} (\n"
        sql += "  id SERIAL PRIMARY KEY,\n"
        @columns.each do |column|
        sql += "  #{column.to_sql},\n"
        end
        sql += "  created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,\n"
        sql += "  updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,\n"
        sql += "  deleted_at TIMESTAMP WITHOUT TIME ZONE\n"
        sql += ");\n"
        sql += "COMMENT ON TABLE #{@name} IS '#{@comment}';\n" unless @comment.nil?
        @columns.each do |column|
        sql += "COMMENT ON COLUMN #{@name}.#{column.name} IS '#{column.comment}';\n" unless column.comment.nil?
        end
        sql
    end
end
    
if $PROGRAM_NAME == __FILE__
    table_specifier, *column_strings = ARGV
    table_name, table_comment = table_specifier.split(':')
    table = Table.new(table_name, table_comment, column_strings)
    puts table.to_sql
end