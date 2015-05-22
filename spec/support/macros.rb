def set_current_user(user=nil)
  sign_in (user || Fabricate(:user))
end

def current_user
  User.find(session[:user_id])
end

def clear_current_user
  session[:user_id] = nil
end

def set_admin_user(a_user=nil)
  user = a_user || Fabricate(:user)
  set_current_user(user)
  user.admin = true
  user.save
end