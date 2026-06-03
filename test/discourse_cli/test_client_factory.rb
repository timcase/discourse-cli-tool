# frozen_string_literal: true

require "test_helper"

class TestClientFactory < Minitest::Test
  def test_raises_when_host_missing
    config = DiscourseCli::Config.new(api_key: "k", api_username: "u")
    err = assert_raises(RuntimeError) { DiscourseCli::ClientFactory.build(config) }
    assert_match "host", err.message
    assert_match "dsc config set", err.message
  end

  def test_raises_when_api_key_missing
    config = DiscourseCli::Config.new(host: "http://example.com", api_username: "u")
    err = assert_raises(RuntimeError) { DiscourseCli::ClientFactory.build(config) }
    assert_match "api_key", err.message
  end

  def test_raises_when_api_username_missing
    config = DiscourseCli::Config.new(host: "http://example.com", api_key: "k")
    err = assert_raises(RuntimeError) { DiscourseCli::ClientFactory.build(config) }
    assert_match "api_username", err.message
  end

  def test_returns_discourse_api_client_when_config_complete
    config = DiscourseCli::Config.new(host: "http://example.com", api_key: "k", api_username: "u")
    client = DiscourseCli::ClientFactory.build(config)
    assert_instance_of DiscourseApi::Client, client
    assert_equal "http://example.com", client.host
  end
end
