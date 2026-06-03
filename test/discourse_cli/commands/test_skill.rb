# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class TestSkillCommands < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @skill_source = File.join(@tmpdir, "gem", "skill", "dsc")
    FileUtils.mkdir_p(@skill_source)

    @claude_path = File.join(@tmpdir, "home", ".claude", "skills", "dsc")
    @codex_path  = File.join(@tmpdir, "home", ".codex",  "skills", "dsc")
    @gemini_path = File.join(@tmpdir, "home", ".gemini", "skills", "dsc")

    @fake_agent_paths = { claude: @claude_path, codex: @codex_path, gemini: @gemini_path }
    @fake_gem_dir = File.join(@tmpdir, "gem")
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def with_stubs(&block)
    DiscourseCli::Commands::Skill.stub(:skill_source, @skill_source) do
      DiscourseCli::Commands::Skill.stub(:agent_paths, @fake_agent_paths) { block.call }
    end
  end

  def test_install_creates_symlinks_for_all_agents
    with_stubs { dsc("skill", "install") }
    assert File.symlink?(@claude_path), "expected claude symlink"
    assert File.symlink?(@codex_path),  "expected codex symlink"
    assert File.symlink?(@gemini_path), "expected gemini symlink"
    assert_equal @skill_source, File.readlink(@claude_path)
  end

  def test_install_claude_only
    with_stubs { dsc("skill", "install", "--claude") }
    assert File.symlink?(@claude_path)
    refute File.exist?(@codex_path)
    refute File.exist?(@gemini_path)
  end

  def test_install_creates_parent_directory
    refute File.exist?(File.dirname(@claude_path))
    with_stubs { dsc("skill", "install", "--claude") }
    assert File.directory?(File.dirname(@claude_path))
  end

  def test_install_replaces_stale_symlink
    FileUtils.mkdir_p(File.dirname(@claude_path))
    File.symlink("/stale/path", @claude_path)
    with_stubs { dsc("skill", "install", "--claude") }
    assert_equal @skill_source, File.readlink(@claude_path)
  end

  def test_install_skips_when_already_correct
    with_stubs { dsc("skill", "install", "--claude") }
    result = with_stubs { dsc("skill", "install", "--claude") }
    assert_match "already installed", result[:out]
  end
end
