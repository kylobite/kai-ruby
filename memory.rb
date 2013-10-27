#!/usr/bin/env ruby

require 'sqlite3'
require "digest"

# Notes
# UPDATE table SET index=newvalue WHERE id=#
# DELETE FROM table| WHERE id=#

class Memory
    attr_reader :db, :id, :tables

    def initialize()
        @db = SQLite3::Database.new("brain.db")
        @db.execute("CREATE TABLE IF NOT EXISTS question
                    (id INTEGER PRIMARY KEY AUTOINCREMENT,
                    input TEXT,
                    output TEXT,
                    increment INTEGER)"
        )
        @db.execute("CREATE TABLE IF NOT EXISTS statement
                    (id INTEGER PRIMARY KEY AUTOINCREMENT,
                    input TEXT,
                    output TEXT,
                    increment INTEGER)"
        )
        @db.execute("CREATE TABLE IF NOT EXISTS command
                    (id INTEGER PRIMARY KEY AUTOINCREMENT,
                    input TEXT,
                    output TEXT,
                    increment INTEGER)"
        )
        @db.execute("CREATE TABLE IF NOT EXISTS thesaurus
                    (id INTEGER PRIMARY KEY AUTOINCREMENT,
                    input TEXT,
                    output TEXT,
                    increment INTEGER)"
        )

        File.open("checksum", "w") { |file| file.write(Digest::SHA2.file("brain.db").hexdigest) }

        @tables = ["question", "statement", "command", "thesaurus"]
    end
    
    def inject(table, input, output)
    	state = false
        @tables.each do |t|
            if t == table
                state = true
            end
        end
        raise ArgumentError, "TABLE DOES NOT EXIST!!!" unless state
        @db.execute("INSERT INTO #{table} (id, input, output) VALUES ( ?, ?, ?, ? )", [nil, input, output, 0])
    end
end