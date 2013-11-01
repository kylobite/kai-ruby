#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Bootstrap

=end

require_relative "memory"
require_relative "think"

require "digest"

dir             = File.expand_path File.dirname(__FILE__)
memories        = "brain.db"
mem_dir         = dir + "/" + memories
memory          = Memory.new(mem_dir)
session_id      = Digest::SHA2.hexdigest(Time.now.to_f.to_s)[0..11]
conversation    = true
prompt          = "> "

puts
puts " KAI v0.2"
puts "------------------"
puts

# Grab the checksum of the memory database
checksum = File.open(dir + "/checksum") {|file| file.read}
mode = "interactive"

while conversation
    print prompt
    input = gets.chomp
    # Exit to exit. Remember this.
    if input == "exit" 
        conversation = false
    else
        # Process input
        thought = Think.new(input)

        # Check for new mode state
        mode_cache = mode
        mode_check = thought.mode_set
        mode = mode_check ? mode_check : mode

        if !mode or mode.nil?
            # This really should not happen
            mode = "interactive"
            puts "#{prompt}#{thought.reply(dir + '/tmp')}"
        else
            # Fixes 'double input processing' bug
            # Do not remove
            if mode_cache != mode
                next
            end

            # Initiate mode
            if mode == "learn"
                puts "#{thought.learn(memory, session_id)}"
            elsif mode == "interactive"
                puts "#{prompt}#{thought.reply(dir + '/tmp')}"
            elsif mode == "curiosity"
                # Be curios about stuff
            else
                # This should not happen
                puts "#{prompt}#{thought.reply(dir + '/tmp')}"
            end
        end
    end
end
