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
    @topic.upload_files.build
    @topic.upload_files.build
  end

  def create
    @topic = BbsTopic.new(topic_params)
    @topic.user_id = current_user.id
    if params[:uploads].any?
      params[:uploads].each do |upload_file|
        @topic.upload_files << UploadFile.new(file: upload_file)
      end
    end
    if @topic.save
      redirect_to bbs_category_path(:id => @topic.bbs_category_id)
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
    @name = current_user.username
    if params[:category] == "hot"
    @hot_topics = BbsTopic.page(params[:page]).per(20)
    else
    @latest_topics = BbsTopic.page(params[:page]).per(20)
    end
  end

  def destroy
     @topic = BbsTopic.find(params[:id])
     bbs_category_id = @topic.bbs_category_id
     @topic.destroy
     if params[:category] == "hot"
       redirect_to list_bbs_topics_path(:category => "hot")
     elsif params[:category] == "category"
       redirect_to bbs_category_path(:id => bbs_category_id)
     else 
      redirect_to list_bbs_topics_path(:category => "last")
     end
  end

  def show
    BbsTopic.increment_counter(:read_count, @topic.id)
  end

  def download
    target_file = UploadFile.find(params[:fid])
    if target_file
      BbsTopic.increment_counter(:download_count, @topic.id)
      send_file target_file.file.path
    else
      render nothing: true, status: 404
    end
  end

  def print
    
  end

  private

  def fetch_categories
    @categories = BbsCategory.all
  end

  def fetch_topic
    @topic = BbsTopic.find(params[:id])
  end

  def topic_params
    params.require(:bbs_topic).permit(:bbs_category_id, :title, :body, :upload_files)
  end


end
