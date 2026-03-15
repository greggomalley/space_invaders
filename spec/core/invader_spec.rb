# frozen_string_literal: true

require 'spec_helper'
require 'core/invader'

RSpec.describe Invader do
  let(:crab) do
    <<~TXT
      --o--o--
      -oooooo-
      oo-oo-oo
      oooooooo
      --o--o--
      -o----o-
    TXT
  end

  describe '.from_string' do
    subject(:invader) { Invader.from_string('crab', crab) }

    it 'creates an invader with the correct name' do
      expect(invader.name).to eq('crab')
    end

    it 'sets the correct width' do
      expect(invader.width).to eq(8)
    end

    it 'sets the correct height' do
      expect(invader.height).to eq(6)
    end

    it 'ignores leading and trailing blank lines' do
      invader = Invader.from_string('crab', "\n#{crab}\n")
      expect(invader.height).to eq(6)
    end
  end

  describe '.from_file' do
    subject(:invader) { Invader.from_file('spec/fixtures/crab.txt') }

    it 'derives the name from the filename without extension' do
      expect(invader.name).to eq('crab')
    end

    it 'creates a valid invader from the file' do
      expect(invader.width).to be > 0
      expect(invader.height).to be > 0
    end
  end

  describe '#rotated' do
    subject(:invader) { Invader.from_string('crab', crab) }

    it 'raises an error for invalid angles' do
      expect { invader.rotated(45) }.to raise_error(ArgumentError)
    end

    it 'raises an error for 0 degrees' do
      expect { invader.rotated(0) }.to raise_error(ArgumentError)
    end

    it 'returns an Invader instance' do
      expect(invader.rotated(90)).to be_an(Invader)
    end

    it 'swaps width and height on 90 degree rotation' do
      rotated = invader.rotated(90)
      expect(rotated.width).to eq(invader.height)
      expect(rotated.height).to eq(invader.width)
    end

    it 'preserves dimensions on 180 degree rotation' do
      rotated = invader.rotated(180)
      expect(rotated.width).to eq(invader.width)
      expect(rotated.height).to eq(invader.height)
    end

    it 'top-left corner moves to top-right after 90 degree rotation' do
      expect(invader[0, 0]).to eq(0)
      rotated = invader.rotated(90)
      expect(rotated[0, rotated.width - 1]).to eq(0)
    end

    it 'four 90 degree rotations equals the original' do
      rotated = invader.rotated(90).rotated(90).rotated(90).rotated(90)
      expect(rotated[true, true]).to eq(invader[true, true])
    end
  end

  describe '#[]' do
    subject(:invader) { Invader.from_string('crab', crab) }

    it 'allows slicing a region of the pattern' do
      slice = invader[0...2, 0...2]
      expect(slice.shape).to eq([2, 2])
    end

    it 'returns 0 for a known empty cell' do
      expect(invader[0, 0]).to eq(0)
    end

    it 'returns 1 for a known filled cell' do
      expect(invader[0, 2]).to eq(1)
    end
  end
end
