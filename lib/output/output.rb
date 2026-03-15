# frozen_string_literal: true

module Output
  @registry = {}

  module Registerable
    def register
      Output.register(self)
    end
  end

  def self.const_added(name)
    klass = const_get(name)
    klass.extend(Registerable) if klass.is_a?(Class)
  end

  def self.register(klass)
    @registry[klass.name.split('::').last.downcase] = klass
  end

  def self.for(name)
    @registry.fetch(name) { abort "Error: unknown format '#{name}' (available: #{@registry.keys.join(', ')})" }
  end
end
