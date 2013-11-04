#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Bootstrap

=end

require_relative "memory"
require_relative "think"
#require_relative "config"

require "digest"

# Notes
# File: constants
#   use: File.open("constants").read.scan /(\w+):\s(.+)\n/

class Bootstrap
    attr_reader :memory, :session_id, :conversation, :mode, :prompt, :checksum

    # Set class constants
    def initialize(memories)
        # Grab the memory database
        dir             = File.expand_path File.dirname(__FILE__)
        memdir          = "#{dir}/#{memories}"
        @memory         = Memory.new(memdir)

        # Prepare for conversation
        @session_id     = Digest::SHA2.hexdigest(Time.now.to_f.to_s)[0..11]
        @conversation   = true
        @mode = "interactive"
        @prompt         = "> "

        # Grab the checksum of the memory database
        @checksum = File.open("#{dir}/checksum") {|file| file.read}
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
        return ""
    end
    # </modes>

    def start()
        while @conversation
            print @prompt
            input = gets.chomp

            # `exit` to exit. Remember this.
            if input == "exit" 
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
                if @mode.empty? or @mode.nil?
                    # This should not happen
                    @mode = "interactive"
                    puts interactive(thought)
                else
                    # Do not remove! Hack fixes the double input processing bug
                    if mode_cache != @mode then next end

                    # Get result of mode function
                    mode = send(modes[modes.index @mode], thought)

                    # Another sanity check
                    if mode.empty? or mode.nil?
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