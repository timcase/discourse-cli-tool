# frozen_string_literal: true

require "fileutils"
require "yaml"

module DiscourseCli
  module Commands
    class Config < Base
      def self.config_path
        DiscourseCli::Config.config_path
      end

      desc "set", "Save connection details for a named site"
      option :site,           type: :string, required: true, desc: "Site name"
      option :host,           type: :string, required: true, desc: "Discourse host URL"
      option :"api-key",      type: :string, required: true, desc: "API key"
      option :"api-username", type: :string, required: true, desc: "API username"
      def set
        data = load_file
        data["sites"] ||= {}
        data["default"] ||= options[:site]
        data["sites"][options[:site]] = {
          "host"         => options[:host],
          "api_key"      => options[:"api-key"],
          "api_username" => options[:"api-username"],
        }
        FileUtils.mkdir_p(File.dirname(self.class.config_path))
        File.write(self.class.config_path, YAML.dump(data))
        puts "Saved config for site '#{options[:site]}'"
      end

      desc "list", "List configured sites"
      def list
        data = load_file
        sites = data["sites"] || {}
        default_site = data["default"]
        if sites.empty?
          puts "No sites configured. Run `dsc config set` to add one."
          return
        end
        sites.each do |name, cfg|
          marker = name == default_site ? " (default)" : ""
          puts "#{name}#{marker}"
          puts "  host:         #{cfg["host"]}"
          puts "  api_username: #{cfg["api_username"]}"
          puts
        end
      end

      private

      def load_file
        path = self.class.config_path
        File.exist?(path) ? YAML.safe_load(File.read(path)) || {} : {}
      end
    end
  end
end
