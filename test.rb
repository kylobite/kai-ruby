#!/usr/bin/env ruby

require_relative "kylodocs"

kd = KyloDocs.new("brain", "memories")
kd.set "test", "test".reverse
#puts kd.read
kd.update
#puts kd.read
kd.delete true