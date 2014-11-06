Fabricator(:admin) do
  username { Faker::Internet.user_name }
  fullname { Faker::Name.name }
  password { Faker::Internet.password(6) }
end
