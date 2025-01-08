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
    collections_json = JSON.parse(File.read(args[:filename] || 'collections.json'))
    collections_json.each do |collection_json|
      next unless collection_json['druid']

      puts "Importing collection #{collection_json['druid']}"
      Importers::Collection.call(collection_json:)
    end
  end
end
