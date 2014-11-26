# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :activity do
    click_id "MyString"
    store_id ""
    clicks 1
    sales_cents 1
    commission_cents 1
  end
end
