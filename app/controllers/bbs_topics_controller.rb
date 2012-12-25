class BbsTopicsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :fetch_categories, except: [:download, :create]
  before_filter :fetch_topic, except: [:index, :new, :create, :list]

  def index
    @hot_topics = BbsTopic.hot.limit(10)
    @latest_topics = BbsTopic.latest.limit(10)
  end

  def new
    @topic = BbsTopic.new
  end

  def create
    @topic = BbsTopic.new(topic_params)
    @topic.user_id = current_user.id
    if @topic.save
      redirect_to bbs_topics_path
    else
      render :new
    end
  end

  def update
    if @topic.update_attributes(topic_params)
      redirect_to bbs_topics_path
    else
      render :edit
    end
  end

  def list
    if params[:category] == "hot"
    @hot_topics = BbsTopic.page(params[:page]).per(4)
    else
    @latest_topics = BbsTopic.page(params[:page]).per(4)
    end
  end

  def destroy
     @r = BbsTopic.find(params[:id])
     @r.destroy
     redirect_to bbs_topics_path
  end

  def edit
    @topic = BbsTopic.find(params[:id])
  end

  def show
    @count = @topic.read_count + 1
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
