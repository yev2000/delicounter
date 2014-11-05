def set_current_user(user=nil)
  if user.nil?
    user = Fabricate(:user)
  end

  session[:userid] = user.id
end

def get_current_user
  session[:userid] ? User.find_by(id: session[:userid]) : nil
end

def clear_current_user
  session[:userid] = nil
end

def sign_in_user(user)
  visit sign_in_path
  fill_in "User Name", with: user.username
  click_button "Sign In"
end

def expect_success_flash
  expect(flash[:success]).not_to be_blank
end

def expect_error_flash
  expect(flash[:danger]).not_to be_blank
end

