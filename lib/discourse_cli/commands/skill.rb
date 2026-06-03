# frozen_string_literal: true

require "fileutils"

module DiscourseCli
  module Commands
    class Skill < Base
      def self.agent_paths
        {
          claude: File.expand_path("~/.claude/skills/dsc"),
          codex:  File.expand_path("~/.codex/skills/dsc"),
          gemini: File.expand_path("~/.gemini/skills/dsc"),
        }
      end

      desc "install", "Install the dsc skill for LLM coding agents"
      option :claude, type: :boolean, default: false, desc: "Install for Claude Code"
      option :codex,  type: :boolean, default: false, desc: "Install for Codex"
      option :gemini, type: :boolean, default: false, desc: "Install for Gemini CLI"
      def install
        targets = selected_agents
        skill_source = self.class.skill_source

        unless File.exist?(skill_source)
          $stderr.puts "Skill source not found at #{skill_source}"
          exit 1
        end

        targets.each do |agent, path|
          FileUtils.mkdir_p(File.dirname(path))

          if File.symlink?(path) && File.readlink(path) == skill_source
            puts "#{agent}: already installed"
            next
          end

          File.unlink(path) if File.symlink?(path) || File.exist?(path)
          File.symlink(skill_source, path)
          puts "#{agent}: installed → #{path}"
        end
      end

      def self.skill_source
        spec = Gem::Specification.find_by_name("discourse_cli_tool")
        File.join(spec.gem_dir, "skill", "dsc")
      rescue Gem::MissingSpecError
        File.expand_path("../../../skill/dsc", __dir__)
      end

      private

      def selected_agents
        paths = self.class.agent_paths
        any_selected = options[:claude] || options[:codex] || options[:gemini]
        agents = any_selected ? {} : paths.dup
        agents[:claude] = paths[:claude] if options[:claude]
        agents[:codex]  = paths[:codex]  if options[:codex]
        agents[:gemini] = paths[:gemini] if options[:gemini]
        agents
      end
    end
  end
end
