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
    def reply(memory)
        memories = memory.db.execute("SELECT input, output FROM statement")

        # Default responses if memory database is empty/nonexistent
        if memories.nil? or memories.empty?
            greeting = ["hi", "hello", "hey"]
            return greeting[Random.new.rand(greeting.size)].capitalize + "."
        end

        use = lookup(memories)
        content = use.inject {|sum,u| sum + u }

        # Do if KAI thought of something
        if content > 0
            return memories[use.index(use.max)][1]
        # Do if KAI is clueless at the moment
        else
            # Last Resort

            # Consult thesaurus
            # Look for similiar words
            # If all fails: Store string in curiosity and random

            return memories[Random.new.rand(memories.size)][1]
        end
    end

    # Process user input and cross-reference with memories
    def lookup(memories)
        # Tokenize user input
        said = Array.new
        said_phrase = @string.scan(/[a-zA-Z0-9'-]+/).flatten.each do |sp|
            said.push(sp.downcase)
        end

        used = Array.new
        u = 0
        # Cross-referencing
        memories.each do |ms|
            used.push(0)
            # Tokenize memories
            ms[0].downcase.scan(/[a-zA-Z0-9'-]+/).each do |m|
                said.each do |s|
                    if s == m
                        used[u] += 1
                    end
                end
            end
            u += 1
        end

        return used
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

        # Check for empty output
        output = memory.db.execute("SELECT id FROM statement WHERE output='&' ORDER BY id DESC LIMIT 1")[0]
        id = (output.nil?) ? nil : output

        uniqid      = nil
        io_match    = nil
        io_matching = nil

        # Get uniqid
        if id.nil?
            # Generate new id
            get_id      = memory.db.execute("SELECT id FROM statement ORDER BY id DESC LIMIT 1").flatten[0]
            id = get_id.nil? ? 0 : get_id + 1

            # No empty outputs
            unique      = memory.db.execute("SELECT uniqid FROM statement WHERE id=?",[get_id])[0]
            io_match    = (unique.nil?) ? "0" : (unique[(unique.size - 4),(unique.size)].to_s.to_i(16).to_s(10).to_i + 1)

            # ~

            io_matching     = "%x" % io_match
            if io_matching.size != 4
                (4 - io_matching.size).times { io_matching = "0#{io_matching}" }
            end

            # Needs to be 4 characters

            uniqid          = "#{session_id}#{io_matching}"
            if uniqid.size != 16 
                puts "Error: Uniqid is messed up: #{uniqid}"
            end
        end
        # else
        #     # Empty output!
        #     unique      = memory.db.execute("SELECT uniqid FROM statement WHERE id=?",[id])[0]
        #     io_match    = unique[(unique.size - 4),(unique.size)].to_s.to_i(16).to_s(10).to_i
        # end
        # io_matching     = "%x" % io_match
        # if io_matching.size != 4
        #     (4 - io_matching.size).times { io_matching = "0#{io_matching}" }
        # end

        # # Needs to be 4 characters

        # uniqid          = "#{session_id}#{io_matching}"
        # if uniqid.size != 16 
        #     puts "Error: Uniqid is messed up: #{uniqid}"
        # end

        # Check syntax
        io       = process.scan(/\|\s([xyXY]):\s.*/).flatten[0]
        remember = process.scan(/\|\s[xyXY]:\s(.*)/).flatten[0]
        if io == "x"
            memory.db.execute("INSERT INTO statement (id,input,output,scales,type,uniqid) 
                               VALUES (?,?,?,?,?,?)",[id,remember,'&','[0]',type,uniqid])
            return "'#{remember}'"
        elsif io == "y"
            memory.db.execute("UPDATE statement SET output=? WHERE id=?",[remember,id])
            return "'#{remember}'"
        else
            # This should really never happen
            raise "Logic error @ Think::learn"
        end
    end
end