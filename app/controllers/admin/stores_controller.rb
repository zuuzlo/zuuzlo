class Admin::StoresController < AdminController

  def get_ls_stores
    count_start = Store.count
    LsTransactions.load_store_list
    LsTransactions.load_ls_stores
    count_finish = Store.count

    if count_finish > count_start
      flash[:success] = "Loaded #{count_finish - count_start} LS stores."
    else
      flash[:danger] = "No new LS stores added"
    end

    redirect_to admin_stores_path
  end

  def get_pj_stores
    count_start = Store.count
    PjTransactions.pj_stores_get
    count_finish = Store.count

    if count_finish > count_start
      flash[:success] = "Loaded #{count_finish - count_start} LS stores."
    else
      flash[:danger] = "No new LS stores added"
    end

    redirect_to admin_stores_path
  end
end