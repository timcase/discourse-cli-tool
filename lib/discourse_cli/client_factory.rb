# frozen_string_literal: true

require "discourse_api"

module DiscourseCli
  class ClientFactory
    def self.build(config)
      missing = []
      missing << "host" unless config.host
      missing << "api_key" unless config.api_key
      missing << "api_username" unless config.api_username

      if missing.any?
        raise "Missing required config: #{missing.join(", ")}. " \
              "Run `dsc config set` or set #{missing.map { |k| "DISCOURSE_#{k.upcase}" }.join(", ")}."
      end

      DiscourseApi::Client.new(config.host, config.api_key, config.api_username)
    end
  end
end
