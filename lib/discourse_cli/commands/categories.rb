# frozen_string_literal: true

module DiscourseCli
  module Commands
    class Categories < Base
      desc "list", "List all categories"
      def list
        formatter.print_list(client.categories)
      rescue DiscourseApi::DiscourseError => e
        handle_error(e)
      end

      desc "show ID", "Show a category"
      def show(id)
        formatter.print_item(client.category(id.to_i))
      rescue DiscourseApi::DiscourseError => e
        handle_error(e)
      end

      desc "create", "Create a category"
      option :name,         type: :string, required: true
      option :color,        type: :string
      option :"text-color", type: :string
      option :description,  type: :string
      def create
        params = { name: options[:name] }
        params[:color]       = options[:color]          if options[:color]
        params[:text_color]  = options[:"text-color"]   if options[:"text-color"]
        params[:description] = options[:description]    if options[:description]
        formatter.print_item(client.create_category(params))
      rescue DiscourseApi::DiscourseError => e
        handle_error(e)
      end

      desc "update ID", "Update a category"
      option :name,         type: :string, required: true
      option :color,        type: :string
      option :"text-color", type: :string
      option :description,  type: :string
      def update(id)
        params = { id: id.to_i, name: options[:name] }
        params[:color]       = options[:color]          if options[:color]
        params[:text_color]  = options[:"text-color"]   if options[:"text-color"]
        params[:description] = options[:description]    if options[:description]
        result = client.update_category(params)
        formatter.print_item(result) if result
        formatter.print_success("Updated category #{id}")
      rescue DiscourseApi::DiscourseError => e
        handle_error(e)
      end

      desc "delete ID", "Delete a category"
      def delete(id)
        client.delete_category(id.to_i)
        formatter.print_success("Deleted category #{id}")
      rescue DiscourseApi::DiscourseError => e
        handle_error(e)
      end
    end
  end
end
