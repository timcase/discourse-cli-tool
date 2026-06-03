# frozen_string_literal: true

require "json"

module DiscourseCli
  class Formatter
    def initialize(output: $stdout, json: false, quiet: false)
      @output = output
      @json = json
      @quiet = quiet
    end

    def print_list(items)
      return if @quiet
      if @json
        @output.puts JSON.pretty_generate(items)
      else
        items.each { |item| @output.puts format_row(item) }
      end
    end

    def print_item(item)
      return if @quiet
      if @json
        @output.puts JSON.pretty_generate(item)
      else
        item.each { |k, v| @output.puts "#{k}: #{v}" }
      end
    end

    def print_success(message)
      return if @quiet || @json
      @output.puts message
    end

    private

    def format_row(item)
      id = item["id"] || item[:id]
      label = item["title"] || item["name"] || item["slug"] || item.values.compact.first
      "#{id}\t#{label}"
    end
  end
end
