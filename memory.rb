#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Memories

=end

require 'sqlite3'
require "digest"

# Notes
# UPDATE table SET index=newvalue WHERE id=#
# DELETE FROM table| WHERE id=#

class Memory
    attr_reader :db, :id, :tables

    # Create memory database; Set checksum of memories; Hardcode existing tables
    def initialize(memories)
        if not File.exist? memories
            File.open(memories)
        end
        @db = SQLite3::Database.new(memories)
        # All questions "?"
        @db.execute("CREATE TABLE IF NOT EXISTS question
                    (id INTEGER PRIMARY KEY AUTOINCREMENT,
                    input TEXT,
                    output TEXT,
                    increment INTEGER)"
        )
        # All statements "."
        @db.execute("CREATE TABLE IF NOT EXISTS statement
                    (id INTEGER PRIMARY KEY AUTOINCREMENT,
                    input TEXT,
                    output TEXT,
                    increment INTEGER)"
        )
        # All commands "!"
        @db.execute("CREATE TABLE IF NOT EXISTS command
                    (id INTEGER PRIMARY KEY AUTOINCREMENT,
                    input TEXT,
                    output TEXT,
                    increment INTEGER)"
        )
        # All word matchings "*"
        @db.execute("CREATE TABLE IF NOT EXISTS thesaurus
                    (id INTEGER PRIMARY KEY AUTOINCREMENT,
                    input TEXT,
                    output TEXT,
                    increment INTEGER)"
        # Possibly add reaction determination to `thesaurus`?
        )

        dir = File.expand_path File.dirname(__FILE__)
        File.open("#{dir}/checksum", "w") { |file| file.write(Digest::SHA2.file(memories).hexdigest) }

        @tables = ["question", "statement", "command", "thesaurus"]
    end
    
    # Inject memories into the database
    def inject(table, input, output)
    	state = false
        # Validate that table exists
        @tables.each do |t|
            if t == table
                state = true
            end
        end
        # Should not happen unless hackers happen
        raise ArgumentError, "TABLE DOES NOT EXIST!!!" unless state
        @db.execute("INSERT INTO #{table} (id, input, output) VALUES ( ?, ?, ?, ? )", [nil, input, output, 0])
    end
end