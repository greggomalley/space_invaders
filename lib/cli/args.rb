# frozen_string_literal: true

require 'optparse'

class Args
  attr_reader :radar_file, :formats, :threshold

  def self.parse(argv = ARGV)
    new.tap { |a| a.parse(argv) }
  end

  def initialize
    @formats   = ['terminal']
    @threshold = 0.8
  end

  def parse(argv)
    OptionParser.new do |opts|
      opts.banner = 'Usage: space_invaders.rb [options] radar_file'

      opts.on('-f', '--format FORMAT', 'Output format(s): terminal, html (comma-separated)') do |f|
        @formats = f.split(',').map(&:strip)
      end

      opts.on('-t', '--threshold FLOAT', Float, 'Match threshold (default: 0.7)') do |t|
        abort 'Error: threshold must be between 0 and 1' unless (0.0..1.0).cover?(t)
        @threshold = t
      end
    end.parse!(argv)

    @radar_file = argv.shift
    abort "Error: radar file required\nUsage: space_invaders.rb [options] radar_file" unless @radar_file
    abort "Error: file not found: #{@radar_file}" unless File.exist?(@radar_file)
  end
end
