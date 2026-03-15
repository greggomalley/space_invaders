# frozen_string_literal: true

require_relative 'grid_parser'
require_relative 'result'
require_relative 'scan_result'

class Radar
  extend GridParser

  attr_reader :width, :height

  DEFAULT_THRESHOLD = 0.7

  def self.from_file(path, threshold: DEFAULT_THRESHOLD)
    new(parse_file(path), threshold:)
  end

  def self.from_string(text, threshold: DEFAULT_THRESHOLD)
    new(parse_text(text), threshold:)
  end

  def scan(threats)
    results = cluster(threats.flat_map { |threat| identify(threat) })
    ScanResult.new(@radar, results)
  end

  def initialize(radar, threshold: DEFAULT_THRESHOLD)
    @radar     = radar
    @width     = radar.shape[1]
    @height    = radar.shape[0]
    @threshold = threshold
  end

  def identify(threat)
    threat_height = threat.height
    threat_width = threat.width
    min_overlap = (threat_height * threat_width) / 2

    # The "World" coordinates (y) run from 0 to (Map Height + Threat Height - 2)
    # y = 0: Only the LAST row of the threat touches the FIRST row of the map.
    # y = Mid: The threat is fully inside the map.
    # y = Max: Only the FIRST row of the threat touches the LAST row of the map.

    results = []
    overall_height = height + 2 * threat_height - 2
    overall_width = width + 2 * threat_width - 2
    (0...overall_height).each do |y|
      (0...overall_width).each do |x|
        # -- Vertical Overlap --

        # Calculate which rows of the threat are currently "on screen"
        # Clip the start at 0 and the end at the threat's actual height.
        t_y_start = [0, (threat_height - 1) - y].max
        t_y_end   = [threat_height, (threat_height - 1) + (height - y)].min

        # Calculate the corresponding rows on the radar
        # When y is small, we hit the top of the map. When y is large, the bottom.
        r_y_start = [0, y - (threat_height - 1)].max
        r_y_end   = [height, y + 1].min

        # -- Horizontal Overlap --

        # Calculate which columns of the threat are "on screen"
        t_x_start = [0, (threat_width - 1) - x].max
        t_x_end   = [threat_width, (threat_width - 1) + (width - x)].min

        # Calculate the corresponding columns on the radar
        r_x_start = [0, x - (threat_width - 1)].max
        r_x_end   = [width, x + 1].min

        next if t_y_start >= t_y_end || t_x_start >= t_x_end
        next if r_y_start >= r_y_end || r_x_start >= r_x_end

        # Extract the visible part of the threat
        t_slice = threat[t_y_start...t_y_end, t_x_start...t_x_end]
        # Extract the part of the map it is currently overlapping
        r_slice = @radar[r_y_start...r_y_end, r_x_start...r_x_end]

        next if t_slice.empty?

        # Calculate Hamming Distance on the matching shapes
        distance = (t_slice ^ r_slice).count_true

        # Use a score so that we can determine the match probability
        score = 1.0 - (distance.to_f / t_slice.size)

        next unless score > @threshold && t_slice.size >= min_overlap

        results << Result.new(
          x: x - (threat_width  - 1),
          y: y - (threat_height - 1),
          score:,
          invader: threat
        )
      end
    end
    results
  end

  def cluster(results)
    remaining = results.sort_by { |r| -r.score }
    kept = []

    while remaining.any?
      best = remaining.shift
      kept << best
      remaining.reject! do |r|
        (r.x - best.x).abs < best.invader.width &&
          (r.y - best.y).abs < best.invader.height
      end
    end

    kept
  end
end
