#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Configuration Parser

=end

require "json"
require "io/console"

class Configuration
    attr_reader :json, :groups, :users, :sudo

    def initialize()
        dir     = File.expand_path File.dirname __FILE__
        json    = File.open("#{dir}/config.json") {|file| file.read}
        @json   = JSON.parse json
        @groups = @json["groups"]
        @users  = @json["users"]
        @sudo   = @json["sudo"]
    end

    # Determine if user data is exists
    def validate()
        print "Username:  "
        user = gets.chomp

        # Check user value
        user_state = [false]
        @users.keys.each do |u|
            if u == user then
                user_state[0] = true
                user_state.push @users[user]["group"]
                next
            end
        end

        if user_state and (!user_state.nil? or !user_state.empty?) then
            print "Passwords: "
            password = STDIN.noecho(&:gets).gsub(/\n/,"")

            # Check password value
            password_state = false
            @sudo["passphrases"].each do |p|
                if (p[0] == user_state[1]) and (p[1] == password) then
                    password_state = true
                    next
                end
            end

            if password_state then
                group = @users[user]["group"]

                # Sanity check
                if !group.empty? then
                    return group
                else 
                    return "guest"
                end
            else
                return "guest"
            end
        else
            return "guest"
        end
    end

    def privileges(group)
        rights = @sudo["privileges"][group]

        # Sanity check
        if rights.nil? or rights.empty?
            return [ "plebeian", @sudo["privileges"]["plebeian"] ]
        else
            return [ group, rights ]
        end
    end

end



