# frozen_string_literal: true

require 'spec_helper'
require 'core/result'
require 'core/scan_result'
require 'numo/narray'

RSpec.describe ScanResult do
  let(:matrix) do
    Numo::Bit[
      [1, 0, 1],
      [0, 1, 0]
    ]
  end

  let(:results) { [Result.new(x: 0, y: 0, score: 0.9, invader: double('Invader'))] }

  subject(:scan_result) { ScanResult.new(matrix, results) }

  describe '#height' do
    it 'returns the number of rows' do
      expect(scan_result.height).to eq(2)
    end
  end

  describe '#width' do
    it 'returns the number of columns' do
      expect(scan_result.width).to eq(3)
    end
  end

  describe '#results' do
    it 'returns the detection results' do
      expect(scan_result.results).to eq(results)
    end
  end

  describe '#[]' do
    it 'returns o for a cell with value 1' do
      expect(scan_result[0, 0]).to eq('o')
    end

    it 'returns - for a cell with value 0' do
      expect(scan_result[0, 1]).to eq('-')
    end

    it 'works for all positions' do
      expect(scan_result[0, 2]).to eq('o')
      expect(scan_result[1, 0]).to eq('-')
      expect(scan_result[1, 1]).to eq('o')
      expect(scan_result[1, 2]).to eq('-')
    end
  end
end
