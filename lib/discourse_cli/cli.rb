# frozen_string_literal: true

require "thor"

module DiscourseCli
  class CLI < Thor
    def self.exit_on_failure?
      true
    end

    register(Commands::Config,     "config",     "config <command>",     "Manage site configuration")
    register(Commands::Categories, "categories", "categories <command>", "Manage categories")
    register(Commands::Topics,     "topics",     "topics <command>",     "Manage topics")
    register(Commands::Posts,      "posts",      "posts <command>",      "Manage posts")
    register(Commands::Skill,      "skill",      "skill <command>",      "Manage the dsc LLM skill")
  end
end
