#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Origin

=end

require_relative "bootstrap"

kai = Bootstrap.new "brain.json"
kai.header "0.4.1"
# Can users log in?
# What rights will they get?
kai.start(kai.rights(kai.login(true)))