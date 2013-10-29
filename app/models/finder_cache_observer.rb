class FinderCacheObserver < ActiveRecord::Observer
  observe :account,:trade_source,:taobao_app_token

  def after_commit(object)
    Rails.cache.delete_matched(/^#{object.cache_path}$/,namespace: FinderCache::NAMESPACE)
  end
end
