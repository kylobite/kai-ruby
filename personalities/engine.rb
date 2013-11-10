#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Personality Engine

=end

require "json"

# This will be the parent class of all Personalities
class Engine
    attr_reader :dir, :partitions

    def initialize(engine)
        if not engine[/.+\.json/].nil? then
            @dir        = File.expand_path File.dirname __FILE__
            base        = File.open("#{@dir}/#{engine}") {|file| file.read}
            json        = JSON.parse base
            @partitions = json["partitions"]
        else
            raise "Fatal Error @ Engine::initialize"
        end
    end

    def quadrals(location)
        quadrals = "#{@dir}/#{location}/quadrals"
        if not File.exist? quadrals then raise "Fatal Erro @ Engine::quadrals" end
        # Scan location directory
    end

    def load(path)

    end

    # Ditch JSON, make files with custom API syntax
    # Make methods to run API functions
end