# frozen_string_literal: true

require "test_helper"
require "tmpdir"

class TestClientFactory < Minitest::Test
  def setup
    @tmpdir = Dir.mktmpdir
    @empty_config = File.join(@tmpdir, "config.yml")
  end

  def teardown
    FileUtils.remove_entry(@tmpdir)
  end

  def with_no_config(&block)
    DiscourseCli::Config.stub(:config_path, @empty_config) { block.call }
  end

  def test_raises_when_host_missing
    with_no_config do
      config = DiscourseCli::Config.new(api_key: "k", api_username: "u")
      err = assert_raises(RuntimeError) { DiscourseCli::ClientFactory.build(config) }
      assert_match "host", err.message
      assert_match "dsc config set", err.message
    end
  end

  def test_raises_when_api_key_missing
    with_no_config do
      config = DiscourseCli::Config.new(host: "http://example.com", api_username: "u")
      err = assert_raises(RuntimeError) { DiscourseCli::ClientFactory.build(config) }
      assert_match "api_key", err.message
    end
  end

  def test_raises_when_api_username_missing
    with_no_config do
      config = DiscourseCli::Config.new(host: "http://example.com", api_key: "k")
      err = assert_raises(RuntimeError) { DiscourseCli::ClientFactory.build(config) }
      assert_match "api_username", err.message
    end
  end

  def test_returns_discourse_api_client_when_config_complete
    config = DiscourseCli::Config.new(host: "http://example.com", api_key: "k", api_username: "u")
    client = DiscourseCli::ClientFactory.build(config)
    assert_instance_of DiscourseApi::Client, client
    assert_equal "http://example.com", client.host
  end
end
