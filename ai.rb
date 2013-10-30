#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Bootstrap

=end

require_relative "memory"
require_relative "think"

dir 			= File.expand_path File.dirname(__FILE__)
source 			= "/brain.db"
mem_src			= dir + source
memory 			= Memory.new(mem_src)
conversation	= true
prompt			= "> "

puts
puts "---------------------------------------"
puts "| [KAI] : KAI Artificial Intelligence |"
puts "---------------------------------------"
puts

# Grab the checksum of the memory database
checksum = File.open("checksum") {|file| file.read}

while conversation
	print prompt
	input = gets.chomp
	# Exit to exit. Remember this.
	if input == "exit" 
		conversation = false
	else
		#Figure out what to say
		thought = Think.new(input)
		mode = thought.mode_set
		if !mode or !mode.nil?
			puts "#{prompt}#{thought.reply(dir + '/tmp')}"
		else
			# Initiate mode
			if mode == "learn"
				# Learn stuff
			elsif mode == "interactive"
				puts "#{prompt}#{thought.reply(dir + '/tmp')}"
			elsif mode == "curiosity"
				# Be curios about stuff
			else
				# This should not happen
				puts "I don't understand..."
			end
		end
		# File.open("test", "a") {|file| file.write("[#{input.downcase}]\n")}
	end
end
