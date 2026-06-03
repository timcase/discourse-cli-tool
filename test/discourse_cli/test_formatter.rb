# frozen_string_literal: true

require "test_helper"
require "json"
require "stringio"

class TestFormatter < Minitest::Test
  def formatter(json: false, quiet: false)
    @out = StringIO.new
    DiscourseCli::Formatter.new(output: @out, json: json, quiet: quiet)
  end

  def output
    @out.string
  end

  def test_print_list_human_shows_id_and_label
    formatter.print_list([{ "id" => 1, "name" => "General" }, { "id" => 2, "name" => "Meta" }])
    assert_match "1", output
    assert_match "General", output
    assert_match "2", output
    assert_match "Meta", output
  end

  def test_print_list_json_outputs_json_array
    formatter(json: true).print_list([{ "id" => 1, "name" => "General" }])
    parsed = JSON.parse(output)
    assert_equal 1, parsed.first["id"]
  end

  def test_print_list_quiet_outputs_nothing
    formatter(quiet: true).print_list([{ "id" => 1, "name" => "General" }])
    assert_empty output
  end

  def test_print_item_human_shows_key_value_pairs
    formatter.print_item({ "id" => 1, "name" => "General", "slug" => "general" })
    assert_match "id: 1", output
    assert_match "name: General", output
  end

  def test_print_item_json_outputs_json_object
    formatter(json: true).print_item({ "id" => 1, "name" => "General" })
    parsed = JSON.parse(output)
    assert_equal 1, parsed["id"]
  end

  def test_print_success_human_prints_message
    formatter.print_success("Deleted successfully")
    assert_match "Deleted successfully", output
  end

  def test_print_success_json_suppresses_message
    formatter(json: true).print_success("Deleted successfully")
    assert_empty output
  end

  def test_print_success_quiet_suppresses_message
    formatter(quiet: true).print_success("Deleted successfully")
    assert_empty output
  end
end
