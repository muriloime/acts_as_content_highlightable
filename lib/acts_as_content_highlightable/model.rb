module ActsAsContentHighlightable
  module Model
    def acts_as_content_highlightable_on(column_names, options = {})
      column_names = Array.wrap(column_names)

      if not column_names.all? { |column_name| self.column_names.include? column_name.to_s }
        raise ArgumentError, "acts_as_content_highlightable_on: One or more invalid attribute #{column_names}"
      end

      setup_options(column_names, options)

      class_eval do
        has_many :content_highlights, as: :highlightable
        before_save :prepare_for_content_highlights, if: -> {column_names.all?{|column_name| send("#{column_name}_changed?".to_sym)}}
      end

      include ActsAsContentHighlightable::Model::InstanceMethods
    end

    def setup_options(column_names, options)
      self.class_attribute :acts_as_content_highlightable_options
      self.acts_as_content_highlightable_options = options.dup
      self.acts_as_content_highlightable_options[:column_names] = column_names
    end

    module InstanceMethods
      def highlightable_columns
        acts_as_content_highlightable_options[:column_names].map(&:to_s)
      end

      def highlight?
        if_condition = acts_as_content_highlightable_options[:if]
        unless_condition = acts_as_content_highlightable_options[:unless]
        (if_condition.blank? || if_condition.call(self)) && !unless_condition.try(:call, self)
      end

      def prepare_for_content_highlights
        return unless highlight?

        acts_as_content_highlightable_options[:column_names].each do |column_name|
          self[column_name.to_sym] = ActsAsContentHighlightable::HtmlNodeParser.new(self[column_name.to_sym]).assign_unique_node_identifiers("data-" + ActsAsContentHighlightable.unique_html_node_identifier_key).body_content
        end
      end
    end
  end
end
