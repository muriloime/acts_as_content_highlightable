Rails.application.routes.draw do
  mount ActsAsContentHighlightable::Engine => "/" if ActsAsContentHighlightable.mount
end

ActsAsContentHighlightable::Engine.routes.draw do
  scope module: "acts_as_content_highlightable" do
    get 'content_highlights/index'
    post 'content_highlights/create'
    post 'content_highlights/destroy'
  end
end
