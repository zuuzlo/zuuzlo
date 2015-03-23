class StoresController < ApplicationController
  include LoadCoupons
  include LoadSeo

  before_filter :require_user, only:[:save_store, :remove_store]

  def index
    @stores = Store.friendly.to_a
    featured = Store.with_coupons.collect(&:id).sample(12)
    @stores_featured = Store.find(featured)

    @store_array = []
    @stores.each do | store |
      @store_array << store.name
    end
    render layout: 'store_index'
  end

  def show
    @store = Store.friendly.find(params[:id])
    load_all_coupons(@store)
    render 'coupons/display_coupons', locals: { title: @store, meta_keywords: seo_keywords(@coupons, @store), meta_description: seo_description(@coupons, @store)}
  end

  def save_store
    @store = Store.find_by_id(params[:store_id])
    current_user.stores << @store
    flash[:success] = "#{@store.name} has been added to your favorites."
    respond_to do |format|
      format.html do  
        redirect_to :back
      end
      format.js
    end
  end

  def remove_store
    @store = Store.find_by_id(params[:store_id])
    current_user.stores.delete(@store)
    flash[:success] = "#{@store.name} has been removed from your favorites."
    respond_to do |format|
      format.html do  
        redirect_to :back
      end
      format.js
    end
  end
end
