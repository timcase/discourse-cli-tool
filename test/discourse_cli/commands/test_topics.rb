# frozen_string_literal: true

require "test_helper"

class TestTopicsCommands < Minitest::Test
  TOPIC_LIST_JSON = {
    topic_list: {
      topics: [
        { id: 100, title: "Hello World" },
        { id: 101, title: "Another Topic" }
      ]
    }
  }.freeze

  TOPIC_JSON = {
    id: 100,
    title: "Hello World",
    post_stream: { posts: [{ id: 500, raw: "original content" }] }
  }.freeze

  def test_topics_list
    stub_get("/latest.json").to_return(json_response(TOPIC_LIST_JSON))
    result = dsc("topics", "list", *CONN_FLAGS)
    assert_equal 0, result[:status]
    assert_match "Hello World", result[:out]
  end

  def test_topics_show
    stub_get("/t/100.json").to_return(json_response(TOPIC_JSON))
    result = dsc("topics", "show", "100", *CONN_FLAGS)
    assert_equal 0, result[:status]
    assert_match "Hello World", result[:out]
  end

  def test_topics_create_with_raw_flag
    stub_post("/posts").to_return(json_response({ id: 200, title: "New Topic", topic_id: 200 }))
    result = dsc("topics", "create",
                 "--title", "New Topic",
                 "--raw", "Some content",
                 *CONN_FLAGS)
    assert_equal 0, result[:status]
  end

  def test_topics_create_reads_from_stdin
    stub_post("/posts").to_return(json_response({ id: 201, title: "Stdin Topic", topic_id: 201 }))
    original_stdin = $stdin
    $stdin = StringIO.new("content from stdin")
    result = dsc("topics", "create", "--title", "Stdin Topic", *CONN_FLAGS)
    assert_equal 0, result[:status]
  ensure
    $stdin = original_stdin
  end

  def test_topics_update_renames_when_title_given
    stub_put("/t/100.json").to_return(json_response({ basic_topic: { id: 100, title: "New Title" } }))
    result = dsc("topics", "update", "100", "--title", "New Title", *CONN_FLAGS)
    assert_equal 0, result[:status]
  end

  def test_topics_update_edits_post_when_raw_given
    stub_get("/t/100.json").to_return(json_response(TOPIC_JSON))
    stub_put("/posts/500").to_return(json_response({ id: 500, raw: "new content" }))
    result = dsc("topics", "update", "100", "--raw", "new content", *CONN_FLAGS)
    assert_equal 0, result[:status]
  end

  def test_topics_delete
    stub_delete("/t/100.json").to_return(json_response({}))
    result = dsc("topics", "delete", "100", *CONN_FLAGS)
    assert_equal 0, result[:status]
    assert_match "Deleted", result[:out]
  end

  def test_topics_list_json
    stub_get("/latest.json").to_return(json_response(TOPIC_LIST_JSON))
    result = dsc("topics", "list", "--json", *CONN_FLAGS)
    parsed = JSON.parse(result[:out])
    assert_equal 100, parsed.first["id"]
  end
end
