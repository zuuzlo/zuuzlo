module AdminLoadSeo
  extend ActiveSupport::Concern

  def seo_description(coupons, category)
    description = "{"
    if category
      description += "#{Time.now.strftime("%B, %Y")} Kohls #{category.name} coupons. "
    else
      description += "#{Time.now.strftime("%B, %Y")} Kohls coupons. "
    end
    coupons.each do |coupon|
      description += coupon.description.gsub(/(\d{2}|\d{1})\/(\d{2}|\d{1})(-|.-.)(\d{2}|\d{1})\/(\d{2}|\d{1})/, "").gsub(/(Sept|Oct|Nov|Dec)(\s*)(\d*|)(-|.-.|)/,"") + " " 
      description += "|" unless coupon == coupons.last
    end

    description += "}"
  end

  def seo_keywords(coupons, category)
    
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