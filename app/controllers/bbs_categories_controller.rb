class BbsCategoriesController < ApplicationController
	before_filter :authenticate_user!
	before_filter :fetch_categories
	def show
		@category = current_account.bbs_categories.find(params[:id])
		@topics = @category.bbs_topics.latest.page(params[:page]).per(20)
	end

	private

  def fetch_categories
    @categories = current_account.bbs_categories.all
  end

end
