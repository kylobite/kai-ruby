#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    Ruby port of KyloDocs
KyloDocs:   https://github.com/kylobite/kylodocs

=end

require "json"
require "tempfile"
require "fileutils"

class KyloDocs
    attr_reader :file, :data, :base, :dir, :path

    # Possibly add optional `file` param
    # Instead instance a one-use session
    # Will only manipulate `@data` param
    # Will run in :tmp: mode until close
    # I love writing evenly spaced lines
    # I also like messing with OCD people
    def initialize(file, path = nil)
        if exists file then
            @file = file
            @data = Hash.new
            @base = File.expand_path File.dirname __FILE__

            @path = path unless path == @base
            @path ||= locate base
            @dir  = "#{@path}/#{file}.json"

            if not File.exists? "#{@dir}" then create end
        end
    end

    # Is `var` empty or nil?
    # This is me being lazy
    def exists(var)
        return (var.nil? or var.empty?) ? false : true
    end

    def get(param)
        return (exists @data[param]) ? @data[param] : nil
    end

    def set(param, val)
        @data[param] = val
    end

    # Look for the `memories` folder
    # This is so YOU can be lazy
    def locate(start)
        content = Dir.entries start
        2.times { content.shift }

        # Let us hope we find it quickly
        content.each do |c|
            if c == "kylodocs"
                # Return is our safety line
                return "#{@base}/#{c}"
            end
        end

        # Time to look deeper
        content.each do |c|
            if File.directory? c then
                # Recursion!!!
                locate "#{start}/#{c}"
            end
        end

        # Please, never be this lazy
        FileUtils.mkpath("kylodocs") unless Dir.exist? "kylodocs"
        return "#{@base}/kylodocs"
    end

    # This is the magic behind the `update` function
    def set_array_key(hash, keys, key, value, mode)
        # [walking,down,this].inject(hash, :fetch) == hash[walking][down][this]
        # The above statement's format is how deep hash fetching works
        case mode
        when "remove"
            if key == "delete" then
                keys.inject(hash, :fetch).delete(value)
            else
                hash.delete(value)
            end
            return hash
        when "array"
            if exists keys then
                *keys, last = keys
                value.each do |v|
                    keys.inject(hash, :fetch)[last].push(v)
                end
            else
                hash[hash.size] = value
            end
            return hash
        when "put"              # Alias of `default`
            if exists keys then
                keys.inject(hash, :fetch)[key] = value
            else
                hash[key] = value
            end
            return hash
        when "put|array"
            if exists keys then
                *keys, last = keys
                keys.inject(hash, :fetch)[last.to_i] = value
            else
                raise "Missing variable error @ KyloDocs::set_array_key"
            end
            return hash
        when "put|array|last"
            if exists keys then
                *keys, last = keys
                put = keys.inject(hash, :fetch)[last].size - 1
                keys.inject(hash, :fetch)[last][put.to_i] = value
            else
                raise "Missing variable error @ KyloDocs::set_array_key"
            end
            return hash
        when "put|array|last|key"
            if exists keys then
                *keys, last = keys
                put = keys.inject(hash, :fetch)[last].size - 1
                keys.inject(hash, :fetch)[last][put.to_i][key] = value
            else
                raise "Missing variable error @ KyloDocs::set_array_key"
            end
            return hash
        when "new"
            if exists keys then
                *keys, last = keys
                keys.inject(hash, :fetch)[last] = {}
            else
                raise "Missing variable error @ KyloDocs::set_array_key"
            end
            return hash
        when "new|array"
            if exists keys then
                *keys, last  = keys
                keys.inject(hash, :fetch)[last] = []
                value.each do |v|
                    keys.inject(hash, :fetch)[last].push(v)
                end
            else
                raise "Missing variable error @ KyloDocs::set_array_key"
            end
            return hash
        when "default"
            if exists keys then
                keys.inject(hash, :fetch)[key] = value
            else
                hash[key] = value
            end
            return hash
        else
            raise "Parameter error @ KyloDocs::set_array_key"
        end
    end

    def serialize(hash)
        return "#{hash.to_json}"
    end

    def unserialize(string)
        return JSON.parse string
    end

    def create()
        File.open("#{@dir}", File::RDWR|File::CREAT, 0644) { |file| file.write({"#{@file}"=>{}}.to_json) }
    end

    def read(verbose = false, string = false)
        contents = File.open("#{@dir}") { |file| file.read }

        if string then
            return verbose ? (serialize contents)   : (serialize contents)[@file]
        else
            return verbose ? (unserialize contents) : (unserialize contents)[@file]
        end
        return String.new
    end

    # Query for terms in database
    ## terms = [index to look at, what value should be]
    ## grab  = what data you want from a match
    ## path  = where to look for index
    ## vague = check exact or close to
    def search(terms, grab, path = nil, vague = false)
        hash = read(true)
        keys = [@file] | path.split("/")
        output = nil
        look, expect = terms[0], terms[1]
        get = nil

        # Is an array being searched?
        if array then
            *keys, last = keys
            get ||= keys.inject(hash, :fetch)[last][look]
        else
            get ||= keys.inject(hash, :fetch)[last][look]
        end

        if get.kind_of? Array then
            get.each do |h|
                if vague then
                    if h[look] =~ expect then output = h[grab] end
                else
                    if h[look] == expect then output = h[grab] end
                end
                break if !output.nil?
            end
        else
            if vague then
                if get[look] =~ expect then output = get[grab] end
            else
                if get[look] == expect then output = get[grab] end
            end
        end unless not exists get
        return (output.nil?) ? nil : output
    end

    # Reverse search; same as DESC
    def rsearch(terms, grab, path = nil, vague = false, array = false)
        hash = read(true)
        keys = [@file] | path.split("/")
        output = nil
        look, expect = terms[0], terms[1]
        get = nil

        # Is an array being searched?
        if array then
            *keys, last = keys
            get ||= keys.inject(hash, :fetch)[last.to_i]
        else
            get ||= keys.inject(hash, :fetch)
        end

        # Reverse!
        if exists get then
            if get.kind_of? Hash
            then get = Hash[get.to_a.reverse][look]
            else get = get.reverse[look]
            end
        end

        # Reverse aspect
        if get.kind_of? Array then
            get.each do |h|
                if vague then
                    if h[look] =~ expect then output = h[grab] end
                else
                    if h[look] == expect then output = h[grab] end
                end
                break if !output.nil?
            end
        else
            if vague then
                if get[look] =~ expect then output = get[grab] end
            else
                if get[look] == expect then output = get[grab] end
            end
        end unless not exists get
        return (output.nil?) ? nil : output
    end

    # def update_mode(mode, hash, keys)
    #     if mode == "array" then
    #         hash = set_array_key(hash, keys, nil, data, mode)
    #     else
    #         @data.each {|k,v| hash = set_array_key(hash, keys, k, v, mode)}
    #     end
    #     return hash
    # end

    # I advice only doing this with a `new-array` combo
    def update(path = nil, mode = "default")
        hash = JSON.parse(File.open("#{@dir}") { |file| file.read })
        keys = [@file]
        keys = keys | path.split("/") unless not exists path or path == "*"

        # priority_mode = Array.new
        # # Is there more than one mode given?
        # if mode.kind_of? Array then
        #     # If so, determine which mode to run first

        #     # The order `mode` executes in
        #     priorities      = ["new","array","put","default","remove"]
        #     # Convert `priorities` to numerical hash table
        #     order           = Hash[priorities.map.with_index.to_a]
        #     # Complicated algorithm that sorts `mode` in the `priorities` order
        #     priority_mode   = mode.map{|k,v| [order[k],k]}.each.sort_by{|k,v| k}.map{|k,v| v}
        #     # Execute each mode
        #     priority_mode.each do |m|
        #         update_mode m, hash, keys
        #     end
        # else
        #     update_mode mode, hash, keys
        # end

        if mode == "array" || mode == "new|array" then
            send = data.map{|k,v| v}
            hash = set_array_key(hash, keys, nil, send, mode)
        else
            @data.each {|k,v| hash = set_array_key(hash, keys, k, v, mode)}
        end

        string  = hash.to_json.encode("UTF-8")
        tmp = Tempfile.new "tmp"
        tmp.write(string)
        FileUtils.mv(tmp.path, "#{@dir}")
        db = File.open("#{@dir}", File::RDWR|File::CREAT, 0644)
        db.flock(File::LOCK_EX)
        tmp.close
        tmp.unlink
        db.close
        @data = {}
        return true
    end

    def delete(verify = false)
        if verify then File.delete("#{@dir}") end
    end
end





