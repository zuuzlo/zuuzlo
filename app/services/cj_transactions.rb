class CjTransactions
  
  DEVELOPER_KEY = ENV['CJ_DEVELOPER_KEY']
  WEBSITE_ID = ENV['CJ_WEBSITE_ID']
  
  def self.load_cj_stores
    #cj = CommissionJunction.new(DEVELOPER_KEY, WEBSITE_ID)

    page = 1 
    advertiser_hash = {
      'advertiser-ids' => 'joined',
      'records-per-page' => '100',
      'page-number' => page.to_s
    }

    current_stores = Store.select(:id_of_store).map(&:id_of_store)

    begin
      results = []
      #require 'pry'; binding.pry
      cj = CommissionJunction.new(DEVELOPER_KEY, WEBSITE_ID)
      results = cj.advertiser_lookup(advertiser_hash)
      #require 'pry'; binding.pry
      results.each do |advertiser|
        
        if advertiser.advertiser_id.to_i.in?(current_stores)
          current_store = Store.find_by(id_of_store: advertiser.advertiser_id.to_i)
          current_store.update(active_commission: true )   if advertiser.account_status == 'Active' && current_store.active_commission == false

        else
          store_hash = {
            name: advertiser.advertiser_name,
            id_of_store: advertiser.advertiser_id,
            #description: advertiser.,
            home_page_url: advertiser.program_url,
            commission: find_commission(advertiser.actions['action']),
            store_img: find_image(advertiser.advertiser_id.to_i)
          }

          if advertiser.account_status == 'Active'
            store_hash[:active_commission] = true
          else
            store_hash[:active_commission] = false
          end

          new_store = Store.new(store_hash)
          new_store.save if advertiser.link_types['link_type'] & ['Text Link']
        end
      end

      page +=1
      advertiser_hash['page-number'] = page.to_s
    end while results.count > 0
  end

  def self.find_commission(data)
    if data.is_a?(Hash)
      commission = data['commission']['default']
    else
      commission = data[0]['commission']['default']
    end

    if commission.is_a?(String)
      return commission.split("%").first.to_f
    else
      return commission['__content__'].split("%").first.to_f
    end
  end

  def self.find_image(store_id)
    @image_link = nil
    search_hash = {
      'website-id' => WEBSITE_ID,
      'advertiser-ids' => store_id,
      'records-per-page' => '1000',
      'link-type' => 'Banner'
    }

    cji = CommissionJunction.new(DEVELOPER_KEY, WEBSITE_ID)

    cji.link_search(search_hash).each do |link|
      if link.creative_width == "120" && link.creative_height == "60"
        @image_link = Nokogiri::HTML(link.link_code_html).at_css('img').attr('src')
      end
      break if @image_link
    end

    if @image_link 
      @image_link
    else
      "#{Rails.root}/images/coming_soon.jpg"
    end
  end

  def self.cj_update_coupons
    page = 1
    search_hash = {
      'website-id' => WEBSITE_ID,
      'advertiser-ids' => "joined",
      'records-per-page' => '1000',
      'link-type' => 'Text Link',
      'page-number' => page.to_s
    }

    cj = CommissionJunction.new(DEVELOPER_KEY, WEBSITE_ID)

    cj.link_search(search_hash).each do |link|
      
      coupon_hash = {
          store_id: Store.find_by_id_of_store(link.advertiser_id.to_i).id,
          link: link.clickURL,
          id_of_coupon: link.link_id,
          description: link.description,
          title: link.link_name,
          start_date: (Time.parse(link.promotion_start_date) if link.promotion_start_date),
          code: (link.coupon_code if link.coupon_code),
          restriction: nil,
          image: nil,
          impression_pixel: nil,
          coupon_source_id: 3
        }

      new_coupon = Coupon.new(coupon_hash)
      new_coupon.save
  end
end