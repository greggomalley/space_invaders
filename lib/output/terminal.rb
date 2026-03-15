# frozen_string_literal: true

require_relative 'output'

module Output
  class Terminal
    register

    INVADER_COLOURS = [
      "\e[32m",   # green
      "\e[33m",   # yellow
      "\e[34m",   # blue
      "\e[35m",   # magenta
      "\e[36m" # cyan
    ].freeze

    def initialize(scan_result, io: $stdout)
      @scan_result = scan_result
      @io = io
    end

    def render
      render_map
      render_legend
      render_detections
    end

    private

    def colour_map
      @colour_map ||= @scan_result.results
                                  .map { |r| r.invader.name }
                                  .uniq
                                  .each_with_index
                                  .to_h do |name, i|
        [name,
         INVADER_COLOURS[i % INVADER_COLOURS.size]]
      end
    end

    def render_map
      rows = Array.new(@scan_result.height) do |r|
        Array.new(@scan_result.width) { |c| @scan_result[r, c] }
      end

      @scan_result.results.each do |result|
        colour  = colour_map[result.invader.name]
        invader = result.invader
        (result.y...(result.y + invader.height)).each do |row|
          (result.x...(result.x + invader.width)).each do |col|
            next if row.negative? || col.negative? || row >= rows.size || col >= rows[row].size

            rows[row][col] = "#{colour}#{rows[row][col]}\e[0m"
          end
        end
      end

      rows.each { |row| @io.puts row.join }
    end

    def render_legend
      @io.puts "\nLegend:"
      colour_map.each do |name, colour|
        @io.puts "  #{colour}#{name}\e[0m"
      end
    end

    def render_detections
      @io.puts "\nDetections:"
      @scan_result.results.sort_by { |r| -r.score }.each do |r|
        @io.puts "  #{r.invader.name} at (#{r.x}, #{r.y}) - score: #{(r.score * 100).round(1)}%"
      end
    end
  end
end
