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
    def mode_set(modes)
        phrase = @string.scan(/~&\/\/mode:.+/).flatten[0]
        if phrase.nil? or phrase.empty? then
            return false
        end

        extract = phrase.scan(/~&\/\/mode:(.+)/).flatten[0]
        modes.each do |mode|
            if extract == mode then
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
        if memories.nil? or memories.empty? then
            greeting = ["hi", "hello", "hey"]
            return greeting[Random.new.rand(greeting.size)].capitalize + "."
        end

        use = lookup(memories)
        content = use.inject {|sum,u| sum + u }

        # Do if KAI thought of something
        if content > 0 then
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
                    if s == m then
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
        if process.nil? or process.empty? then
            print "Error: Invalid learning syntax!"
            return
        end

        # Categorize sentence type
        type = nil
        [".","?","!"].each do |t|
            if t == process[-1] then
                type = process[-1]
            end
        end

        # How dare you use improper grammar!
        if type.nil? then
            return "Error: Invalid punctuation! KAI only accepts proper grammar."
        end


        # Determine if input or output
        io = process.scan(/\|\s([xyXY]):\s.*/).flatten[0]

        # Check empty output for Y
        output = memory.db.execute("SELECT id FROM statement WHERE output='&' ORDER BY id DESC LIMIT 1")[0]
        id = (output.nil?) ? nil : output

        if io.downcase == "x" and !id.nil? then
            id += 1
        end

        uniqid      = nil
        io_match    = nil
        io_matching = nil

        # ID and Unique ID
        if id.nil? then
            # Generate new id
            get_id      = memory.db.execute("SELECT id FROM statement ORDER BY id DESC LIMIT 1").flatten[0]
            id = get_id.nil? ? "0" : get_id + 1

            # Generate new IO match
            unique      = memory.db.execute("SELECT uniqid FROM statement WHERE uniqid 
                                             LIKE ? ORDER BY id DESC LIMIT 1",["#{session_id}____"]).flatten[0]
            io_match    = (unique.nil?) ? "0" : (unique[(unique.size - 4),(unique.size)].to_s.to_i(16).to_s(10).to_i + 1)
            io_matching = "%x" % io_match

            # IO match needs to be four characters
            if io_matching.size != 4 then
                (4 - io_matching.size).times { io_matching = "0#{io_matching}" }
            end

            # Create unique ID
            uniqid          = "#{session_id}#{io_matching}"
            if uniqid.size != 16 then
                puts "Error: Uniqid is messed up: #{uniqid}"
            end
        end

        # Grab text to remember
        remember = process.scan(/\|\s[xyXY]:\s(.*)/).flatten[0]
        if io.downcase == "x" then
            memory.db.execute("INSERT INTO statement (id,input,output,scales,type,uniqid) 
                               VALUES (?,?,?,?,?,?)",[id,remember,'&','[0]',type,uniqid])
            return "'#{remember}'"
        elsif io.downcase == "y"
            memory.db.execute("UPDATE statement SET output=? WHERE id=?",[remember,id])
            return "'#{remember}'"
        else
            # This should never happen
            raise "Logic error @ Think::learn"
        end
    end
end