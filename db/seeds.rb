# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

raise "Seeds are for development only" unless Rails.env.development?

user = User.find_or_create_by!(email_address: Authentication::DEV_REMOTE_USER) do |user|
  user.first_name = Authentication::DEV_FIRST_NAME
  user.name = Authentication::DEV_NAME
end

Collection.find_or_create_by!(title: 'Test Collection') do |collection|
  collection.user = user
  collection.druid = 'druid:cd234fg5678'
end
