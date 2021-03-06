class LsTransactions

  require 'csv'
  require 'open-uri'

  LinkshareAPI.token = ENV["LINKSHARE_TOKEN"]

  def self.ls_activity
    url = "https://reportws.linksynergy.com/downloadreport.php?bdate=#{last_update_ls}&edate=#{DateTime.now.strftime("%Y%m%d")}&token=62017e672fbab4c4c474ec35eb740c1939922b48c39186690dbffe4908703185&reportid=11&locale=de"
    activities = CSV.new(open(url), :headers => :first_row)
    array_of_rows = activities.read
    
    num = array_of_rows.length - 1

    (1..num).each do | i |
      if User.exists?(cashback_id: array_of_rows['Member ID'][i]) && Store.exists?(id_of_store: array_of_rows['Advertiser ID'][i] )
        #Member ID,Advertiser ID,Advertiser Name,Clicks,Sales,Commissions
        
        row_hash = {
          user_id: User.find_by_cashback_id(array_of_rows['Member ID'][i]).id,
          store_id: Store.find_by_id_of_store(array_of_rows['Advertiser ID'][i]).id,
          
          clicks: array_of_rows['Clicks'][i].to_i,
          sales_cents: array_of_rows['Sales'].split('.').join.to_i,
          commission_cents: array_of_rows['Commissions'].split('.').join.to_i
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

  def self.last_update_ls
    last_activity_update = Activity.order("updated_at DESC").first
    if last_activity_update
      last_activity_update.updated_at.strftime("%Y%m%d")
    else
      time = DateTime.now - 1.month
      time.strftime("%Y%m%d")
    end
  end

  def self.ls_update_coupons

    options = {
      network: 1 
    }

    coupon_ids = Coupon.select(:id_of_coupon).map(&:id_of_coupon)
    response = LinkshareAPI.coupon_web_service(options).all
    response.each do |link|
      unless ls_coupon_id(link.advertiserid, link.clickurl).in?(coupon_ids)
        coupon_hash = {
          store_id: Store.find_by_id_of_store(link.advertiserid.to_i).id,
          link: link.clickurl,
          id_of_coupon: ls_coupon_id(link.advertiserid, link.clickurl),
          description: link.offerdescription,
          title: title_shorten(link.offerdescription),
          start_date: Time.parse(link.offerstartdate),
          code: (link.couponcode if link.couponcode),
          restriction: (link.couponrestriction if link.couponrestriction),
          image: "nil",
          impression_pixel: link.impressionpixel,
          coupon_source_id: 1
        }

        if link.offerenddate == '' || link.offerenddate.downcase == "ongoing"
          coupon_hash[ :end_date ] = Time.parse('2017-1-1') #DateTime.now + 5.years
        else
          coupon_hash[ :end_date ] = Time.parse(link.offerenddate)
        end

        new_coupon = Coupon.new(coupon_hash)
        
        if new_coupon.save
    
          link.categories.category.each do | category |
            new_coupon.categories << Category.find_by_ls_id(category["id"].to_i) if category["id"]
          end

          link.promotiontypes.promotiontype.each do | type_x |
            new_coupon.ctypes << Ctype.find_by_ls_id(type_x["id"].to_i) if type_x["id"]
          end
        end
      end
    end
  end

  def self.load_ls_stores
    oo = Roo::CSV.new("#{Rails.root}/store.csv", csv_options: {encoding: Encoding::ISO_8859_1})
    oo.default_sheet = oo.sheets.first
   
    current_stores = Store.select(:id_of_store).map(&:id_of_store)
    
    2.upto(oo.last_row.to_i) do | line |

      if oo.cell(line, 'C').to_i.in?(current_stores)
        current_store = Store.find_by(id_of_store: oo.cell(line, 'C').to_i)
        current_store.update(active_commission: true )   if oo.cell(line, 'H') == 'Active' && current_store.active_commission == false

      else
        store_hash = {
          name: oo.cell(line, 'A'),
          id_of_store: oo.cell(line, 'C').to_i,
          description: oo.cell(line, 'D'),
          home_page_url: oo.cell(line, 'G'),
          commission: oo.cell(line, 'AA').split("%").first.to_f
        }

        if oo.cell(line, 'H') == 'Active'
          store_hash[:active_commission] = true
        else
          store_hash[:active_commission] = false
        end
        
        ['jpg','gif','png'].each do | ext |
          store_hash[:store_img] = 'http://merchant.linksynergy.com/fs/logo/lg_' + store_hash[:id_of_store].to_s + '.' + ext  
          break if Faraday.head(store_hash[:store_img]).status == 200
        end
        new_store = Store.new(store_hash)
        new_store.save
      end
    end
  end

  def self.load_store_list
    agent = Mechanize.new
    agent.log = Logger.new "#{Rails.root}/mechanize.log"
    
    login_page = agent.get "https://login.linkshare.com/sso/login?service=http://cli.linksynergy.com/cli/publisher/home.php"
    
    login_form = login_page.form

    user_field = login_form.field_with(name: "username") 
    password_field = login_form.field_with(name: "password")

    user_field.value = ENV["LS_USER"]
    password_field.value = ENV["LS_PASSWORD"]

    home_page = login_form.submit

    avertisers_page = home_page.link_with(text: 'My Advertisers').click
    report_page = avertisers_page.link_with(text: "\n                    Consolidated Advertiser Report").click
    file_link = report_page.link_with(text: "\n                    Export to .csv" ).click
    file_link.save!("#{Rails.root}/store.csv")
    logout_page = report_page.link_with(text: "Logout").click
  end

  def self.ls_coupon_id(store_id, link)
    a = link.split("&")
    b = a[1].split(".")
    c = a[2].split("=")
    store_id + c[1] + b[1] 
  end

  def self.title_shorten(title, length = 50)
    title.delete!('()') if title.include?('(')
    name = title.strip.downcase.gsub(/(\d{2}|\d{1})\/(\d{2}|\d{1})(-|.-.)(\d{2}|\d{1})\/(\d{2}|\d{1})/, "").gsub(/(sept|oct|nov|dec|jan|feb|mar|apr|may|jun|jul|aug)(\s*)(\d*|)(-|.-.|)/,"")
    name.gsub!(/[^a-z\s\&]/i,"")
    name_array = name.split(" ")
    items_to_remove = ['reg', 'all', 'orig', 'valid', 'code']

    items_to_remove.each do |remove|
      name_array.reject! { |item| item.include?(remove) }
    end
    name = name_array.uniq.join(" ")

    break_words = [' with ',' on a ','off ',' at ', ': ',' on ',' just ',' up to ',' - ',' for ',' w/ ', ' of ']
    break_words.each do | break_word |
      if break_word == ' at '
        @b_length = 100
        @pos = 1
      else
        @b_length = name.length
        @pos = (@b_length / 2).to_i
      end

      break if @b_length < length
      
      if name.index(break_word)
        find_on = name.split(break_word)
        if name.index(break_word) < @pos
          name = find_on[1]
        else
          name = find_on[0]
        end
      end
    end

    while name.length > length
      name_array = name.split(" ")
      name_array.pop
      name = name_array.join(" ")
    end
    
    #name.gsub!(/[[:punct:]]/,"")
    name_array = name.split(" ")
    items_to_remove = ['off', 'with']

    items_to_remove.each do |remove|
      name_array.reject! { |item| item.include?(remove) }
    end
    name = name_array.join(" ")
    #name.gsub!(/[\]\[!"#$%'()*+,.\/:;<=>?@\^_`{|}~-]/,"")
    name.gsub!(/#{Regexp.escape('\/')}/, "")
    name.titleize
  end
end