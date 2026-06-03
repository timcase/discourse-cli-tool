# frozen_string_literal: true

require "minitest/autorun"
require "webmock/minitest"
require "discourse_cli"

WebMock.disable_net_connect!

HOST = "http://test.example.com"
API_KEY = "testkey"
API_USERNAME = "testuser"

# Shared flags for commands that need a live client
CONN_FLAGS = ["--host", HOST, "--api-key", API_KEY, "--api-username", API_USERNAME].freeze

def stub_get(path)
  stub_request(:get, "#{HOST}#{path}")
    .with(headers: { "Api-Key" => API_KEY, "Api-Username" => API_USERNAME })
end

def stub_post(path)
  stub_request(:post, "#{HOST}#{path}")
    .with(headers: { "Api-Key" => API_KEY, "Api-Username" => API_USERNAME })
end

def stub_put(path)
  stub_request(:put, "#{HOST}#{path}")
    .with(headers: { "Api-Key" => API_KEY, "Api-Username" => API_USERNAME })
end

def stub_delete(path)
  stub_request(:delete, "#{HOST}#{path}")
    .with(headers: { "Api-Key" => API_KEY, "Api-Username" => API_USERNAME })
end

def json_response(body, status: 200)
  { status: status, body: body.to_json, headers: { "Content-Type" => "application/json" } }
end

# Run a dsc command, return { out:, err:, status: }
def dsc(*args)
  status = 0
  out, err = capture_io do
    DiscourseCli::CLI.start(args)
  rescue SystemExit => e
    status = e.status
  end
  { out: out, err: err, status: status }
end
