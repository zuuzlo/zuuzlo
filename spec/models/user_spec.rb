require 'spec_helper'

describe User do
  it { should have_many(:activities) }
  it { should have_and_belong_to_many(:coupons) }
  it { should have_and_belong_to_many(:stores) }
  it "should generate a cashback_id" do
    kirk = Fabricate(:user)
    expect(kirk.cashback_id).to be_present
  end
end
