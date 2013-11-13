#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    Ruby port of KyloDocs
KyloDocs:   https://github.com/kylobite/kylodocs

=end

require "json"
require "fileutils"

class KyloDocs
    attr_reader :file, :data, :base, :dir, :path

    def initialize(file, path = nil)
        if exists file then
            @file = file
            @data = Hash.new
            @base = File.expand_path File.dirname __FILE__

            @path ||= search base
            @dir    = "#{@path}/#{file}.json"

            if not File.exists? @dir then created end
        end
    end

    # Is `var` empty or nil?
    # This is me being lazy
    def exists(var)
        return (!var.empty? and !var.nil?) ? true : false
    end

    def get(param)
        return (exists @data[param]) ? @data[param] : nil
    end

    def set(param, val)
        @data[param] = val
    end

    # Look for the `memories` folder
    # This is so YOU can be lazy
    def search(start)
        contents = Dir.entries start
        2.times { contents.shift }

        # Let us hope we find it quickly
        contents.each do |c|
            if c == "memories"
                # Return is our safety line
                return "#{@base}/#{c}"
            end
        end

        # Time to look deeper
        contents.each do |c|
            if File.directory? c then
                # Recursion!!!
                search c
            end
        end

        # Please, never be this lazy
        FileUtils.mkpath("memories") unless Dir.exist? "memories"
        return "#{@base}/#{memories}"
    end

    def set_array_key(hash, new_key, value, keys, mode)
        case mode
        when "remove":
            if new_key == "delete" then
                *keys = keys.split("/")
                keys.inject(hash, :fetch).delete(value)
            else
                hash.delete(value)
            end
            return hash
        when "array":
            if exists keys then
                *keys = keys.split("/")
                keys.inject(hash, :fetch)[hash.size] = value
            else
                hash[hash.size] = value
            end
            return hash
        when "default":
            if exists keys then
                *keys = keys.split("/")
                keys.inject(hash, :fetch)[new_key] = value
            else
                hash[new_key] = value
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
        File.open("#{@file}.json", File::RDWR|File::CREAT, 0644) { |file| file.write({"#{@file}"=>nil}.to_json) }
    end

    def read(string = false)
        contents = File.open("#{@file}.json") { |file| file.read }

        if string then
            return serialize contents
        else
            return contents
        end
        return String.new
    end

    def update(mode = default, path = null)
        string
        keys = Array.new @file
        if exists path and path != "*" then
            keyring = path.split("/")
            keyring.each do {|key| keys << key}
        end

        if mode == "array" then
            set_array_key(string,null,data,keys,mode)
        else
            
        end
    end

    def delete(verify = false)
        if verify then File.delete("#{@file}.json") end
    end
end





