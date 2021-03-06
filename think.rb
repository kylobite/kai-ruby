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
        # Does it look like a mode?
        if phrase.nil? or phrase.empty? then
            return false
        end

        # Can the user access this mode?
        state = false
        extract = phrase.scan(/~&\/\/mode:(.+)/).flatten[0]
        modes.each do |mode|
            if extract == mode then
                state = true
                puts "Starting #{mode} mode..."
                return mode
            end
        end

        # Tell user the mode failed
        if not state then
            puts "Invalid or unauthorized mode"
        end
        return nil
    end

    # Reply to user input; Setting the memory database
    def reply(memory)
        # memories = memory.db.execute "SELECT input, output FROM statement"
        kd          = memory.kd
        memories    = kd.read["statement"]

        # Default responses if memory database is empty/nonexistent
        if memories.nil? or memories.empty? then
            greeting = ["hi", "hello", "hey"]
            return greeting[Random.new.rand(greeting.size)].capitalize + "."
        end

        use = lookup memories
        content = use.inject {|sum,u| sum + u }

        # Do if KAI thought of something
        if content > 0 then
            return memories[use.index(use.max)]["output"]
        # Do if KAI is clueless at the moment
        else
            # Last Resort

            # Consult categories
            # Look for similiar words
            # If all fails: Store string in curiosity and random

            return memories[Random.new.rand(memories.size)]["output"]
        end
    end

    # Process user input and cross-reference with memories
    def lookup(memories)
        # Tokenize user input
        said = Array.new
        said_phrase = @string.scan(/[a-zA-Z0-9'-]+/).flatten.each do |sp|
            said << sp.downcase
        end

        used = Array.new
        u = 0
        # Cross-referencing
        memories.each do |ms|
            used << 0
            # Tokenize memories
            ms["input"].downcase.scan(/[a-zA-Z0-9'-]+/).each do |m|
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

        # Alias to KyloDocs
        kd = memory.kd

        # Check empty output for Y
        # unique = memory.db.execute("SELECT id FROM statement WHERE output='&' ORDER BY id DESC LIMIT 1")[0]
        unique = kd.rsearch(["output",'&'],"id","statement", true, true) unless not kd.exists kd.read["statement"]
        if unique.kind_of? String then unique = unique.to_i end
        id = (unique.nil?) ? nil : unique

        if io.downcase == "x" and not id.nil? then
            id += 1
        end

        uniqid      = nil
        io_match    = nil
        io_matching = nil

        # ID and Unique ID
        if id.nil? then
            # Generate new id
            # get_id = memory.db.execute("SELECT id FROM statement ORDER BY id DESC LIMIT 1").flatten[0]
            get_id = (kd.read["statement"].reverse)[0]["id"] unless not kd.exists kd.read["statement"]
            id = get_id.nil? ? "0" : (get_id.to_i + 1).to_s

            # Generate new IO match
            # unique      = memory.db.execute("SELECT uniqid FROM statement WHERE uniqid 
            #                                  LIKE ? ORDER BY id DESC LIMIT 1",["#{session_id}____"]).flatten[0]
            unique = kd.rsearch(["uniqid",/#{session_id}.{4}/],"id","statement", true, true) unless not kd.exists kd.read["statement"]
            if unique.kind_of? String then unique = unique.to_i end
            io_match    = unique.nil? ? "0" : (unique[(unique.size - 4),(unique.size)].to_s.to_i(16).to_s(10).to_i + 1)
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
            # memory.db.execute("INSERT INTO statement (id,input,output,scales,type,uniqid) 
            #                    VALUES (?,?,?,?,?,?)",[id,remember,'&','[0]',type,uniqid])
            # kd.set("id",      id)
            # kd.set("input",   remember)
            # kd.set("output",  '&')
            # kd.set("scales",  '[0]')
            # kd.set("type",    type)
            # kd.set("uniqid",  uniqid)
            kd.set 0, {
                "id"       => id,
                "input"    => remember,
                "output"   => '&',
                "scales"   => '[0]',
                "type"     => type,
                "uniqid"   => uniqid
            }
            kd.update("statement", "array")
            return "'#{remember}'"
        elsif io.downcase == "y"
            # memory.db.execute("UPDATE statement SET output=? WHERE id=?",[remember,id])
            kd.set("output", remember)
            kd.update("statement", "put|array|last|key")
            return "'#{remember}'"
        else
            # This should never happen
            raise "Logic error @ Think::learn"
        end
    end
end