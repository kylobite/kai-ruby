#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Origin

=end

require_relative "bootstrap"
require "fileutils"

command = ARGV.shift

# Runtime commands
if !command.nil? then
    case command
    when "--reboot"
        dir = File.expand_path File.dirname __FILE__
        FileUtils.rm_r "#{dir}/memories/"
    else
    end
end

kai = Bootstrap.new "brain"
kai.header "0.4.5"

# Can users log in?
# What rights will they get?
kai.start(kai.rights(kai.login(true)))