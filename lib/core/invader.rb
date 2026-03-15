# frozen_string_literal: true

require_relative 'grid_parser'

class Invader
  extend GridParser

  attr_reader :name, :width, :height

  def self.from_file(path)
    name = File.basename(path, '.txt')
    dna  = parse_file(path)
    new(name, dna)
  end

  def self.from_string(name, text)
    dna = parse_text(text)
    new(name, dna)
  end

  def self.from_matrix(name, matrix)
    new(name, matrix)
  end

  def rotated(angle)
    raise ArgumentError, 'Angle must be 90/180/270' unless [90, 180, 270].include?(angle)

    self.class.from_matrix("#{@name}_rotated_#{angle}", @dna.rot90(angle / 90))
  end

  def [](*args)
    @dna[*args]
  end

  private

  def initialize(name, dna)
    @name   = name
    @dna    = dna
    @width  = dna.shape[1]
    @height = dna.shape[0]
  end
end
