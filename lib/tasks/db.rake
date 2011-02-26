namespace :db do
  desc 'Seed the current Rails.env database from db/seeds.rb'
  namespace :seed do
    seeders = [
      :magazines
    ]
    seeders.each do |seeder|
      desc "Seed #{seeder}"
      task seeder => :environment do
        puts "Seeding '#{seeder}' for the '#{Rails.env}' database..."
        require "db/seeds/#{seeder}"
      end
    end

  end
end
