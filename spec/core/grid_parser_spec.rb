# frozen_string_literal: true

require 'spec_helper'
require 'core/grid_parser'

RSpec.describe GridParser do
  let(:parser) { Class.new { extend GridParser }.itself }

  describe '#parse_text' do
    it 'raises when pattern is empty' do
      expect { parser.parse_text('') }.to raise_error(ArgumentError, /empty/)
    end

    it 'raises when rows have inconsistent widths' do
      expect { parser.parse_text("ooo\no\nooo") }.to raise_error(ArgumentError, /width/)
    end

    it 'raises when pattern contains invalid characters' do
      expect { parser.parse_text("oox\nooo") }.to raise_error(ArgumentError, /characters/)
    end

    it 'parses a valid pattern into a Numo::Bit matrix' do
      result = parser.parse_text("-o-\nooo\n-o-")
      expect(result).to be_a(Numo::Bit)
    end

    it 'sets the correct dimensions' do
      result = parser.parse_text("-o-\nooo\n-o-")
      expect(result.shape).to eq([3, 3])
    end

    it 'correctly maps o to 1 and - to 0' do
      result = parser.parse_text("-o-\n---")
      expect(result[0, 1]).to eq(1)
      expect(result[0, 0]).to eq(0)
    end
  end

  describe '#parse_file' do
    it 'raises when file is empty' do
      allow(File).to receive(:read).and_return('')
      expect { parser.parse_file('empty.txt') }.to raise_error(ArgumentError, /empty/)
    end

    it 'delegates to parse_text' do
      expect(parser).to receive(:parse_text).with("ooo\n---")
      allow(File).to receive(:read).and_return("ooo\n---")
      parser.parse_file('test.txt')
    end
  end
end
