def set_current_user(user=nil)
  if user.nil?
    user = Fabricate(:user)
  end

  session[:userid] = user.id
end

def set_current_admin_user(admin=nil)
  if admin.nil?
    admin = Fabricate(:admin)
  end

  session[:adminid] = admin.id
end

def get_current_user
  session[:userid] ? User.find_by(id: session[:userid]) : nil
end

def clear_current_user
  session[:userid] = nil
end

def clear_current_admin_user
  session[:adminid] = nil
end

def sign_in_user(username)
  visit signin_path
  fill_in "Your Name", with: username
  click_button "Sign In"
end

def sign_in_admin(admin_user)
  visit admin_signin_path
  fill_in "Username", with: admin_user.username
  fill_in "Password", with: admin_user.password
  click_button "Admin Sign In"
end


def expect_success_flash
  expect(flash[:success]).not_to be_blank
end

def expect_danger_flash
  expect(flash[:danger]).not_to be_blank
end

