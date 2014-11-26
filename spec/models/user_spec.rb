require 'spec_helper'

describe User do
  before { kirk1 = Fabricate(:user) }
  it { should validate_presence_of(:email) }
  it { should_not allow_value("fads").for(:email) } 
  it { should allow_value("KJa.aa12@yah.com").for(:email) }
  it { should validate_presence_of(:full_name) }
  it { should validate_presence_of(:password) }
  #password_confirmation 
  it { should_not allow_value('12345').for(:password) }
  it { should allow_value('123456').for (:password) }  
  it { should validate_uniqueness_of(:email) }

  it_behaves_like "tokenable" do
    let(:object) { Fabricate(:user) }
  end

  it "should generate a token" do
    kirk = Fabricate(:user)
    expect(kirk.token).to be_present
  end
end
