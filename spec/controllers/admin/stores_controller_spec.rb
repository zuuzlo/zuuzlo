require 'spec_helper'

describe Admin::StoresController do
  describe "GET get_ls_stores" do
    context "admin credentials" do
      before { set_admin_user }
      context "with new stores" do
        before do
          stub_request(:any, /merchant.linksynergy.com/).
            with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Faraday v0.9.0'}).
            to_return(:status => 200, :body => "", :headers => {})

          test_csv = Roo::CSV.new("#{Rails.root}/spec/support/test_files/ls_test_store.csv", csv_options: {encoding: Encoding::ISO_8859_1})

          Roo::CSV.stub_chain(:new).and_return( test_csv )

          stub_request(:any, /login.linkshare.com/).
            with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Faraday v0.9.0'}).
            to_return(:status => 200, :body => "", :headers => {})

        end

        it "flashes success and new numbers of stores" do
          get :get_ls_stores
          expect(flash[:success]).to be_present
        end
      end
    end
  end
end