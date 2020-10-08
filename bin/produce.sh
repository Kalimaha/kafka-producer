#!/usr/bin/env ruby

require_relative "../producer"

puts "======================================================="
puts "\tPublish random order to Kafka: START..."
puts "======================================================="
Producer.produce
puts "======================================================="
puts "\tPublish random order to Kafka: ...DONE"
puts "======================================================="
