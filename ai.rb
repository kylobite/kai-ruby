#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Bootstrap

=end

require "./memory"
require "./think"

mem 			= "brain.db"		
memory 			= Memory.new(mem)
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
			puts "#{prompt}#{thought.reply('tmp')}"
		else
			# Initiate mode
			if mode == "learn"
				# Learn stuff
			elsif mode == "interactive"
				# Interact with stuff
			elsif mode == "curiosity"
				# Be curios about stuff
			else
				# This should never happen
				raise InvalidError, "What did you do..."
			end
		end
		# File.open("test", "a") {|file| file.write("[#{input.downcase}]\n")}
	end
end