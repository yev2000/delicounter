Fabricator(:question) do
  title { Faker::Lorem.words(4).join(" ") }
  ## body { Faker::Lorem.paragraph(2) }
  body { Faker::Hacker.say_something_smart + " " + Faker::Hacker.say_something_smart + " " + Faker::Hacker.say_something_smart }
  claimed { false }
end