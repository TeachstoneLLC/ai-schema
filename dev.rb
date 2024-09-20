#!/usr/bin/env ruby
# == Wrapper script to update a local postgrseql database
#
# == Usage
#  ./dev.rb
#

Dir.chdir(File.dirname($0)) {
  command = "sem-apply --url postgresql://svc_ai@localhost:5432/ai_development"
  puts command
  exec(command)
}
