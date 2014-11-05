Fabricator(:question) do
  title { Faker::Lorem.words(4).join(" ") }
  body { Faker::Lorem.paragraph(2) }
  claimed { false }
end