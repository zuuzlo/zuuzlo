module LoadSeo
  extend ActiveSupport::Concern

  def seo_description(coupons, category)
    if logged_in?
      "checking"
    else
      if category
        description = "#{Time.now.strftime("%B, %Y")} Kohls #{category.name} coupons. "
      else
        description = "#{Time.now.strftime("%B, %Y")} Kohls coupons. "
      end
      coupons.each do |coupon|
        description += coupon.description.gsub(/(\d{2}|\d{1})\/(\d{2}|\d{1})(-|.-.)(\d{2}|\d{1})\/(\d{2}|\d{1})/, "").gsub(/(Sept|Oct|Nov|Dec|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug)(\s*)(\d*|)(-|.-.|)/,"") + " " if description.length < 160
      end

      description[0..150] + "..."
    end
  end

  def seo_keywords(coupons, category)
    if logged_in?
      "kohls, kohls coupons"
    else
      if category
        keywords = ["Kohls #{category.name} coupon codes", "Kohls #{category.name} deals"]
      else
        keywords = ["Kohls coupon codes", "Kohls deals"]
      end

      coupons.each do |coupon|
        description_keywords = FindKeywords::Keywords.new("#{coupon.description}").keywords
        keywords << coupon.code if coupon.code
        keywords = keywords + description_keywords if keywords.uniq.count < 20
      end

      keywords.uniq.join(", ")
    end
  end
end