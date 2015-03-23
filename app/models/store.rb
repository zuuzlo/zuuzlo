class Store < ActiveRecord::Base

  validates :name, presence: true
  validates :id_of_store, presence: true, uniqueness: true
  has_many :coupons, -> { order "end_date ASC" }
  has_and_belongs_to_many :users

  has_many :activities
  
  extend FriendlyId
  friendly_id :name, use: :slugged

  def self.with_coupons
    Store.joins(:coupons).where(["end_date >= :time ", { :time => DateTime.current }]).uniq
  end

  def self.load_stores
    oo = Roo::Excel.new("#{Rails.root}/lsstores.xls")
    oo.default_sheet = oo.sheets.first
    2.upto(177) do | line |
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