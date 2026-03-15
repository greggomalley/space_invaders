# frozen_string_literal: true

class ScanResult
  attr_reader :height, :width, :results

  def initialize(matrix, results)
    @matrix  = matrix
    @height  = matrix.shape[0]
    @width   = matrix.shape[1]
    @results = results
  end

  def [](row, col)
    @matrix[row, col] == 1 ? 'o' : '-'
  end
end
