# frozen_string_literal: true

require_relative 'invader'

class InvaderStore
  def self.build(invaders_config: 'config/invaders')
    Dir.glob("#{invaders_config}/*.txt").map do |file|
      Invader.from_file(file)
    end
  end
end
