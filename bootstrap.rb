#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Bootstrap

=end

require_relative "memory"
require_relative "think"
require_relative "config"

require "digest"

# Notes
# File: constants
#   use: File.open("constants").read.scan /(\w+):\s(.+)\n/

class Bootstrap
    attr_reader :memory, :config, :session_id, :conversation, :mode, :prompt, :checksum

    # Set class constants
    def initialize(memories)
        # Grab the memory database
        dir             = File.expand_path File.dirname(__FILE__)
        memdir          = "#{dir}/#{memories}"
        @memory         = Memory.new(memdir)

        # Grab the configuration settings
        @config = Configuration.new

        # Prepare for conversation
        @session_id     = Digest::SHA2.hexdigest(Time.now.to_f.to_s)[0..11]
        @conversation   = true
        @mode = "interactive"
        @prompt         = "> "

        # Grab the checksum of the memory database
        @checksum = File.open("#{dir}/checksum") {|file| file.read}
    end

    def login(enable)
        if enable then
            return @config.validate
        end
        return "guest"
    end

    def rights (usergroup)
        return @config.privileges(usergroup)
    end

    def header(version)
        puts "\n KAI v#{version}\n------------------\n"
    end

    # <modes>
    def learn(thought)
        return "#{thought.learn(@memory, @session_id)}"
    end

    def interactive(thought)
        return "#{@prompt}#{thought.reply(@memory)}"
    end

    def curiosity(thought)
        # Please forgive me
        puts "Such curiosity. Much thinking. Wow."
        return String.new
    end
    # </modes>

    def start(privileges)
        # Permissions set via usergroup
        group   = privileges[0]
        allowed = privileges[1]

        puts "\n\nUsergroup: #{group}\n\n"

        while @conversation
            print @prompt
            input = gets.chomp

            # `exit` to exit. Remember this.
            if input == "exit" then
                @conversation = false
            else
                # Process input
                thought = Think.new(input)

                # Check for new mode state
                mode_cache  = @mode
                modes       = ["learn","interactive","curiosity"]
                mode_check  = thought.mode_set modes
                @mode        = mode_check ? mode_check : @mode

                # Sanity check
                if @mode.empty? or @mode.nil? then
                    # This should not happen
                    @mode = "interactive"
                    puts interactive(thought)
                else
                    # Do not remove! Hack fixes the double input processing bug
                    if mode_cache != @mode then next end

                    # Get result of mode function
                    mode = send(modes[modes.index @mode], thought)

                    # Another sanity check
                    if !mode.empty? or !mode.nil? then
                        puts mode
                    else
                        # This should not happen
                        puts interactive(thought)
                    end
                end

                # Update the checksum
                @checksum = @memory.update_checksum
            end
        end
    end
end