#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Memories

=end

require_relative "kylodocs"
require "digest"

class Memory
    attr_reader :db, :memories, :checksum

    # Create memory database; Set checksum of memories; Hardcode existing tables
    def initialize(dir, memories)
        @memories = "#{dir}/#{memories}"
        Dir.mkdir dir unless Dir.exists? dir
        File.open @memories, File::CREAT unless File.exists? @memories

        data = kd.read

        if data["statements"] then
            kd.set("statement",{
                    # Schema
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
                    # Schema
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
                    # Schema
                    # [
                    #     :id     => {},
                    #     :input  => {},
                    #     :output => {},
                    #     :scales => {},
                    #     :sid    => {}
                    # ]
                })
        end

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