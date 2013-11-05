class FinderCacheObserver < ActiveRecord::Observer
  CACHE_STORE = Rails.application.config.cache_store
  observe :account,:trade_source,:taobao_app_token,:logistic

  def after_commit(object)
    Rails.cache.delete_matched(object.cache_path,namespace: FinderCache::NAMESPACE)
  end
end
