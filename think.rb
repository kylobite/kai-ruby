#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Thought Process

=end

class Think
	def initialize(string)
		@string = string
	end

	# Determine if mode was set
	def mode_set()
		phrase = @string.scan(/~&\\\\mode:.+/)
		if phrase.nil? or phrase.empty?
			return false
		else
			extract = @string.scan(/~&\\\\mode:(.+)/)[0][0]
			modes = Array.new("learn", "interactive", "curiosity")
			modes.each do |mode|
				if extract == mode
					return mode
				else
					return nil
				end
			end
		end
	end

	# Reply to user input; Setting the memory database
	def reply(memories)
		known_phrases = File.open(memories).read.scan(/\[(.*)\]/).flatten

		# Default responses if memory database is empty/nonexistent
		if known_phrases.nil? or known_phrases.empty?
			greeting = ["hi", "hello", "hey"]
			return greeting[Random.new.rand(greeting.size)].capitalize + "."
		else
			use = lookup(known_phrases)
			content = use.inject {|sum,u| sum + u }

			# Do if KAI thought of something
			if content > 0
				return known_phrases[use.index(use.max)].capitalize
			# Do if KAI is clueless at the moment
			else
				# Last Resort

				# Consult thesaurus
				# Look for similiar words
				# If all fails: Store string in curiosity and random

				return known_phrases[Random.new.rand(known_phrases.size)].capitalize
			end
		end
	end

	# Process user input and cross-reference with memories
	def lookup(known_phrases)
		# Tokenize user input
		said = Array.new
		said_phrase = @string.scan(/[a-zA-Z0-9'-]+/).flatten.each do |s|
			said.push(s.downcase)
		end

		used = Array.new
		u = 0
		# Cross-referencing
		known_phrases.each do |kp|
			used.push(0)
			# Tokenize memories
			kp.scan(/[a-zA-Z0-9'-]+/).each do |k|
				said.each do |p|
					if p == k
						used[u] += 1
					end
				end
			end
			u += 1
		end

		return used
	end
end