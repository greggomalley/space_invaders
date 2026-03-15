# frozen_string_literal: true

require 'spec_helper'
require 'cli/args'

RSpec.describe Args do
  def parse(*argv)
    Args.parse(argv)
  end

  before do
    allow(File).to receive(:exist?).and_return(true)
  end

  describe 'defaults' do
    it 'defaults format to terminal' do
      expect(parse('radar.txt').formats).to eq(['terminal'])
    end

    it 'defaults threshold to 0.7' do
      expect(parse('radar.txt').threshold).to eq(0.8)
    end
  end

  describe '--format' do
    it 'parses a single format' do
      expect(parse('--format', 'html', 'radar.txt').formats).to eq(['html'])
    end

    it 'parses multiple comma-separated formats' do
      expect(parse('--format', 'terminal,html', 'radar.txt').formats).to eq(%w[terminal html])
    end

    it 'strips whitespace from formats' do
      expect(parse('--format', 'terminal, html', 'radar.txt').formats).to eq(%w[terminal html])
    end
  end

  describe '--threshold' do
    it 'parses a threshold value' do
      expect(parse('--threshold', '0.8', 'radar.txt').threshold).to eq(0.8)
    end

    it 'aborts when threshold is above 1' do
      expect { parse('--threshold', '1.5', 'radar.txt') }.to raise_error(SystemExit)
    end

    it 'aborts when threshold is below 0' do
      expect { parse('--threshold', '-0.1', 'radar.txt') }.to raise_error(SystemExit)
    end
  end

  describe 'radar_file' do
    it 'sets the radar file from the positional argument' do
      expect(parse('radar.txt').radar_file).to eq('radar.txt')
    end

    it 'aborts when no radar file is given' do
      expect { parse }.to raise_error(SystemExit)
    end

    it 'aborts when the file does not exist' do
      allow(File).to receive(:exist?).and_return(false)
      expect { parse('missing.txt') }.to raise_error(SystemExit)
    end
  end
end
