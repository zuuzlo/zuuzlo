Fabricator(:store) do
  name { Faker::Lorem.word }
  id_of_store { Random.new.rand(1_000_000..10_000_000-1) }
  store_img { Faker::Internet.url }
end