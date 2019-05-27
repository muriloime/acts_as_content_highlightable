# frozen_string_literal: true

module ActsAsContentHighlightable
  class ContentHighlightsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_highlighter_user
    before_action :set_highlightable
    before_action :set_highlightable_column, only: %i[add index]
    load_and_authorize_resource :content_highlight, class: ContentHighlight

    def index
      if @highlightable.present? && (ContentHighlight.respond_to?(:can_view_highlights?) ? ContentHighlight.can_view_highlights?(@highlightable, @highlighter_user) : true)
        show_highlights = ContentHighlight.highlights_to_show(@highlightable, @highlighter_user, request: request).enrich_highlights(@highlighter_user)
      else
        show_highlights = []
      end

      render json: { all_highlights: show_highlights.as_json }
    end

    def create
      if @highlightable.present? && ContentHighlight.can_create_highlight?(@highlighter_user)
        content_highlight = @highlightable.content_highlights.new(
          user: @highlighter_user,
          highlightable_column: @highlightable_column,
          content: params[:content],
          container_node_identifier_key: params[:common_ancestor_identifier_key],
          container_node_identifier: params[:common_ancestor_identifier],
          container_node_type: params[:common_ancestor_node_type],
          startnode_offset: params[:start_offset],
          endnode_offset: params[:end_offset],
          selection_backward: params[:backward]
        )
        content_highlight.save
        show_highlights = ContentHighlight.highlights_to_show(@highlightable, @highlighter_user, request: request).enrich_highlights(@highlighter_user)
      else
        show_highlights = []
      end

      render json: { all_highlights: show_highlights.as_json, new_highlight_id: content_highlight&.id }
    end

    def destroy
      content_highlight = @highlightable.content_highlights.where(id: params[:content_highlight_id]).first
      if content_highlight.present? && (content_highlight.respond_to?(:can_remove_highlight?) ? content_highlight.can_remove_highlight?(@highlighter_user) : (content_highlight.user == @highlighter_user))
        remove_highlights = @highlightable.content_highlights.where(id: content_highlight.id).enrich_highlights(@highlighter_user).as_json
        content_highlight.destroy
      else
        remove_highlights = []
      end
      render json: { all_highlights: remove_highlights }
    end

    private

    def set_highlightable_column
      if params[:highlightable_column].blank? && @highlightable.highlightable_columns.size > 1
        raise ArgumentError, 'More than one highlightable column found. Please provide highlightable_column in your parameters'
      elsif params[:highlightable_column].blank?
        @highlightable_column = @highlightable.highlightable_columns.first.to_s
      else
        @highlightable_column = params[:highlightable_column].to_s
      end

      unless @highlightable.respond_to?(:highlightable_columns)
        raise ArgumentError, 'Highlightable column not found. Please check the parameter: highlightable_column'
      end

      unless @highlightable.highlightable_columns.include? @highlightable_column
        raise ArgumentError, 'Invalid Highlightable column'
      end
    end

    def set_highlightable
      highlightable_model = params[:highlightable_type].to_s.constantize
      @highlightable = highlightable_model.respond_to?(:find_by_id) && highlightable_model.find(params[:highlightable_id])

      if @highlightable.nil?
        raise ArgumentError, 'Highlightable item not found. Please check the parameter: highlightable_id'
      end

      @highlightable = nil unless @highlightable.respond_to?(:highlightable_columns)
    end

    def set_highlighter_user
      @highlighter_user ||= (respond_to?(:current_user) && current_user) || (respond_to?(:current_resource_owner, true) && send(:current_resource_owner)) || nil
    end
  end
end
