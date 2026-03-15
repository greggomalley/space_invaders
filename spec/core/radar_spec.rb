# frozen_string_literal: true

require 'spec_helper'
require 'core/radar'
require 'core/invader'

RSpec.describe Radar do
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

  let(:squid) do
    <<~TXT
      --o-----o--
      ---o---o---
      --ooooooo--
      -oo-ooo-oo-
      ooooooooooo
      o-ooooooo-o
      o-o-----o-o
      ---oo-oo---
    TXT
  end

  let(:crab_invader)  { Invader.from_string('crab', crab) }
  let(:squid_invader) { Invader.from_string('squid', squid) }

  describe 'perfect match' do
    it 'finds a perfect match when radar contains only the crab' do
      radar   = Radar.from_string(crab)
      results = radar.scan([crab_invader]).results
      match = results.find { |r| r.score == 1.0 }
      expect(match).not_to be_nil
      expect(match.x).to eq(0)
      expect(match.y).to eq(0)
    end

    it 'finds a perfect match when radar contains only the squid' do
      radar   = Radar.from_string(squid)
      results = radar.scan([squid_invader]).results
      match = results.find { |r| r.score == 1.0 }
      expect(match).not_to be_nil
      expect(match.x).to eq(0)
      expect(match.y).to eq(0)
    end

    it 'finds a perfect match when invader is embedded in a larger radar' do
      radar_pattern = <<~TXT
        ----------------
        ----------------
        ------o--o------
        -----oooooo-----
        ----oo-oo-oo----
        ----oooooooo----
        ------o--o------
        -----o----o-----
        ----------------
        ----------------
      TXT
      radar   = Radar.from_string(radar_pattern)
      results = radar.scan([crab_invader]).results
      match = results.find { |r| r.score == 1.0 }
      expect(match).not_to be_nil
      expect(match.x).to eq(4)
      expect(match.y).to eq(2)
    end
  end

  describe 'noisy matches' do
    it 'finds a high score match when one cell is flipped' do
      noisy = <<~TXT
        --o--o--
        -oooooo-
        oo-oo-oo
        oooooooo
        --o--o--
        -o---oo-
      TXT
      radar   = Radar.from_string(noisy)
      results = radar.scan([crab_invader]).results
      expect(results.any? { |r| r.score >= 0.8 }).to be true
    end

    it 'finds a match when radar has false positives' do
      noisy = <<~TXT
        --o--o--
        -ooooooo
        oo-oo-oo
        oooooooo
        --o--o--
        -o----o-
      TXT
      radar   = Radar.from_string(noisy)
      results = radar.scan([crab_invader]).results
      expect(results.any? { |r| r.score >= 0.8 }).to be true
    end

    it 'finds a match when radar has false negatives' do
      noisy = <<~TXT
        --o--o--
        -oooooo-
        oo-oo-o-
        oooooooo
        --o--o--
        -o----o-
      TXT
      radar   = Radar.from_string(noisy)
      results = radar.scan([crab_invader]).results
      expect(results.any? { |r| r.score >= 0.8 }).to be true
    end
  end

  describe 'edge cases' do
    it 'finds a match when invader is at the top left corner' do
      radar_pattern = <<~TXT
        --o--o----------
        -oooooo---------
        oo-oo-oo--------
        oooooooo--------
        --o--o----------
        -o----o---------
        ----------------
        ----------------
      TXT
      radar   = Radar.from_string(radar_pattern)
      results = radar.scan([crab_invader]).results
      match = results.find { |r| r.score == 1.0 }
      expect(match).not_to be_nil
      expect(match.x).to eq(0)
      expect(match.y).to eq(0)
    end

    it 'finds a match when invader is at the bottom right corner' do
      radar_pattern = <<~TXT
        ----------------
        ----------------
        --------o--o----
        --------oooooo--
        -------oo-oo-oo-
        -------ooooooooo
        ---------o--o---
        --------o----o--
      TXT
      radar   = Radar.from_string(radar_pattern)
      results = radar.scan([crab_invader]).results
      expect(results.any? { |r| r.score >= 0.8 }).to be true
    end

    it 'finds a partial match when invader is half off the top edge' do
      radar_pattern = <<~TXT
        oo-oo-oo--------
        oooooooo--------
        --o--o----------
        -o----o---------
      TXT
      radar   = Radar.from_string(radar_pattern)
      results = radar.scan([crab_invader]).results
      expect(results.any? { |r| r.score >= 0.8 }).to be true
    end

    it 'finds a partial match when invader is half off the left edge' do
      radar_pattern = <<~TXT
        o---------------
        ooo-------------
        ooo-oo----------
        oooooooo--------
        o--o------------
        ----o-----------
      TXT
      radar   = Radar.from_string(radar_pattern)
      results = radar.scan([crab_invader]).results
      expect(results.any? { |r| r.score >= 0.8 }).to be true
    end
  end

  describe 'multiple invaders' do
    it 'finds two different invaders in the same radar' do
      radar_pattern = <<~TXT
        --o--o-----------------------------
        -oooooo----------------------------
        oo-oo-oo---------------------------
        oooooooo---------------------------
        --o--o-----------------------------
        -o----o----------------------------
        -----------------------------------
        -----------------------------------
        -----------o-----o-----------------
        ------------o---o------------------
        -----------ooooooo-----------------
        ----------oo-ooo-oo----------------
        ----------ooooooooo----------------
        ----------o-ooooooo-o--------------
        ----------o-o-----o-o--------------
        ------------oo-oo------------------
      TXT
      radar   = Radar.from_string(radar_pattern)
      results = radar.scan([crab_invader, squid_invader]).results
      crab_match  = results.find { |r| r.invader == crab_invader  && r.score == 1.0 }
      squid_match = results.find { |r| r.invader == squid_invader && r.score >= 0.8 }
      expect(crab_match).not_to be_nil
      expect(crab_match.x).to eq(0)
      expect(crab_match.y).to eq(0)
      expect(squid_match).not_to be_nil
      expect(squid_match.x).to eq(9)
      expect(squid_match.y).to eq(8)
    end

    it 'finds two crabs in the same radar' do
      radar_pattern = <<~TXT
        --o--o--------------------o--o--
        -oooooo------------------oooooo-
        oo-oo-oo----------------oo-oo-oo
        oooooooo----------------oooooooo
        --o--o--------------------o--o--
        -o----o------------------o----o-
      TXT
      radar   = Radar.from_string(radar_pattern)
      results = radar.scan([crab_invader]).results
      perfect = results.select { |r| r.score == 1.0 }
      expect(perfect.length).to be >= 2
      positions = perfect.map { |r| [r.x, r.y] }
      expect(positions).to include([0, 0])
      expect(positions).to include([24, 0])
    end
  end

  describe 'clustering' do
    it 'collapses overlapping candidates into a single result' do
      radar   = Radar.from_string(crab)
      results = radar.scan([crab_invader]).results
      expect(results.length).to eq(1)
    end

    it 'keeps the highest-scoring candidate when results overlap' do
      noisy = <<~TXT
        --o--o--
        -oooooo-
        oo-oo-oo
        oooooooo
        --o--o--
        -o---oo-
      TXT
      radar   = Radar.from_string(noisy)
      results = radar.scan([crab_invader]).results
      expect(results.length).to eq(1)
      expect(results.first.x).to eq(0)
      expect(results.first.y).to eq(0)
    end

    # Constructing a radar that scores both types above threshold at overlapping
    # positions isn't practical in the timeframe, so we test cluster directly
    # with synthetic results.
    it 'eliminates a lower-scoring result of a different invader type when positions overlap' do
      radar        = Radar.from_string(crab)
      crab_result  = Result.new(x: 0, y: 0, score: 1.0,  invader: crab_invader)
      squid_result = Result.new(x: 2, y: 1, score: 0.85, invader: squid_invader)
      clustered    = radar.cluster([crab_result, squid_result])
      expect(clustered.length).to eq(1)
      expect(clustered.first.invader).to eq(crab_invader)
    end
  end
end
