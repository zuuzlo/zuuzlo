require 'spec_helper'
require "recursive_open_struct"

describe LsTransactions do
  describe "ls_activity" do
    let!(:user1) { Fabricate( :user, verified_email: true , cashback_id: 'user1') }
    let!(:store1) { Fabricate( :store, id_of_store: '12345' ) }
    
    before do
      user1.update_columns( cashback_id: 'user1' )
      responce_csv = File.new("#{Rails.root}/spec/support/test_files/valid_ls.csv")
      LsTransactions.stub(:open).and_return( responce_csv.read )
    end
    
    context "valid records found first time" do  

      it "adds record to Activity" do
        LsTransactions.ls_activity
        expect(Activity.count).to eq(1)
      end
    end

    context "valid update columns" do
      before do
        activty1 = Fabricate( :activity, user_id: user1.id, store_id: store1.id )
        LsTransactions.ls_activity
      end

      it "updates click column" do
        expect(Activity.find(1).clicks).to eq(4)
      end
      it "updates sales_cents" do
        expect(Activity.find(1).sales_cents).to eq(2200)
      end
      it "updates commission_cents" do
        expect(Activity.find(1).commission_cents).to eq(220)
      end
    end

    context "invalid update" do
      before do
        responce_csv = File.new("#{Rails.root}/spec/support/test_files/invalid_ls.csv")
        LsTransactions.stub(:open).and_return( responce_csv.read )
        LsTransactions.ls_activity
      end

      it "do not update or create Activity" do
        expect(Activity.count).to eq(0)
      end
    end
  end
  describe "last_update_ls" do
    context "Activity exists" do
      let!(:activity1) { Fabricate(:activity, updated_at: '2014-01-01 01:24:05') }
      let!(:activity2) { Fabricate(:activity, user_id: 2, updated_at: '2013-01-01 01:24:05') }
      before { LsTransactions.last_update_ls }

      it "return data of up_dated" do
        expect(Activity.order("updated_at DESC").first.updated_at.strftime("%Y%m%d")).to eq('20140101')
      end
    end
    context "Activity does not exist" do
      it "returns todays date minus 1 month" do
        time = DateTime.now - 1.month
        expect(LsTransactions.last_update_ls).to eq(time.strftime("%Y%m%d"))
      end
    end
  end

  describe "ls_update_coupons" do
    
    context "id is not existing coupon" do
      let!(:cat1) { Fabricate(:category, ls_id: 1 ) }
      let!(:cat2) { Fabricate(:category, ls_id: 2 ) }
      let!(:ctype1) { Fabricate(:ctype, ls_id: 1) }
      let!(:ctype2) { Fabricate(:ctype, ls_id: 2) }
      let!(:store1) { Fabricate(:store, id_of_store: 24572)}
      before do
        a = [ { "categories"=>{"category"=>[{"__content__"=>"Department Store", "id"=>"2"}, {"__content__"=>"Electronic Equipment", "id"=>"1"}]}, "promotiontypes"=>{"promotiontype"=>[{"__content__"=>"Free Shipping", "id"=>"1"}, {"__content__"=>"Percentage off", "id"=>"1"}]}, "offerdescription"=>"Weekend Sale! Save 8% ! Free Shipping on Most Items!", "offerstartdate"=>"2014-04-11", "offerenddate"=>"", "couponcode"=>"APRL8", "couponrestriction"=>"On Orders of $69", "clickurl"=>"http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&offerid=272227.10001315&type=3&subid=0", "impressionpixel"=>"http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&bids=272227.10001315&type=3&subid=0", "advertiserid"=>"24572", "advertisername"=>"Cascio Interstate Music", "network"=>{"__content__"=>"US Network", "id"=>"1"} } ]

        response = []
        a.each do | b |
          response << RecursiveOpenStruct.new( b, :recurse_over_arrays => true )
        end

        LinkshareAPI.stub_chain(:coupon_web_service,:all).and_return( response )
        LsTransactions.ls_update_coupons
      end
      it "creates new coupon" do
        expect(Coupon.count).to eq(1)
      end

      it "adds enddate if it does not exist" do
        expect(Coupon.first.end_date).to eq(Time.parse('2017-1-1'))
      end

      it "adds coupon to categories" do
        expect(Coupon.first.categories.count).to eq(2)
      end

      it "adds coupon to ctypes" do
        expect(Coupon.first.ctypes.count).to eq(2)
      end
    end
    
    context "id exists already" do
      let!(:coupon1) { Fabricate(:coupon, id_of_coupon: "24572310001315" ) }
      before do
        a = [ { "categories"=>{"category"=>[{"__content__"=>"Department Store", "id"=>"2"}, {"__content__"=>"Electronic Equipment", "id"=>"1"}]}, "promotiontypes"=>{"promotiontype"=>[{"__content__"=>"Free Shipping", "id"=>"1"}, {"__content__"=>"Percentage off", "id"=>"1"}]}, "offerdescription"=>"Weekend Sale! Save 8% ! Free Shipping on Most Items!", "offerstartdate"=>"2014-04-11", "offerenddate"=>"", "couponcode"=>"APRL8", "couponrestriction"=>"On Orders of $69", "clickurl"=>"http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&offerid=272227.10001315&type=3&subid=0", "impressionpixel"=>"http://ad.linksynergy.com/fs-bin/show?id=V8uMkWlCTes&bids=272227.10001315&type=3&subid=0", "advertiserid"=>"24572", "advertisername"=>"Cascio Interstate Music", "network"=>{"__content__"=>"US Network", "id"=>"1"} } ]
        
        response = []
        a.each do | b |
          response << RecursiveOpenStruct.new( b, :recurse_over_arrays => true )
        end

        LinkshareAPI.stub_chain(:coupon_web_service,:all).and_return( response )
        LsTransactions.ls_update_coupons
      end
      
      it "does not save coupon" do
        expect(Coupon.count).to eq(1)
      end
    end
  end

  describe "ls_coupon_id" do
    it "should return correct id" do
      expect(LsTransactions.ls_coupon_id("12345","http://click.linksynergy.com/fs-bin/click?id=V8uMkWlCTes&offerid=297133.3217&type=3&subid=0")).to eq("1234533217")
    end
  end

  describe "title_shorten" do
    it "return shorten title" do
      expect(LsTransactions.title_shorten("Get More Easter for Your Money with Great Deals & Free Shipping on Orders at Walmart.com!")).to eq("Great Deals & Free Shipping On Orders At Waltcom")
    end
  end

  describe "load_ls_stores" do
    before do
      stub_request(:any, /merchant.linksynergy.com/).
        with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Faraday v0.9.0'}).
        to_return(:status => 200, :body => "", :headers => {})

      test_csv = Roo::CSV.new("#{Rails.root}/spec/support/test_files/ls_test_store.csv", csv_options: {encoding: Encoding::ISO_8859_1})

      Roo::CSV.stub_chain(:new).and_return( test_csv )
    end

    context "new stores" do
      before { LsTransactions.load_ls_stores }
      it "creates five new stores" do
        expect(Store.all.count).to eq(5)
      end

      it "first store is active" do
        expect(Store.first.active_commission).to be_true
      end

      it "last store is not active" do
        expect(Store.last.active_commission).to be_false
      end

      it "finds image for store" do
        expect(Store.first.store_img).to eq("http://merchant.linksynergy.com/fs/logo/lg_35298.jpg")
      end
    end
    
    context "existing store no status change" do
      let!(:store1) { Fabricate(:store, id_of_store: 35298, active_commission: true )}
      before { LsTransactions.load_ls_stores }
      
      it "first store is the same" do
        expect(Store.first.name).to eq( store1.name )
      end

      it "five stores with 4 new 1 ths same" do
        expect(Store.all.count).to eq(5)
      end
    end
    
    context "existing store with status change" do
      let!(:store1) { Fabricate(:store, id_of_store: 35298, active_commission: false )}
      before { LsTransactions.load_ls_stores }
      
      it "changes status of store1" do
        expect(Store.first.active_commission).to be_true
      end

      it "first store is the same" do
        expect(Store.first.name).to eq( store1.name )
      end

      it "five stores with 4 new 1 ths same" do
        expect(Store.all.count).to eq(5)
      end
    end
  end
end