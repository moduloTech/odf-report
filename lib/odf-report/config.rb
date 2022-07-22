# frozen_string_literal: true

module ODFReport

  class << self

    def configure
      yield config
    end

    def config
      @config ||= Config.new
    end

  end

  class Config

    DEFAULTS = {
      patterns_regex:  /\[(.*)\]/,
      field_delimiters:       %w([ ]).freeze,
      field_delimiters_as_is: false
    }.freeze

    attr_accessor *DEFAULTS.keys

    def initialize
      DEFAULTS.each do |key, value|
        public_send("#{key}=", value)
      end
    end

  end

end
