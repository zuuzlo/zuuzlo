class Admin::StoresController < AdminController

  def index
    @store_count = Store.count
    @stores = Store.all
  end
  
  def get_ls_stores
    LsTransactions.load_store_list
    load_stores(LsTransactions.load_ls_stores)
  end

  def get_pj_stores
    load_stores(PjTransactions.pj_stores_get)
  end

  def get_cj_stores
    load_stores(CjTransactions.load_cj_stores)
  end

  def load_stores(load_store_command)
    count_start = Store.count
    load_store_command
    count_finish = Store.count

    if count_finish > count_start
      flash[:success] = "Loaded #{count_finish - count_start} LS stores."
    else
      flash[:danger] = "No new LS stores added"
    end

    redirect_to admin_stores_path
  end
end