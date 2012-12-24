class BbsTopicsController < ApplicationController
  before_filter :fetch_categories, except: [:download, :create]
  before_filter :fetch_topic, except: [:index, :new, :create]

  def index
    @hot_topics = BbsTopic.hot.limit(10)
    @latest_topics = BbsTopic.latest.limit(10)
  end

  def new
    @topic = BbsTopic.new
  end

  def create
    @topic = BbsTopic.new(topic_params)
    if @topic.save
      redirect_to @topic
    else
      render :new
    end
  end

  def update
    if @topic.update_attributes(topic_params)
      redirect_to @topic
    else
      render :edit
    end
  end

  def show
    BbsTopic.increment_counter(:read_count, @topic.id)
    # @attachements = @topic.attachements
  end

  def download
    # TODO: bind the attachments with request
    BbsTopic.increment_counter(:download_count, @topic.id)
    send_file(Rails.root.join('public', 'robots.txt'), :filename => "download-robots.txt")
  end

  private

  def fetch_categories
    @categories = BbsCategory.all
  end

  def fetch_topic
    @topic = BbsTopic.find(params[:id])
  end

  def topic_params
    params.require(:bbs_topic).permit(:bbs_category_id, :title, :body)
  end

end
