#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Memories

=end

# require "rubygems"
# require "bundler/setup"
# require "sqlite3"
require_relative "kylodocs"
require "digest"

# Notes
# SELECT * FROM table
# INSERT INTO table (columns) VALUES (values)
# UPDATE table SET column=newvalue WHERE column=value
# DELETE FROM table WHERE column=value
# WHERE column LIKE val

class Memory
    attr_reader :db, :memories, :checksum

    # Create memory database; Set checksum of memories; Hardcode existing tables
    def initialize(memories, memdir)
        @memories = "#{memdir}/#{memories}.json"
        kd = KyloDocs.new(memories, memdir)

        data = kd.read

        if data["statements"] then
            kd.set("statement",{
                    # [
                    #     :id     => {},
                    #     :input  => {},
                    #     :output => {},
                    #     :scales => {},
                    #     :type   => {},
                    #     :uniqid => {}
                    # ]
                })
        end

        # Possibly add reaction determination to `categories`?
        if data["categories"] then
            kd.set("statement",{
                    # [
                    #     :id     => {},
                    #     :input  => {},
                    #     :output => {},
                    #     :scales => {},
                    #     :uniqid => {}
                    # ]
                })
        end

        # SID == session_id
        if data["curiosity"] then
            kd.set("statement",{
                    # [
                    #     :id     => {},
                    #     :input  => {},
                    #     :output => {},
                    #     :scales => {},
                    #     :sid    => {}
                    # ]
                })
        end

        # @db = SQLite3::Database.new(@memories)
        # @db.execute("CREATE TABLE IF NOT EXISTS statement
        #              (
        #                 id INTEGER PRIMARY KEY,
        #                 input TEXT,
        #                 output TEXT,
        #                 scales TEXT,
        #                 type TEXT,
        #                 uniqid TEXT
        #              )"
        # )
        # @db.execute("CREATE TABLE IF NOT EXISTS thesaurus
        #              (
        #                 id INTEGER PRIMARY KEY,
        #                 input TEXT,
        #                 output TEXT,
        #                 scales TEXT,
        #                 uniqid TEXT
        #              )"
        # )
        # @db.execute("CREATE TABLE IF NOT EXISTS curiosity
        #              (
        #                 id INTEGER PRIMARY KEY,
        #                 input TEXT,
        #                 output TEXT,
        #                 scales TEXT,
        #                 sid TEXT
        #              )"
        # )

        dir = File.expand_path File.dirname __FILE__
        @checksum = "#{dir}/checksum"
        if not File.exist? checksum then
            File.open checksum, File::CREAT
        else
            update_checksum
        end
    end

    def update_checksum()
        File.open(@checksum, "w") { |file| file.write(Digest::SHA2.file("#{@memories}").hexdigest) }
    end
end