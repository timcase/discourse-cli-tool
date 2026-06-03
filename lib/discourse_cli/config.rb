# frozen_string_literal: true

require "yaml"

module DiscourseCli
  class Config
    def self.config_path
      File.expand_path("~/.config/dsc/config.yml")
    end

    def initialize(overrides = {})
      @overrides = overrides
      @config_path_snapshot = self.class.config_path
    end

    def host
      @overrides[:host] || ENV["DISCOURSE_HOST"] || site_config["host"]
    end

    def api_key
      @overrides[:api_key] || ENV["DISCOURSE_API_KEY"] || site_config["api_key"]
    end

    def api_username
      @overrides[:api_username] || ENV["DISCOURSE_API_USERNAME"] || site_config["api_username"]
    end

    def sites
      file_config["sites"] || {}
    end

    def default_site
      file_config["default"]
    end

    private

    def site_name
      @overrides[:site] || ENV["DISCOURSE_SITE"] || file_config["default"]
    end

    def site_config
      return {} unless site_name
      (file_config["sites"] || {})[site_name] || {}
    end

    def file_config
      @file_config ||=
        if File.exist?(@config_path_snapshot)
          YAML.safe_load(File.read(@config_path_snapshot)) || {}
        else
          {}
        end
    end
  end
end
