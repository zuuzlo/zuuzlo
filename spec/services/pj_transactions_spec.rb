require 'spec_helper'
require "recursive_open_struct"

describe PjTransactions do
  describe "pj_stores_get" do
=begin
    before do
      a = [ { "id"=>"4055", "name"=>"World Class Ink Supply, Inc.", "description"=>"world class ink description", "logo"=>"http://media.pepperjamnetwork.com/programs/logos/4055", "prohibited_states"=>"", "mobile_tracking"=>"N/A", "category"=>[{"id"=>"2", "name"=>"Computer & Electronics "}, {"id"=>"7", "name"=>"Accessories"}, {"id"=>"49", "name"=>"Shops/Malls"}], "address1"=>"47 Cooper Street", "address2"=>"Rear Unit", "city"=>"Woodbury", "state_code"=>"NJ", "zip_code"=>"08096", "country_code"=>"US", "phone"=>"609-556-5338", "website"=>"http://www.worldclassink.com", "contact_name"=>"Scott Hoffman", "email"=>"info@worldclassink.com", "currency"=>"USD", "status"=>"joined", "join_date"=>"2013-08-10", "cookie_duration"=>"1080", "percentage_payout"=>"10.000", "flat_payout"=>nil } ]
      # { "id"=>"4669", "name"=>"US Pets", "description"=>"US pets", "logo"=>"http://media.pepperjamnetwork.com/programs/logos/4669", "prohibited_states"=>"", "mobile_tracking"=>"N/A", "category"=>[{"id"=>"7", "name"=>"Accessories"}, {"id"=>"35", "name"=>"Home & Garden"}, {"id"=>"49", "name"=>"Shops/Malls"}], "address1"=>"1157 Sawgrass Corporate Parkway", "address2"=>"", "city"=>"Sunrise", "state_code"=>"FL", "zip_code"=>"33323", "country_code"=>"US","phone"=>"888-415-7387", "website"=>"http://www.uspets.com", "contact_name"=>"Brandon Edwards", "email"=>"Brandon@uspets.com", "currency"=>"USD", "status"=>"joined", "join_date"=>"2013-08-10", "cookie_duration"=>"1080", "percentage_payout"=>"10.000", "flat_payout"=> nil }, { "id"=>"5027", "name"=>"Baseball Express", "description"=>"Baseball Express description", "logo"=>"http://media.pepperjamnetwork.com/programs/logos/5027", "prohibited_states"=>"", "mobile_tracking"=>"N/A", "category"=>[{"id"=>"19", "name"=>"Clothing/Apparel "}, {"id"=>"49", "name"=>"Shops/Malls"}, {"id"=>"51", "name"=>"Sports & Fitness"}], "address1"=>"5750 Northwest Parkway", "address2"=>"Suite 100", "city"=>"San Antonio", "state_code"=>"TX", "zip_code"=>"78249", "country_code"=>"US", "phone"=>"210-348-7000", "website"=>"http://www.baseballexpress.com", "contact_name"=>"Kelly Bina", "email"=>"kelly.bina@teamexpress.com", "currency"=>"USD", "status"=>"joined", "join_date"=>"2013-08-11", "cookie_duration"=>"720", "percentage_payout"=>"10.000", "flat_payout"=>nil } ],
      
      response = []
      
      require 'pry'; binding.pry
      a.each do | b |
        response << RecursiveOpenStruct.new( b )
      end

      EBayEnterpriseAffiliateNetwork::APIResource.stub(:get).and_return( response )
      PjTransactions.pj_stores_get  
    end
=end
    context "store doesn't exist" do
      before do
        EBayEnterpriseAffiliateNetwork.api_version = 400
        PjTransactions.pj_stores_get
      end

      it "id_of_store is a integer" do
        expect(Store.first.id_of_store).to be_a Integer
      end

      it "commission is a fixed number" do
        expect(Store.first.commission).to be_a Float
      end

      it "active_commission is true" do
        expect(Store.first.active_commission).to be_true
      end

      it "adds new Stores " do
        expect(Store.count).to eq(1)
      end
    end

    context "store exists" do

      it "doesn't add store if exists" do
        store1 = Fabricate( :store, id_of_store: 4055 )
        EBayEnterpriseAffiliateNetwork.api_version = 400
        PjTransactions.pj_stores_get
        expect(Store.count).to eq(1)
      end

      it "change active commission if status is joined" do
        store1 = Fabricate( :store, id_of_store: 4055, active_commission: false )
        EBayEnterpriseAffiliateNetwork.api_version = 400
        PjTransactions.pj_stores_get
        expect(Store.last.active_commission).to be_true
      end
    end
  end

  describe "#pj_update_coupons" do
    let!(:category1) { Fabricate(:category, ls_id: 5) }
    let!(:type1) { Fabricate(:ctype, ls_id: 7) }
    let!(:type2) { Fabricate(:ctype, ls_id: 5) }
    
    before do
      EBayEnterpriseAffiliateNetwork.api_version = 3
      PjTransactions.pj_update_coupons
    end

    context "id is not existing coupon" do
      it "creates new coupons" do
        expect(Coupon.count).to eq(3)
      end

      it "adds enddate if it does not exist" do
        expect(Coupon.last.end_date).to eq(Time.parse('2017-1-1'))
      end

      it "adds enddate if it exits" do
        expect(Coupon.first.end_date).to eq(Time.parse('2014-06-01 00:00:00'))
      end

      it "adds coupon categories" do
        expect(Coupon.first.categories).to eq([ category1 ])
      end

      it "adds coupon to ctypes" do
        expect(Coupon.first.ctypes).to eq([ type1, type2 ])
      end
    end
  end

  describe "#pj_coupon_code_valid" do
    context "valid codes" do
      it "returns true" do
        code = PjTransactions.pj_coupon_code_valid("DSC200901")
        expect(code).to be_true
      end
    end
    context "invalid code" do
      it "returns false for N/A" do
        code = PjTransactions.pj_coupon_code_valid("N/A")
        expect(code).to be_false
      end

      it "returns false for Code Not Needed" do
        code = PjTransactions.pj_coupon_code_valid("Code Not Needed")
        expect(code).to be_false
      end

      it "returns false for Code Not Needed" do
        code = PjTransactions.pj_coupon_code_valid("No Code Needed")
        expect(code).to be_false
      end
    end
  end

  describe "#pj_find_category" do
    it "returns 1,5,6 array for Car apparel for a beauty look" do
      categories = PjTransactions.pj_find_category("Car apparel for a beauty look.")
      expect(categories).to eq [1,5,6]
    end

    it "returns empty array for no matches" do
      categories = PjTransactions.pj_find_category("For no matches.")
      expect(categories).to eq []
    end

    it "returns 28 for NFL." do
      categories = PjTransactions.pj_find_category("NFL.")
      expect(categories).to eq [28]
    end
  end

  describe "#pj_find_type" do
    it "returns 1,5,6 array for General promotion $10 off for free trial" do
      types = PjTransactions.pj_find_type("General promotion $10 off for free trial")
      expect(types).to eq [1,5,6]
    end

    it "returns empty array for no matches" do
      types = PjTransactions.pj_find_type("For no matches.")
      expect(types).to eq []
    end

    it "returns 2 for Buy one get one NFL department." do
      types = PjTransactions.pj_find_type("Buy one get one NFL department.")
      expect(types).to eq [2]
    end
  end

  describe "#pj_activity" do

    context "valid records found first time" do
      it "adds record to Activity" 
    end

    context "valid update columns" do
      it "updates click column"
      it "updates sales_cents"
      it "updates commission_cents"
    end
  end
end