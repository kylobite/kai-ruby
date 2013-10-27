#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Bootstrap

=end

class Think
	def initialize(string)
		@string = string
	end

	def reply(memory)
		known_phrases = File.open(memory).read.scan(/\[(.*)\]/).flatten

		if known_phrases.nil? or known_phrases.empty?
			greeting = ["hi", "hello", "hey"]
			return greeting[Random.new.rand(greeting.size)].capitalize + "."
		else
			use = lookup(known_phrases)
			content = use.inject {|sum,u| sum + u }

			if content > 0
				return known_phrases[use.index(use.max)].capitalize
			else
				# Consult thesaurus
				# Look for similiar words
				# If all fails: Store string in curiosity and random
				return known_phrases[Random.new.rand(known_phrases.size)].capitalize
			end
		end
	end

	def lookup(known_phrases)
		# known = Array.new
		# known_phrases.each do |k|
		# 	known.push(k.scan(/[a-zA-Z0-9'-]+/))
		# end

		said = Array.new
		said_phrase = @string.scan(/[a-zA-Z0-9'-]+/).flatten.each do |s|
			said.push(s.downcase)
		end

		used = Array.new
		u = 0
		known_phrases.each do |kp|
			used.push(0)
			kp.scan(/[a-zA-Z0-9'-]+/).each do |k|
				found = false
				said.each do |p|
					if p == k
						used[u] += 1
						found = !found
					end
					break if found
				end
			end
			u += 1
		end

		return used
	end
end