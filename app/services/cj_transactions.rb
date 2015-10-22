class CjTransactions
  
  DEVELOPER_KEY = ENV['CJ_DEVELOPER_KEY']
  WEBSITE_ID = ENV['CJ_WEBSITE_ID']
  
  def self.load_cj_stores(store_cj_id = 'joined')
    #cj = CommissionJunction.new(DEVELOPER_KEY, WEBSITE_ID)

    page = 1 
    advertiser_hash = {
      'advertiser-ids' => store_cj_id,
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
      'records-per-page' => '100',
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
      'records-per-page' => '100',
      'link-type' => 'text link',
      'page-number' => page.to_s
    }

    current_coupons = Coupon.where(coupon_source_id: 3).select(:id_of_coupon).map(&:id_of_coupon)

    begin
      results = []
      cj = CommissionJunction.new(DEVELOPER_KEY, WEBSITE_ID)

      results = cj.link_search(search_hash)
      
      results.each do |link|
        
        unless link.link_id.to_i.in?(current_coupons)

          load_cj_stores(link.advertiser_id) unless Store.find_by_id_of_store(link.advertiser_id.to_i)
          
          if link.coupon_code == "" || link.coupon_code == nil
            coupon_code = nil
          else
            coupon_code = link.coupon_code
          end

          coupon_hash = {
              store_id: Store.find_by_id_of_store(link.advertiser_id.to_i).id,
              link: link.clickUrl,
              id_of_coupon: link.link_id,
              description: link.description,
              title: link.link_name,
              #start_date: (Time.parse(link.promotion_start_date) if link.promotion_start_date),
              code: (coupon_code),
              restriction: nil,
              image: nil,
              impression_pixel: nil,
              coupon_source_id: 3
            }

          if link.promotion_start_date.chars.first == nil || link.promotion_start_date.chars.first == ""
            coupon_hash[ :start_date ] = Time.now
          else
            coupon_hash[ :start_date ] = Time.parse(link.promotion_start_date)
          end

          if link.promotion_end_date.chars.first == nil || link.promotion_end_date.chars.first == ""
            coupon_hash[ :end_date ] = Time.now + 3.years
          else
            coupon_hash[ :end_date ] = Time.parse(link.promotion_end_date)
          end

          new_coupon = Coupon.new(coupon_hash)
          name_check = "#{link.link_name} #{link.description} #{link.category}"

          if new_coupon.save
            find_categories(link.category).each do | category |
              new_coupon.categories << Category.find_by_ls_id(category) if category
            end

            PjTransactions.pj_find_type(name_check).each do | type_x |
              new_coupon.ctypes << Ctype.find_by_ls_id(type_x) if type_x
            end
          end
        end
      end
      page += 1
      search_hash['page-number'] = page.to_s
    end while results.count > 0
  end

  def self.find_categories(name)
    category_hash = {1=> ["Clothing/Apparel", "Men's", "Women's", "Children's", "Malls"],
      5=> ["Automotive", "Parts & Accessories", "Cars & Trucks", "Motorcycles", "Rentals", "Tools and Supplies"],
      6=> ["Bath & Body", "Cosmetics", "Beauty", "Fragrance", "Green" ],
      7=> ["Books/Media", "Books", "Magazines", "News", "Audio Books", "Television", "Videos/Movies"],
      8=> ["Photo", "Art/Photo/Music"],
      9=> ["Rentals", "Car"],
      10=> ["Computer & Electronics", "Computer SW", "Peripherals", "Computer HW", "Computer Support", ],
      11=> ["Matchmaking"],
      12=> ["Department Stores/Malls", "Department Stores", "Virtual Malls"  ],
      13=> ["Consumer Electronics"],
      14=> ["Gifts & Flowers", "Flowers", "Collectibles", "Gifts", "Greeting Cards"],
      15=> ["Home & Garden", "Garden"],
      16=> ["Gifts"],
      17=> ["Food & Drinks", "Gourmet", "Wine & Spirits", "Groceries", "Restaurants"],
      18=> ["Energy Saving", "Recycling", "Green", "Green", "Green", "Green", "Green", "Green", "Green", "Green", "Green"],
      19=> ["Health and Wellness", "Health Food", "Nutritional Supplements", "Pharmaceuticals", "Wellness", "Weight Loss"],
      20=> ["Home Appliances"],
      21=> ["Jewelry","Accessories", "Handbags"],
      23=> ["Entertainment", "Videos/Movies" ],
      24=> ["Pets"],
      25=> ["Personal Insurance", "Insurance", "Legal", "Financial Services", "Banking/Trading", "Credit Cards", "Mortgage Loans", "Real Estate Services", "Tax Services", "Personal Loans" ],
      26=> ["Shoes"],
      27=> ["Services"],
      28=> ["Sports", "Water Sports", "Equipment", "Winter Sports", "Summer Sports", "Golf", "Collectibles and Memorabilia", "Sports & Fitness", "Exercise & Health" ],
      29=> ["Games & Toys", "Games", "Toys", "Electronic Toys"],
      30=> ["Travel", "Air", "Hotel"],
      31=> ["Business", "Marketing", "Office", "Business-to-Business",],
      32=> []
      }
      categories = []

      category_hash.each do | cat_id, match_words |
      unless match_words.select{ |word| name.downcase.include? word.downcase }.join("") == ""
        categories << cat_id
      end
    end

    categories


=begin
  "Careers", "Employment", "College", "Malls", "Buying and Selling", "Auction", "Classifieds", "Utilities", "E-commerce Solutions/Providers",     "Tobacco",       "Astrology", "Communities",     "Online Services", "Search Engine", "Web Design", "Web Tools",  "Investment",  "Accessories", "Luggage",   "Family", "Teens", "Entertainment",  "Network Marketing",  "Shoes", "Construction", "Education", "Professional", , "Weddings",  "Military", "Kitchen", "Languages", "Outdoors", "Furniture", "Party Goods", "Self Help", "Online/Wireless", ,  "Recreation & Leisure",  "Bed & Bath",    "Travel", , "Vacation", "Web Hosting/Servers", "Commercial", "Marketing", "Productivity Tools",   "Children", "Equipment", "Babies", "Real Estate", "Children", "Domain Registrations", "Military", "Business-to-Business", "New/Used Goods", "Internet Service Providers", "Events",  "Telecommunications",   "Betting/Gaming",   ,   "Professional Sports Organizations", "Memorabilia", "Vision Care", "Email Marketing", "Credit Reporting and Repair", "Camping and Hiking", "Blogs", "Broadband", "Seasonal", "Autumn", "Back to School", "Christmas", "Easter", "Father's Day", "Halloween", "Mother's Day", "Spring", "Summer", "Tax Season", "Valentine's Day", "Winter", "Guides", "Discounts", "Mobile Entertainment", "Phone Card Services", "Non-Profit", "Charitable Organizations", "Fundraising", "Electronic Games",  "Apparel", ,   "Black Friday/Cyber Monday", "New Year's Resolution"
=end
  end
end