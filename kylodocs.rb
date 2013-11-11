#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    Ruby port of KyloDocs
KyloDocs:   https://github.com/kylobite/kylodocs

=end

require "json"

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
        Dir.mkdir("memories") unless Dir.exist? "memories"
        return "#{@base}/#{memories}"
    end

    def set_array_key(hash, new_key, value, keys, mode)
        case mode
        when "remove":
            if new_key == "delete" then
                *keys = keys.split("/")
                keys.inject(hash, :fetch).delete(value)
                return hash
            else
                hash.delete(value)
                return hash
            end
        when "array":
            if exists keys then
                *keys = keys.split("/")
                keys.inject(hash, :fetch)[hash.size] = value
                return hash
            else
                hash[hash.size] = value
                return hash
            end
        when "default":
            if exists keys then
                *keys = keys.split("/")
                keys.inject(hash, :fetch)[new_key] = value
                return hash
            else
                hash[new_key] = value
                return hash
            end
        else
            raise "Parameter error @ KyloDocs::set_array_key"
        end
    end

end





