#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Memories

=end

require "sqlite3"
require "digest"

# Notes
# UPDATE table SET index=newvalue WHERE id=#
# DELETE FROM table WHERE id=#

class Memory
    attr_reader :db, :id

    # Create memory database; Set checksum of memories; Hardcode existing tables
    def initialize(memories)
        if not File.exist? memories
            File.open(memories, File::CREAT)
        end
        @db = SQLite3::Database.new(memories)
        # All questions "?"
        @db.execute("CREATE TABLE IF NOT EXISTS statement
                    (id INTEGER PRIMARY KEY,
                    input TEXT,
                    output TEXT,
                    scales TEXT,
                    type TEXT,
                    uniqid TEXT)"
        )
        # All word matchings "*"
        @db.execute("CREATE TABLE IF NOT EXISTS thesaurus
                    (id INTEGER PRIMARY KEY,
                    input TEXT,
                    output TEXT,
                    scales TEXT,
                    uniqid TEXT)"
        # Possibly add reaction determination to `thesaurus`?
        )

        dir = File.expand_path File.dirname(__FILE__)
        File.open("#{dir}/checksum", "w") { |file| file.write(Digest::SHA2.file(memories).hexdigest) }
    end
end