# frozen_string_literal: true

namespace :import do
  desc 'Import collections from json'
  # collections.json can be generated in H2 for some set of collections with:
  #   collections_json = collections.map {|collection| collection.as_json(include: [:creator, :depositors,
  #     :reviewed_by, :managed_by])}
  #   File.write('collections.json', JSON.pretty_generate(collections_json))
  # Importing is idempotent, so you can run this multiple times.
  # It will raise an error if the collection cannot be roundtripped.
  task :collections, [:filename] => :environment do |_t, args|
    Rails.application.config.action_mailer.perform_deliveries = false

    collections_hash = JSON.parse(File.read(args[:filename] || 'collections.json'))
    collections_hash.each do |collection_hash|
      next unless collection_hash['druid']

      puts "Importing collection #{collection_hash['druid']}"
      CollectionImporter.call(collection_hash:)
    end
  end
end
