# frozen_string_literal: true

require "thor"

module DiscourseCli
  module Commands
    class Base < Thor
      class_option :site, type: :string, desc: "Named site from config file"
      class_option :host, type: :string, desc: "Discourse host URL"
      class_option :"api-key", type: :string, desc: "API key"
      class_option :"api-username", type: :string, desc: "API username"
      class_option :json, type: :boolean, default: false, desc: "Output JSON"
      class_option :quiet, type: :boolean, default: false, desc: "Suppress output, exit code only"

      def self.exit_on_failure?
        true
      end

      private

      def client
        @client ||= ClientFactory.build(config)
      end

      def config
        @config ||= DiscourseCli::Config.new(
          site: options[:site],
          host: options[:host],
          api_key: options[:"api-key"],
          api_username: options[:"api-username"],
        )
      end

      def formatter
        @formatter ||= Formatter.new(json: options[:json], quiet: options[:quiet])
      end

      def resolve_raw(given_raw)
        return given_raw if given_raw
        return $stdin.read unless $stdin.tty?
        Editor.new.open
      end

      def handle_error(error)
        message =
          case error
          when DiscourseApi::UnauthenticatedError
            "Authentication failed — check your api_key and api_username"
          when DiscourseApi::NotFoundError
            "Not found"
          when DiscourseApi::UnprocessableEntity
            errors = error.response&.dig(:body, "errors")
            errors ? Array(errors).join("\n") : error.message
          when DiscourseApi::TooManyRequests
            "Rate limited — try again shortly"
          when DiscourseApi::Timeout
            "Request timed out"
          else
            error.message
          end
        $stderr.puts message
        exit 1
      end
    end
  end
end
