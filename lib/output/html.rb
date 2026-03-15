# frozen_string_literal: true

require_relative 'output'

module Output
  class Html
    register

    INVADER_COLOURS = [
      '#22c55e',  # green
      '#eab308',  # yellow
      '#3b82f6',  # blue
      '#a855f7',  # magenta
      '#06b6d4'   # cyan
    ].freeze

    def initialize(scan_result, io: $stdout)
      @scan_result = scan_result
      @io = io
    end

    def render
      @io.write(build)
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

    def cell_colours
      @cell_colours ||= {}.tap do |colours|
        @scan_result.results.each do |result|
          colour  = colour_map[result.invader.name]
          invader = result.invader
          (result.y...(result.y + invader.height)).each do |row|
            (result.x...(result.x + invader.width)).each do |col|
              next if row.negative? || col.negative? || row >= @scan_result.height || col >= @scan_result.width

              colours[[row, col]] = colour
            end
          end
        end
      end
    end

    def render_grid
      rows = @scan_result.height.times.map do |r|
        cols = @scan_result.width.times.map do |c|
          char   = @scan_result[r, c]
          colour = cell_colours[[r, c]]
          colour ? "<span style=\"color:#{colour}\">#{char}</span>" : char
        end
        cols.join
      end
      "<pre>#{rows.join("\n")}</pre>"
    end

    def render_legend
      items = colour_map.map do |name, colour|
        "<li><span style=\"color:#{colour}\">&#9632;</span> #{name}</li>"
      end
      "<h2>Legend</h2><ul>#{items.join}</ul>"
    end

    def render_detections
      items = @scan_result.results.sort_by { |r| -r.score }.map do |r|
        "<li>#{r.invader.name} at (#{r.x}, #{r.y}) &mdash; #{(r.score * 100).round(1)}%</li>"
      end
      "<h2>Detections</h2><ul>#{items.join}</ul>"
    end

    def build
      <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <title>Space Invaders Scan</title>
          <style>
            body  { background: #0f172a; color: #e2e8f0; font-family: monospace; padding: 2rem; }
            pre   { line-height: 1.4; }
            h2    { color: #94a3b8; margin-top: 2rem; }
            ul    { list-style: none; padding: 0; }
            li    { margin: 0.25rem 0; }
          </style>
        </head>
        <body>
          <h1>Radar Scan</h1>
          #{render_grid}
          #{render_legend}
          #{render_detections}
        </body>
        </html>
      HTML
    end
  end
end
