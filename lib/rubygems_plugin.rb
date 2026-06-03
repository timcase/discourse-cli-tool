# frozen_string_literal: true

def dsc_skill_agent_paths
  %w[
    ~/.claude/skills/dsc
    ~/.codex/skills/dsc
    ~/.gemini/skills/dsc
  ].map { |p| File.expand_path(p) }
end

Gem.post_install do |installer|
  next unless installer.spec.name == "discourse_cli_tool"

  skill_source = File.join(installer.spec.gem_dir, "skill", "dsc")
  next unless File.exist?(skill_source)

  dsc_skill_agent_paths.each do |path|
    next unless File.symlink?(path)

    File.unlink(path)
    File.symlink(skill_source, path)
  end
end

Gem.pre_uninstall do |uninstaller|
  next unless uninstaller.spec.name == "discourse_cli_tool"

  skill_source = File.join(uninstaller.spec.gem_dir, "skill", "dsc")

  dsc_skill_agent_paths.each do |path|
    next unless File.symlink?(path) && File.readlink(path) == skill_source

    File.unlink(path)
    puts "Removed dsc skill from #{path}"
  end
end
