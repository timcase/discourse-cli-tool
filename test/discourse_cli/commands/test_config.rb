# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "yaml"

class TestConfigCommands < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @config_path = File.join(@tmpdir, "config.yml")
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def with_config_path
    DiscourseCli::Config.stub(:config_path, @config_path) do
      DiscourseCli::Commands::Config.stub(:config_path, @config_path) { yield }
    end
  end

  def test_config_set_writes_site_to_file
    result = with_config_path do
      dsc("config", "set",
          "--site", "mysite",
          "--host", "http://mysite.example.com",
          "--api-key", "abc123",
          "--api-username", "admin")
    end
    assert_equal 0, result[:status]
    data = YAML.safe_load(File.read(@config_path))
    assert_equal "http://mysite.example.com", data["sites"]["mysite"]["host"]
    assert_equal "abc123", data["sites"]["mysite"]["api_key"]
    assert_equal "admin", data["sites"]["mysite"]["api_username"]
  end

  def test_config_set_sets_default_on_first_site
    with_config_path do
      dsc("config", "set",
          "--site", "first",
          "--host", "http://first.example.com",
          "--api-key", "k",
          "--api-username", "u")
    end
    data = YAML.safe_load(File.read(@config_path))
    assert_equal "first", data["default"]
  end

  def test_config_list_shows_configured_sites
    File.write(@config_path, YAML.dump({
      "default" => "prod",
      "sites" => {
        "prod"    => { "host" => "http://prod.example.com",     "api_key" => "k1", "api_username" => "u1" },
        "staging" => { "host" => "http://staging.example.com",  "api_key" => "k2", "api_username" => "u2" }
      }
    }))
    result = with_config_path { dsc("config", "list") }
    assert_match "prod", result[:out]
    assert_match "staging", result[:out]
    assert_match "http://prod.example.com", result[:out]
  end
end
