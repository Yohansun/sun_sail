class ProductSweeper < ActionController::Caching::Sweeper
  observe Product # This sweeper is going to keep an eye on the Product model

  # If our sweeper detects that a Product was created call this
  def after_create(product)
    expire_cache_for(product)
  end

  # If our sweeper detects that a Product was updated call this
  def after_update(product)
    expire_cache_for(product)
  end

  # If our sweeper detects that a Product was deleted call this
  def after_destroy(product)
    expire_cache_for(product)
  end

  private
  def expire_cache_for(product)
    # Expire the index page now that we added a new product
    # expire_action(controller: 'products', action: 'show')
    # expire_action(controller: 'products', action: 'edit')
    # expire_action(controller: 'products', action: 'index', cache_path: Proc.new { |controller| controller.params })
    # Expire a fragment
    expire_fragment(/products/)
  end
end
