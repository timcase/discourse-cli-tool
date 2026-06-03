# frozen_string_literal: true

require "test_helper"

class TestEditor < Minitest::Test
  def test_returns_content_written_by_spawn_proc
    spawn_calls = []
    spawn_proc = ->(path) { File.write(path, "hello from editor"); spawn_calls << path }
    editor = DiscourseCli::Editor.new(spawn: spawn_proc)
    result = editor.open
    assert_equal "hello from editor", result
    assert_equal 1, spawn_calls.size
  end

  def test_initial_content_is_written_to_temp_file
    written = nil
    spawn_proc = ->(path) { written = File.read(path) }
    editor = DiscourseCli::Editor.new(spawn: spawn_proc)
    editor.open("# initial content")
    assert_equal "# initial content", written
  end

  def test_returns_empty_string_when_nothing_written
    editor = DiscourseCli::Editor.new(spawn: ->(_path) {})
    result = editor.open
    assert_equal "", result
  end
end
