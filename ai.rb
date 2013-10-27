#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Bootstrap

=end

# TODO
#
# respond
# clean up
# make keyphrases
# order: T->Q|S|C

#~&\\\\mode:.+

require "./memory"
require "./think"

memory 			= Memory.new
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
	if input == "exit" 
		conversation = false
	else
		#Figure out what to say
		thought = Think.new(input)
		puts "#{prompt}#{thought.reply('tmp')}"
		# File.open("test", "a") {|file| file.write("[#{input.downcase}]\n")}
	end
end