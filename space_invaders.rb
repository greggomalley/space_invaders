#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')

require 'cli/args'
require 'core/invader_store'
require 'core/radar'
require 'output/terminal'
require 'output/html'

args = Args.parse

invaders = InvaderStore.build
scan_result = Radar.from_file(args.radar_file, threshold: args.threshold).scan(invaders)

args.formats.each do |format|
  io = format == 'html' ? File.open('radar.html', 'w') : $stdout
  Output.for(format).new(scan_result, io:).render
end
