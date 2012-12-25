class BbsCategoriesController < ApplicationController
	# before_filter :authenticate_user!
	before_filter :fetch_categories
	def show
		@category = BbsCategory.find(params[:id])
		@topics = @category.bbs_topics.page(params[:page]).per(4)
	end

	private

  def fetch_categories
    @categories = BbsCategory.all
  end

end
