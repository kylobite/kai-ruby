#!/usr/bin/env ruby

=begin

Developer:  Kylobite
Purpose:    KAI Origin

=end

require_relative "bootstrap"

kai = Bootstrap.new "brain"
kai.header "0.3.8"
# Can users log in?
# What rights will they get?
kai.start(kai.rights(kai.login(true)))