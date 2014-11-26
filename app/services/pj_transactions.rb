class PjTransactions

  require 'open-uri'

  EBayEnterpriseAffiliateNetwork.api_key = ENV["EEAN_API_KEY"]

  def self.pj_stores_get
    publisher = EBayEnterpriseAffiliateNetwork::Publisher.new
    response = publisher.get("advertiser", status: :joined)
    response.data.each do |advertiser|
      store_hash = {
        name: advertiser.name,
        id_of_store: advertiser.id.to_i,
        description: advertiser.description,
        home_page_url: advertiser.website,
        commission: advertiser.percentage_payout.to_f,
        store_img: advertiser.logo
      }

      if advertiser.status == 'joined'
        store_hash[:active_commission] = true
      else
        store_hash[:active_commission] = false
      end
      
      new_store = Store.new(store_hash)
      
      unless new_store.save 
        Store.find_by_id_of_store(advertiser.id.to_i).update!(active_commission: "true") if advertiser.status == 'joined'
      end
    end
  end
  def self.pj_update_coupons
    publisher = EBayEnterpriseAffiliateNetwork::Publisher.new
    response = publisher.get("creative/coupon", {})
    response.all.each do | coupon |

      coupon_hash = {
        store_id: Store.find_by_id_of_store(coupon.program_id.to_i).id,
        link: coupon.code,
        id_of_coupon: coupon.id,
        description: coupon.description,
        title: LsTransactions.title_shorten(coupon.name),
        start_date: Time.parse(coupon.start_date),
        code:( coupon.coupon if pj_coupon_code_valid?(coupon.coupon)),
        coupon_source_id: 2,
      }
      if coupon.end_date.chars.first == "0" || coupon.end_date.chars.first == ""
        coupon_hash[ :end_date ] = Time.parse('2017-1-1') #DateTime.now + 5.years
      else
        coupon_hash[ :end_date ] = Time.parse(coupon.end_date)
      end

      new_coupon = Coupon.new(coupon_hash)
      name_check = "#{coupon.name} #{coupon.description} #{coupon.category_name}"
      if new_coupon.save
        pj_find_category(name_check).each do | category |
          new_coupon.categories << Category.find_by_ls_id(category) if category
        end

        pj_find_type(name_check).each do | type_x |
          new_coupon.ctypes << Ctype.find_by_ls_id(type_x) if type_x
        end
      end
    end
  end

  def self.pj_activity
    publisher = EBayEnterpriseAffiliateNetwork::Publisher.new
    params = { startDate: "#{last_update_pj}", endDate: "#{DateTime.now.strftime("%Y-%m-%d")}", website: 'all' }
    response = publisher.get( "report/transaction-details", params )
    require 'pry'; binding.pry
    response.all.each do | transaction |
      if User.exists?(cashback_id: transaction.sid) && Store.exists?(id_of_store: transaction.program_id )
        row_hash = {
          user_id: User.find_by_cashback_id(transaction.sid).id,
          store_id: Store.find_by_id_of_store(transaction.program_id).id,
          clicks: ( 1 if transaction.type = "click" ),
          sales_cents: transaction.sale_amount.split('.').join.to_i,
          commission_cents: transaction.commission.split('.').join.to_i
        }

        row_record = Activity.where( "user_id = ? and store_id = ?", row_hash[:user_id] , row_hash[:store_id] ).first
      
        if row_record
          #update record
          row_hash[:clicks] += row_record.clicks
          row_hash[:sales_cents] += row_record.sales_cents
          row_hash[:commission_cents] += row_record.commission_cents
          row_record.update_attributes(clicks: row_hash[:clicks], sales_cents: row_hash[:sales_cents], commission_cents: row_hash[:commission_cents])
        else
          #create new record
          new_row_record = Activity.new(row_hash)
          new_row_record.save
        end

      end
    end

  end

  def self.last_update_pj
    last_activity_update = Activity.order("updated_at DESC").first
    if last_activity_update
      last_activity_update.updated_at.strftime("%Y-%m-%d")
    else
      time = DateTime.now - 1.month
      time.strftime("%Y-%m-%d")
    end
  end

  def self.pj_coupon_code_valid?(code)
    not_code = ["n/a", "not ", "no "]
    code_lc = code.downcase
    
    if not_code.select{ |word| code_lc.include? word }.join("") == ""
      true
    else
      false
    end
  end

  def self.pj_find_category(name)
    category_hash = { 1=> ['apparel', 'accoutrement', 'attire', 'clothes', 'costume', 'drapery','dress','dresses', 'duds', 'clothing','garb', 'garment', 'getup', 'habiliment', 'habit', 'outfit','raiment', 'robe', 'suit', 'threads', 'trapping', 'vestment', 'jeans', 'shirt','pants', 'skirt','sleepwear', 'tees', 'tee','underwear','activewear','denium','denim','wrangler','cardigan', 'top','hoodie','swimwear','flacket','sweater','jacket','bottoms','designation','jeggings','capris','blazer', 'workware', 'dickies',' kate young'],
      5=> ['car', 'automotive', 'tools', 'tool', 'craftsman','drill','weatherhandler','compressor','tender','scraper','tires'],
      6=> ['beauty', 'fragrance', 'perfume', 'makeup', 'nail', 'cosmetic', 'skin care', 'hair color', 'razor', 'shaving', 'contact lens', 'glasses','haircare','cosmetics', 'fragrances'],
      7=> ['book', 'books', 'magazine', 'magazines', 'novel','bestseller','paperback'],
      8=> ['cameras','camera','photo','photography'],
      10=> ['computer','computers','laptops','laptop','memory', 'hard drive','usb', 'printer','tablet','keyboard','ram','mouse','monitor','router','galaxy', 'tab','pc','intel', 'pentium','notebook'],
      13=> ['tv','headphones','headphone','mp3', 'speakers', 'cd', 'radio', 'stereo','laser', 'mobile phone', 'satellite', 'telephone', 'cables', 'batteries', 'ups', 'projector', 'dvd', 'player', 'blu-ray', 'playstation', 'xbox', 'wii', ' nintendo', 'game boy', 'leapfrog','hdtv','electronics','led','lcd','ipad','iphone','ipod'],
      14=> ['flowers', 'flower', 'roses','plants'],
      15=> ['garden', 'gardening', 'outdoor', 'trees','pool','spa','mower', 'lawn', 'sprinkler','mulch', 'lanscape', 'snow','rain','backyard','flags','flag','trashcan','trash', 'patio'],
      16=> ['gift','gifts'],
      17=> [ 'food' ],
      19=> ['diet','vitamins','otc','cough','flu','nutrition','protein','health','wellness','personal'],
      20=> ['smoke detector','security','appliances', 'appliance', 'air conditioner','purifier','furnace','dehumidifier','fan','laundry','sewing','vacuum','carpet','floor','household','organization','storage','kitchen','dining', 'cookware','bakeware','dishes','griddle','pots','pans','woks','racks','lunch', 'table','chair','bottle','blender','coffee','cooktop','fryer','washer','dryer', 'dishwasher','mixer','oven','juicer','range','toaster','knife','knives','peeler', 'utensil','bowl','spoon','fork','drinkware','cup','pitcher','flatware','bedding', 'bath','home','pillows','sheet','refrigerator','kenmore','heater','vac','comforter', 'sheets','window','shower','deteregent','lights','pillow','comforters','dinnerware','irons','furniture', 'container','luggage'],
      21=> ['jewelry','anklets','bracelets','brooches','lapels','charms', 'pendants','necklace','watches','rings','diamonds','handbags','bags','wallets','belts', 'bridal','earmuffs','gloves','mittens','hat', 'hats','headwear','neckties','sunglasses', 'money clip','tote','satchel','earrings','pendant'],
      23=> ['movie','movies','music', 'song','songs'],
      24=> ['cat','pet','pets','dog','horse','ferret','cats','dogs','flea','tick','bird','ferret.com','dog.com','bird.com','aquariums','fish.com','fish','frontline'],
      26=> ['shoes', 'shoe','footwear','sandals','sandal','boots','boot','sole','flats','loafers','loafer','clogs','clog','flip'],
      28=> ['nfl', 'ncaa', 'nhl', 'mlb','hockey','nba','football', 'exercise','baseball','basketball','fitness','bikes','scooter','bike','treadmill','everlast'],
      29=> ['toys', 'toy', 'games', 'doll', 'wii', 'ds3','train','fisher-price','nerf','slide'],
      32=> ['baby','babies','newborn','toddler','kid','kids']
    }
    categories = []
    
    category_hash.each do | cat_id, match_words |
      unless match_words.select{ |word| name.downcase.include? word }.join("") == ""
        categories << cat_id
      end
    end

    categories
  end

  def self.pj_find_type(name)

    type_hash = { 1 => [ 'general promotion', 'promotion' ],
      2 => [ /buy one get one/,/buy 1/, /get 1/ ],
      3 => [ /clearance/ ],
      4 => [ /combination savings/ ],
      5 => [ /\$/ ],
      6 => [ /free trial/ ],
      7 => [ /free shipping/, /ships free/ ],
      8 => [ /friends and family/ ],
      9 => [ /gift/, /gift with purchase/ ],
      11 => [ /\% off/,/\% OFF/,/\% on/,/\%/ ],
      14 => [ /daily deal/,/deal of the day/ ],
      30 => [ /black friday/ ],
      31 => [ /cyber monday/ ]
    }

    types = []

    type_hash.each do | type_id, match_words |
      unless match_words.select{ |word| name.downcase.include? word }.join("") == ""
        types << type_id
      end
    end

    types
  end
end


