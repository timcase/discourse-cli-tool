# frozen_string_literal: true

module DiscourseCli
  module Commands
    class Topics < Base
      desc "list", "List latest topics"
      option :category, type: :string, desc: "Filter by category slug"
      def list
        params = {}
        params[:category] = options[:category] if options[:category]
        formatter.print_list(client.latest_topics(params))
      rescue DiscourseApi::DiscourseError => e
        handle_error(e)
      end

      desc "show ID", "Show a topic"
      def show(id)
        formatter.print_item(client.topic(id.to_i))
      rescue DiscourseApi::DiscourseError => e
        handle_error(e)
      end

      desc "create", "Create a topic (opens $EDITOR if --raw not given)"
      option :title,    type: :string, required: true
      option :category, type: :numeric, desc: "Category ID"
      option :tags,     type: :string, desc: "Comma-separated tags"
      option :raw,      type: :string
      def create
        raw = resolve_raw(options[:raw])
        params = { title: options[:title], raw: raw }
        params[:category] = options[:category]                      if options[:category]
        params[:tags]     = options[:tags].split(",").map(&:strip)  if options[:tags]
        formatter.print_item(client.create_topic(params))
      rescue DiscourseApi::DiscourseError => e
        handle_error(e)
      end

      desc "update ID", "Update a topic"
      option :title,    type: :string
      option :category, type: :numeric, desc: "Category ID"
      option :raw,      type: :string, desc: "Replace first post content (opens $EDITOR if not given and no other options)"
      def update(id)
        updated_anything = false

        if options[:title]
          client.rename_topic(id.to_i, options[:title])
          updated_anything = true
        end

        if options[:category]
          client.recategorize_topic(id.to_i, options[:category])
          updated_anything = true
        end

        raw =
          if options[:raw]
            options[:raw]
          elsif !updated_anything && !$stdin.tty?
            $stdin.read
          elsif !updated_anything
            Editor.new.open
          end

        if raw
          topic_data = client.topic(id.to_i)
          first_post_id = topic_data["post_stream"]["posts"][0]["id"]
          client.edit_post(first_post_id, raw)
        end

        formatter.print_success("Updated topic #{id}")
      rescue DiscourseApi::DiscourseError => e
        handle_error(e)
      end

      desc "delete ID", "Delete a topic"
      def delete(id)
        client.delete_topic(id.to_i)
        formatter.print_success("Deleted topic #{id}")
      rescue DiscourseApi::DiscourseError => e
        handle_error(e)
      end
    end
  end
end
