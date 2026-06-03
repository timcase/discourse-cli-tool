# frozen_string_literal: true

require "test_helper"

class TestCategoriesCommands < Minitest::Test
  CATEGORIES_JSON = {
    category_list: {
      categories: [
        { id: 1, name: "General", slug: "general" },
        { id: 2, name: "Meta", slug: "meta" }
      ]
    }
  }.freeze

  CATEGORY_JSON = { category: { id: 1, name: "General", slug: "general", color: "0088CC" } }.freeze

  def test_categories_list
    stub_get("/categories.json").to_return(json_response(CATEGORIES_JSON))
    result = dsc("categories", "list", *CONN_FLAGS)
    assert_equal 0, result[:status]
    assert_match "General", result[:out]
    assert_match "Meta", result[:out]
  end

  def test_categories_list_json
    stub_get("/categories.json").to_return(json_response(CATEGORIES_JSON))
    result = dsc("categories", "list", "--json", *CONN_FLAGS)
    parsed = JSON.parse(result[:out])
    assert_equal 1, parsed.first["id"]
  end

  def test_categories_show
    stub_get("/c/1/show").to_return(json_response(CATEGORY_JSON))
    result = dsc("categories", "show", "1", *CONN_FLAGS)
    assert_equal 0, result[:status]
    assert_match "General", result[:out]
  end

  def test_categories_create
    stub_post("/categories").to_return(json_response({ category: { id: 3, name: "New Cat", slug: "new-cat" } }))
    result = dsc("categories", "create", "--name", "New Cat", *CONN_FLAGS)
    assert_equal 0, result[:status]
    assert_match "New Cat", result[:out]
  end

  def test_categories_update
    stub_put("/categories/1").to_return(json_response({ category: { id: 1, name: "Updated", slug: "updated" } }))
    result = dsc("categories", "update", "1", "--name", "Updated", *CONN_FLAGS)
    assert_equal 0, result[:status]
  end

  def test_categories_delete
    stub_delete("/categories/1").to_return(json_response({ success: "OK" }))
    result = dsc("categories", "delete", "1", *CONN_FLAGS)
    assert_equal 0, result[:status]
    assert_match "Deleted", result[:out]
  end

  def test_categories_list_unauthenticated_error
    stub_get("/categories.json").to_return(status: 403, body: "Forbidden", headers: {})
    result = dsc("categories", "list", *CONN_FLAGS)
    assert_equal 1, result[:status]
    assert_match "Authentication failed", result[:err]
  end

  def test_categories_show_not_found
    stub_get("/c/999/show").to_return(status: 404, body: "{}", headers: { "Content-Type" => "application/json" })
    result = dsc("categories", "show", "999", *CONN_FLAGS)
    assert_equal 1, result[:status]
    assert_match "Not found", result[:err]
  end
end
