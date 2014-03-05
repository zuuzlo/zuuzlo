class Coupon < ActiveRecord::Base

  require 'action_view'
  include ActionView::Helpers::DateHelper

  belongs_to :store
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :ctypes
  
  validates :id_of_coupon, presence: true, uniqueness: true
  validates :title, presence: true
  validates :link, presence: true

  def time_left
    distance_of_time_in_words(end_date, DateTime.now)
  end

  def time_difference
    end_date - DateTime.now
  end

  def store_name
    Store.find(self.store_id).name
  end

  def store_image
    Store.find(self.store_id).store_img
  end

  def store_commission
    Store.find(self.store_id).commission / 2
  end

  def self.search_by_title(search_term)
    return [] if search_term.blank?
    where("lower(description) LIKE ?", "%#{search_term.downcase}%")
  end

  def self.coupon_import
    xml_string = open("#{Rails.root}/LSoutZ.xml").read
    root = Nokogiri::XML(xml_string)
    links = root.xpath("couponfeed/link")

    links.each do |link|
    
    link_hash = {
      id_of_coupon: link.at_xpath("id").text,
      title:  link.at_xpath("title").text,
      description: link.at_xpath("offerdescription").text,
      start_date: Time.parse(link.at_xpath("offerstartdate").text),
      #end_date: (Time.parse(link.at_xpath("offerenddate").text) if link.at_xpath("offerenddate")),
      code: (link.at_xpath("couponcode").text if link.at_xpath("couponcode")),
      restriction: (link.at_xpath("couponrestriction").text if link.at_xpath("couponrestriction")),
      link: link.at_xpath("clickurl").text,
      image: "nil",
      impression_pixel: link.at_xpath("impressionpixel").text,
      store_id: Store.find_by_id_of_store(link.at_xpath("advertiserid").text).id
      }
      
      if link.at_xpath("offerenddate").text == ''
        #requie 'pry';binding.pry
        link_hash[ :end_date ] = Time.parse('2017-1-1') #DateTime.now + 5.years
      else
        link_hash[ :end_date ] = Time.parse(link.at_xpath("offerenddate").text)
      end

      new_coupon = Coupon.new(link_hash)
      if new_coupon.save
  
        link.at_xpath("categories").children.each do | category |
          new_coupon.categories << Category.find_by_ls_id(category.attr("id").to_i) if category.attr("id")
        end

        link.at_xpath("promotiontypes").children.each do | type_x |
          new_coupon.ctypes << Ctype.find_by_ls_id(type_x.attr("id").to_i) if type_x.attr("id")
        end
      end
    end
  end
end