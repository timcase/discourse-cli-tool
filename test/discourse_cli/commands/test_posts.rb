# frozen_string_literal: true

require "test_helper"

class TestPostsCommands < Minitest::Test
  POSTS_JSON = {
    latest_posts: [
      { id: 500, topic_id: 100, raw: "first post content" },
      { id: 501, topic_id: 100, raw: "second post content" }
    ]
  }.freeze

  POST_JSON = { id: 500, topic_id: 100, raw: "first post content", cooked: "<p>first post content</p>" }.freeze

  def test_posts_list
    stub_request(:get, "#{HOST}/posts.json")
      .with(headers: { "Api-Key" => API_KEY, "Api-Username" => API_USERNAME },
            query: hash_including("before" => "0"))
      .to_return(json_response(POSTS_JSON))
    result = dsc("posts", "list", *CONN_FLAGS)
    assert_equal 0, result[:status]
    assert_match "500", result[:out]
  end

  def test_posts_show
    stub_get("/posts/500.json").to_return(json_response(POST_JSON))
    result = dsc("posts", "show", "500", *CONN_FLAGS)
    assert_equal 0, result[:status]
    assert_match "first post content", result[:out]
  end

  def test_posts_create_with_raw_flag
    stub_post("/posts").to_return(json_response({ id: 502, topic_id: 100, raw: "new reply" }))
    result = dsc("posts", "create",
                 "--topic-id", "100",
                 "--raw", "new reply",
                 *CONN_FLAGS)
    assert_equal 0, result[:status]
  end

  def test_posts_create_reads_from_stdin
    stub_post("/posts").to_return(json_response({ id: 503, topic_id: 100, raw: "stdin reply" }))
    original_stdin = $stdin
    $stdin = StringIO.new("stdin reply")
    result = dsc("posts", "create", "--topic-id", "100", *CONN_FLAGS)
    assert_equal 0, result[:status]
  ensure
    $stdin = original_stdin
  end

  def test_posts_update_with_raw_flag
    stub_put("/posts/500").to_return(json_response({ id: 500, raw: "updated content" }))
    result = dsc("posts", "update", "500", "--raw", "updated content", *CONN_FLAGS)
    assert_equal 0, result[:status]
  end

  def test_posts_delete
    stub_delete("/posts/500.json").to_return(json_response({}))
    result = dsc("posts", "delete", "500", *CONN_FLAGS)
    assert_equal 0, result[:status]
    assert_match "Deleted", result[:out]
  end

  def test_posts_show_json
    stub_get("/posts/500.json").to_return(json_response(POST_JSON))
    result = dsc("posts", "show", "500", "--json", *CONN_FLAGS)
    parsed = JSON.parse(result[:out])
    assert_equal 500, parsed["id"]
  end

  def test_posts_create_unprocessable_entity
    stub_post("/posts").to_return(
      status: 422,
      body: { errors: ["Raw can't be blank"] }.to_json,
      headers: { "Content-Type" => "application/json" }
    )
    result = dsc("posts", "create", "--topic-id", "100", "--raw", "", *CONN_FLAGS)
    assert_equal 1, result[:status]
    assert_match "Raw can't be blank", result[:err]
  end
end
