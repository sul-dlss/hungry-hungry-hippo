# frozen_string_literal: true

# MIGRATION PLAN:
# 1. Generate collection.json and run import:collections task.
# 2. Run import:test_works task to test roundtripping of works.
# 3. Redeposit works in H2 that are in deposited or purl_reserved state.
# 4. Generate works.json and run import:works task.

# See https://github.com/sul-dlss/hungry-hungry-hippo/issues/1334
ETD_SUPPLEMENTS = [
  'druid:yy758rc6782',
  'druid:kw169cw9976',
  'druid:pv863tb2293',
  'druid:mq452hj0353',
  'druid:df776kg9323',
  'druid:zr954dr8814',
  'druid:dg109bb1678',
  'druid:bc883gb2542',
  'druid:vx261tg2712',
  'druid:bd057km5719',
  'druid:gh030zr1151'
].freeze

NO_MIGRATE_COLLECTIONS = [
  'druid:kj997mg1848', # Test collection
  'druid:qt691tp6756' # Test collection
].freeze

namespace :import do
  desc 'Import collections from json'
  # collections.json can be generated in H2 for some set of collections with:
  # collections = Collection.joins(:head).where.not('head.state': 'decommissioned')
  # collections_json = collections.map do |collection|
  #   collection.as_json(include: [:creator, :depositors, :reviewed_by, :managed_by]).tap do |collection_hash|
  #     # Map H2 license ids to URIs
  #     ['required_license', 'default_license'].each do |field|
  #       next if (license_id = collection_hash[field]).blank?
  #       collection_hash[field] = License.find(license_id).uri
  #     end
  #   end
  # end
  # File.write('collections.json', JSON.pretty_generate(collections_json))
  # Importing is idempotent, so you can run this multiple times.
  # It will raise an error if the collection cannot be roundtripped.
  task :collections, [:filename] => :environment do |_t, args|
    Rails.application.config.action_mailer.perform_deliveries = false

    collections_hash = JSON.parse(File.read(args[:filename] || 'collections.json'))
    collections_hash.each_with_index do |collection_hash, index|
      next unless collection_hash['druid']
      next if NO_MIGRATE_COLLECTIONS.include?(collection_hash['druid'])

      puts "Importing collection #{collection_hash['druid']} (#{index + 1}/#{collections_hash.length})"
      CollectionImporter.call(collection_hash:)
    end
  end

  desc 'Import works from json'
  # works.json can be generated in H2 for some set of works with:
  #   works = Work.joins(:head).where.not('head.state': 'decommissioned')
  #   works_json = works.map {|work| work.as_json(include: [:owner, :collection])}
  #   File.write('works.json', JSON.pretty_generate(works_json))
  # Importing is idempotent, so you can run this multiple times.
  # It will raise an error if the work cannot be roundtripped or the collection cannot be found.
  task :works, [:filename] => :environment do |_t, args|
    Rails.application.config.action_mailer.perform_deliveries = false

    works_hash = JSON.parse(File.read(args[:filename] || 'works.json'))
    works_hash.each_with_index do |work_hash, index|
      next unless work_hash['druid']

      next if ETD_SUPPLEMENTS.include?(work_hash['druid'])
      next if NO_MIGRATE_COLLECTIONS.include?(work_hash.dig('collection', 'druid'))
      # Cataloged works are not imported
      next if cocina_obj.identification.catalogLinks.present?

      puts "Importing work #{work_hash['druid']} (#{index + 1}/#{works_hash.length})"
      WorkImporter.call(work_hash:)
    end
  end

  desc 'Test import works from json'
  # works.json can be generated as shown above.
  # works_cocina.jsonl can be generated in H2 for some set of works with:
  #   File.open('works_cocina.jsonl', 'w') do |f|
  #     Work.joins(:head).where('head.state': ['deposited', 'purl_reserved']).find_each.with_index do |w, i|
  #       puts "#{w.druid} (#{i + 1})"
  #       c = CocinaGenerator::DROGenerator.generate_model(work_version: w.head, cocina_obj: Repository.find(w.druid))
  #       f.write("#{c.to_json}\n")
  #     end
  #   end
  # It will raise an error if the work cannot be roundtripped or the collection cannot be found.
  task :test_works, %i[cocina_filename] => :environment do |_t, args|
    File.foreach(args[:cocina_filename] || 'works_cocina.jsonl').with_index do |line, index|
      cocina_object = Cocina::Models.with_metadata(Cocina::Models.build(JSON.parse(line)), 'fakelock')

      next if ETD_SUPPLEMENTS.include?(cocina_object.externalIdentifier)
      next if NO_MIGRATE_COLLECTIONS.include?(Cocina::Parser.collection_druid_for(cocina_object:))
      next if cocina_obj.identification.catalogLinks.present?

      puts "Testing work #{cocina_object.externalIdentifier}} (#{index + 1})"

      work_form = Form::WorkMapper.call(cocina_object:, doi_assigned: false, agree_to_terms: true,
                                        version_description: '', collection:)
      content = Contents::Builder.call(cocina_object:, user: User.first)
      raise 'Roundtripping failed' unless WorkRoundtripper.call(work_form:, cocina_object:, content:)
    end
  end
end
