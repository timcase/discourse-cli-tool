# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "yaml"

class TestConfig < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @config_path = File.join(@tmpdir, "config.yml")
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
    ENV.delete("DISCOURSE_HOST")
    ENV.delete("DISCOURSE_API_KEY")
    ENV.delete("DISCOURSE_API_USERNAME")
    ENV.delete("DISCOURSE_SITE")
  end

  def with_config_path
    DiscourseCli::Config.stub(:config_path, @config_path) { yield }
  end

  def test_flags_take_precedence_over_env
    ENV["DISCOURSE_HOST"] = "http://env.example.com"
    config = DiscourseCli::Config.new(host: "http://flag.example.com")
    assert_equal "http://flag.example.com", config.host
  end

  def test_env_takes_precedence_over_file
    File.write(@config_path, YAML.dump({
      "default" => "mysite",
      "sites" => { "mysite" => { "host" => "http://file.example.com", "api_key" => "filekey", "api_username" => "fileuser" } }
    }))
    ENV["DISCOURSE_HOST"] = "http://env.example.com"
    config = nil
    with_config_path { config = DiscourseCli::Config.new }
    assert_equal "http://env.example.com", config.host
  end

  def test_reads_host_from_file
    File.write(@config_path, YAML.dump({
      "default" => "mysite",
      "sites" => { "mysite" => { "host" => "http://file.example.com", "api_key" => "k", "api_username" => "u" } }
    }))
    config = nil
    with_config_path { config = DiscourseCli::Config.new }
    assert_equal "http://file.example.com", config.host
  end

  def test_site_flag_selects_named_site
    File.write(@config_path, YAML.dump({
      "default" => "prod",
      "sites" => {
        "prod"    => { "host" => "http://prod.example.com",    "api_key" => "k1", "api_username" => "u1" },
        "staging" => { "host" => "http://staging.example.com", "api_key" => "k2", "api_username" => "u2" }
      }
    }))
    config = nil
    with_config_path { config = DiscourseCli::Config.new(site: "staging") }
    assert_equal "http://staging.example.com", config.host
  end

  def test_returns_nil_for_missing_keys_with_no_config
    config = nil
    with_config_path { config = DiscourseCli::Config.new }
    assert_nil config.host
    assert_nil config.api_key
    assert_nil config.api_username
  end

  def test_sites_returns_empty_hash_with_no_file
    config = nil
    with_config_path { config = DiscourseCli::Config.new }
    assert_equal({}, config.sites)
  end
end
