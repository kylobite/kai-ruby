#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Config Parser

=end

require "json"

# JSON.parse(json_code) => hash_code

class Config
    attr_reader :config

    def initialize(config)
        dir = File.expand_path File.dirname(__FILE__)
        json = File.open("#{dir}/#{config}") {|file| file.read}
        @config = JSON.parse(json)
    end

end