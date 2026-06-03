# frozen_string_literal: true

require "tempfile"
require "shellwords"

module DiscourseCli
  class Editor
    def initialize(spawn: nil)
      @spawn = spawn || method(:default_spawn)
    end

    def open(initial_content = "")
      Tempfile.create(["dsc", ".md"]) do |f|
        f.write(initial_content)
        f.flush
        @spawn.call(f.path)
        f.rewind
        f.read
      end
    end

    private

    def default_spawn(path)
      editor = ENV.fetch("EDITOR", "vi")
      system("#{editor} #{Shellwords.escape(path)}")
    end
  end
end
