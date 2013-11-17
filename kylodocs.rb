#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    Ruby port of KyloDocs
Version:    1.0
KyloDocs:   https://github.com/kylobite/kylodocs

=end

require "json"
require "tempfile"
require "fileutils"

class KyloDocs
    attr_reader :file, :data, :base, :dir, :path

    def initialize(file, path = nil)
        if exists file then
            @file = file
            @data = Hash.new
            @base = File.expand_path File.dirname __FILE__

            @path ||= search base
            @dir    = "#{@path}/#{file}"

            if not File.exists? "#{@dir}.json" then create end
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

    def set_array_key(hash, keys, key, value, mode)
        case mode
        when "remove"
            if key == "delete" then
                keys.inject(hash, :fetch).delete(value)
                # hash.deep_fetch(keys).delete(value)
            else
                hash.delete(value)
            end
            return hash
        when "array"
            if exists keys then
                keys.inject(hash, :fetch)[hash.size] = value
                # hash.deep_fetch(keys)[hash.size] = value
            else
                hash[hash.size] = value
            end
            return hash
        when "new"
            if exists keys then
                *keys, last = keys
                keys.inject(hash, :fetch)[last] = {key=>value}
                # hash.deep_fetch([keys])[last] = {key=>value}
            else
                raise "Missing variable error @ KyloDocs::set_array_key"
            end
            puts hash
            return hash
        when "default"
            if exists keys then
                keys.inject(hash, :fetch)[key] = value
                # hash.deep_fetch(keys)[key] = value
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
        File.open("#{@dir}.json", File::RDWR|File::CREAT, 0644) { |file| file.write({"#{@file}"=>{}}.to_json) }
    end

    def read(string = false)
        contents = File.open("#{@dir}.json") { |file| file.read }

        if string then
            return serialize contents
        else
            return unserialize contents
        end
        return String.new
    end

    # Give ability to perform multiple modes, add priorities
    def update(path = nil, mode = "default")
        hash = JSON.parse(File.open("#{@dir}.json") { |file| file.read })
        keys = [@file] | path.split("/") unless not exists path or path == "*"

        if mode == "array" then
            hash = set_array_key(hash, keys, nil, data, mode)
        else
            @data.each {|k,v| hash = set_array_key(hash, keys, k, v, mode)}
        end

        string  = hash.to_json.encode("UTF-8")
        tmp = Tempfile.new "tmp"
        tmp.write(string)
        FileUtils.mv(tmp.path, "#{@dir}.json")
        db = File.open("#{@dir}.json", File::RDWR|File::CREAT, 0644)
        db.flock(File::LOCK_EX)
        tmp.close
        tmp.unlink
        db.close
        @data = {}
        return true
    end

    def delete(verify = false)
        if verify then File.delete("#{@dir}.json") end
    end
end

# class Hash
#     def deep_fetch(keys)
#         keys.inject(self) { |obj, key| obj[key] if obj.respond_to? :[] }
#     end
# end





