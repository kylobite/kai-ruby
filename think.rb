#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Thought Process

=end

class Think
    attr_reader :string

    def initialize(string)
        @string     = string
        @increment  = nil
    end

    # Determine if mode was set
    def mode_set()
        phrase = @string.scan(/~&\/\/mode:.+/).flatten[0]
        if phrase.nil? or phrase.empty?
            return false
        end

        extract = phrase.scan(/~&\/\/mode:(.+)/).flatten[0]
        modes = ["learn", "interactive", "curiosity"]
        modes.each do |mode|
            if extract == mode
                puts "Starting #{mode} mode..."
                return mode
            end
        end
        return false
    end

    # Reply to user input; Setting the memory database
    def reply(memories)
        known_phrases = File.open(memories).read.scan(/\[(.*)\]/).flatten[0]

        # Default responses if memory database is empty/nonexistent
        if known_phrases.nil? or known_phrases.empty?
            greeting = ["hi", "hello", "hey"]
            return greeting[Random.new.rand(greeting.size)].capitalize + "."
        end

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

    # Process user input and (hopefully) index it as a memory
    def learn(memory, session_id)
        process = @string.scan(/\|\s[xyXY]:\s.*/).flatten[0]
        if process.nil? or process.empty?
            print "Error: Invalid learning syntax!"
            return
        end

        # Sentence, question, or command?
        type = nil
        [".","?","!"].each do |t|
            if t == process[-1]
                type = process[-1]
            end
        end

        # How dare you use improper grammar!
        if type.nil?
            return "Error: Invalid punctuation! KAI only accepts proper grammar."
        end

        # Use punctuation to determine table
        tables = {
            "." => "statement",
            "?" => "question",
            "!" => "command"
        }
        table = tables[type]

        # Check for empty output
        output = memory.db.execute("SELECT id FROM #{table} WHERE output='&' ORDER BY id DESC LIMIT 1")[0]
        id = (output.nil?) ? nil : output

        uniqid      = nil
        io_match    = nil

        # Get uniqid
        if id.nil?
            # No empty outputs
            unique      = memory.db.execute("SELECT uniqid FROM #{table} ORDER BY id DESC LIMIT 1")[0]
            io_match    = (unique.nil?) ? "0" : (unique[(unique.size - 4),(unique.size)].to_s.to_i(16).to_s(10).to_i + 1)
        else
            # Empty output!
            unique      = memory.db.execute("SELECT uniqid FROM #{table} WHERE id=?",[id])[0]
            io_match    = unique[(unique.size - 4),(unique.size)].to_s.to_i(16).to_s(10).to_i
        end
        io_matching     = "%x" % io_match

        # Needs to be 4 characters
        if io_matching.size != 4
            (4 - io_matching.size).times { io_matching = "0#{io_matching}" }
        end

        uniqid          = "#{session_id}#{io_matching}"
        if uniqid.size != 16 
            puts "Error: Uniqid is messed up: #{uniqid}"
        end

        # Check syntax
        io       = process.scan(/\|\s([xyXY]):\s.*/).flatten[0]
        remember = process.scan(/\|\s[xyXY]:\s(.*)/).flatten[0]
        if io == "x"
            memory.db.execute("INSERT INTO #{table} (id,input,output,scales,uniqid) VALUES (?,?,?,?,?)",[nil,remember,'&','[0]',uniqid])
            return "'#{remember}'"
        elsif io == "y"
            memory.db.execute("UPDATE #{table} SET output=? WHERE uniqid=?",[remember,uniqid])
            return "'#{remember}'"
        else
            # This should really never happen
            raise "Logic error @ Think::learn"
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