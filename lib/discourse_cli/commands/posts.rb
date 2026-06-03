# frozen_string_literal: true

module DiscourseCli
  module Commands
    class Posts < Base
      desc "list", "List recent posts"
      def list
        response = client.posts
        items = response["latest_posts"] || []
        formatter.print_list(items)
      rescue DiscourseApi::DiscourseError => e
        handle_error(e)
      end

      desc "show ID", "Show a post"
      def show(id)
        formatter.print_item(client.get_post(id.to_i))
      rescue DiscourseApi::DiscourseError => e
        handle_error(e)
      end

      desc "create", "Create a post (opens $EDITOR if --raw not given)"
      option :"topic-id", type: :numeric, required: true
      option :raw, type: :string
      def create
        raw = resolve_raw(options[:raw])
        result = client.create_post(topic_id: options[:"topic-id"], raw: raw)
        formatter.print_item(result)
      rescue DiscourseApi::DiscourseError => e
        handle_error(e)
      end

      desc "update ID", "Update a post (opens $EDITOR if --raw not given)"
      option :raw, type: :string
      def update(id)
        raw = resolve_raw(options[:raw])
        client.edit_post(id.to_i, raw)
        formatter.print_success("Updated post #{id}")
      rescue DiscourseApi::DiscourseError => e
        handle_error(e)
      end

      desc "delete ID", "Delete a post"
      def delete(id)
        client.delete_post(id.to_i)
        formatter.print_success("Deleted post #{id}")
      rescue DiscourseApi::DiscourseError => e
        handle_error(e)
      end
    end
  end
end
