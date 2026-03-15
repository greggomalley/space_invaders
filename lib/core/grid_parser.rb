# frozen_string_literal: true

require 'numo/narray'

module GridParser
  def parse_file(path)
    parse_text(File.read(path))
  end

  def parse_text(text)
    binary_str = +''
    width = 0

    text.each_line do |line|
      line.strip!
      next if line.empty?

      width = line.length if width.zero?
      raise ArgumentError, 'Inconsistent row width' if line.length != width

      invalid_chars = line.scan(/[^Oo-]/).uniq.join(', ')
      raise ArgumentError, "Invalid characters in pattern: '#{invalid_chars}'" unless invalid_chars.empty?

      binary_str << line.tr('Oo-', '110')
    end

    raise ArgumentError, 'Pattern is empty' if binary_str.empty?

    Numo::Bit[*binary_str.chars.each_slice(width).map { |row| row.map(&:to_i) }]
  end
end
