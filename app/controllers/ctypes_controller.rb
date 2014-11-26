class CtypesController < ApplicationController
  include LoadCoupons
  include LoadSeo

  def show
    @ctype = Ctype.friendly.find(params[:id])
    load_all_coupons(@ctype)
    render 'coupons/display_coupons', locals: { title: @ctype, meta_keywords: seo_keywords(@coupons, @ctype), meta_description: seo_description(@coupons, @ctype)}
  end
end