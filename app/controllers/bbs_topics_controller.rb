class BbsTopicsController < ApplicationController
  before_filter :fetch_categories

  def index
    @hot_topics = BbsTopic.hot.limit(10)
    @latest_topics = BbsTopic.latest.limit(10)
  end

  private

  def fetch_categories
    @categories = BbsCategory.all
  end
end
