Fabricator(:coupon) do
  id_of_coupon { Faker::Number.number(5) }
  title { Faker::Lorem.sentence(word_count = 3) }
  description { Faker::Lorem.sentence(word_count = 5) }
  start_date { Time.now }
  end_date { Time.now + 3.day }
  code { Faker::Lorem.word }
  restriction { Faker::Lorem.sentence( word_count = 5 ) }
  link { Faker::Internet.url }
end