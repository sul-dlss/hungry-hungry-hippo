# frozen_string_literal: true

# MIGRATION PLAN:
# 1. Run import:collections task to import collections.
# 2. Run import:test_works task to test roundtripping of works.
# 3. Redeposit collections in H2 that are in deposited state.
# 4. Generate collection.json and run import:collections task.
# 5. Redeposit works in H2 that are in deposited or purl_reserved state and for which there is not a version mismatch.
# * Should we allow some version mismatches, e.g., for document types or lifted embargoes?
# * MERGE_STANFORD_AND_ORGANIZATION and DOCUMENT_TYPE should be enabled in H2.
# 6. Generate works.json and run import:works task.

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
  # Decommissioned collections
  'druid:mk208sd1753',
  'druid:st550yz5813',
  'druid:nq513cj3798',
  'druid:zv008fs8442',
  'druid:jg194rw0041',
  'druid:wc394gy9058',
  'druid:kj997mg1848',
  'druid:kv708vv4482',
  'druid:pn977yk8447',
  'druid:tz264ym9581',
  'druid:zm077xw4254',
  'druid:qx111hs9166',
  # Test collection
  'druid:qt691tp6756'
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
    Rails.application.config.cache_store = :file_store, 'tmp/cache/' if Rails.env.development?

    collections_hash = JSON.parse(File.read(args[:filename] || 'collections.json'))
    collections_hash.each_with_index do |collection_hash, index|
      druid = collection_hash['druid']
      next if druid.blank?
      next if NO_MIGRATE_COLLECTIONS.include?(druid)

      puts "Importing collection #{druid} (#{index + 1}/#{collections_hash.length})"

      cocina_object = if Rails.env.development?
                        Rails.cache.fetch(druid, expires_in: 1.year) do
                          Sdr::Repository.find(druid:)
                        end
                      else
                        Sdr::Repository.find(druid:)
                      end
      CollectionImporter.call(collection_hash:, cocina_object:)
    end
  end

  desc 'Import works from json'
  # works.json can be generated in H2 for some set of works with:
  #   works = Work.joins(:head).where('head.state': ['deposited', 'purl_reserved'])
  #   works_json = works.map {|work| work.as_json(include: [:owner, :collection])}
  #   File.write('works.json', JSON.pretty_generate(works_json))
  # Importing is idempotent, so you can run this multiple times.
  # It will raise an error if the work cannot be roundtripped or the collection cannot be found.
  task :works, [:filename] => :environment do |_t, args|
    Rails.application.config.action_mailer.perform_deliveries = false
    Rails.application.config.cache_store = :file_store, 'tmp/cache/' if Rails.env.development?

    works_hash = JSON.parse(File.read(args[:filename] || 'works.json'))
    works_hash.each_with_index do |work_hash, index|
      druid = work_hash['druid']
      next if druid.blank?

      next if ETD_SUPPLEMENTS.include?(druid)
      next if NO_MIGRATE_COLLECTIONS.include?(work_hash.dig('collection', 'druid'))

      cocina_object = if Rails.env.development?
                        Rails.cache.fetch(druid, expires_in: 1.year) do
                          Sdr::Repository.find(druid:)
                        end
                      else
                        Sdr::Repository.find(druid:)
                      end
      # Cataloged works are not imported
      next if cocina_object.identification.catalogLinks.present?

      puts "Importing work #{druid} (#{index + 1}/#{works_hash.length})"
      WorkImporter.call(work_hash:, cocina_object:)
    end
  end

  desc 'Test import collections from json'
  # collections_cocina.jsonl can be generated in H2 for some set of collections with:
  #   File.open('collections_cocina.jsonl', 'w') do |f|
  #     Collection.joins(:head).where('head.state': ['deposited']).find_each.with_index do |coll, i|
  #       puts "#{coll.druid} (#{i + 1})"
  #       c = CocinaGenerator::CollectionGenerator.generate_model(collection_version: coll.head)
  #       f.write("#{c.to_json}\n")
  #     end
  #   end
  # It will raise an error if the work cannot be roundtripped.
  task :test_collections, %i[cocina_filename] => :environment do |_t, args|
    File.foreach(args[:cocina_filename] || 'collections_cocina.jsonl').with_index do |line, index|
      cocina_object = Cocina::Models.with_metadata(Cocina::Models.build(JSON.parse(line)), 'fakelock')

      next if NO_MIGRATE_COLLECTIONS.include?(cocina_object.externalIdentifier)

      puts "Testing collection #{cocina_object.externalIdentifier}} (#{index + 1})"

      collection_form = Form::CollectionMapper.call(cocina_object:, collection: Collection.new)
      raise 'Roundtripping failed' unless CollectionRoundtripper.call(collection_form:, cocina_object:)
    end
  end

  desc 'Test import works from json'
  # IMPORTANT: Enable merge_stanford_and_organization and document_type feature flags in H2.
  # For example: SETTINGS__MERGE_STANFORD_AND_ORGANIZATION=true SETTINGS__DOCUMENT_TYPE=true bin/rails c -e p
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
    Parallel.each_with_index(File.open(args[:cocina_filename] || 'works_cocina.jsonl'),
                             in_processes: 6) do |line, index|
      # File.foreach(args[:cocina_filename] || 'works_cocina.jsonl').with_index do |line, index|
      cocina_object = Cocina::Models.with_metadata(Cocina::Models.build(JSON.parse(line)), 'fakelock')

      next if ETD_SUPPLEMENTS.include?(cocina_object.externalIdentifier)

      collection_druid = Cocina::Parser.collection_druid_for(cocina_object:)
      next if NO_MIGRATE_COLLECTIONS.include?(collection_druid)
      next if cocina_object.identification.catalogLinks.present?

      puts "Testing work #{cocina_object.externalIdentifier}} (#{index + 1})"

      collection = Collection.find_by!(druid: collection_druid)
      work_form = Form::WorkMapper.call(cocina_object:, doi_assigned: false, agree_to_terms: true,
                                        version_description: '', collection:)
      content = Contents::Builder.call(cocina_object:, user: User.first)
      raise 'Roundtripping failed' unless WorkRoundtripper.call(work_form:, cocina_object:, content:)
    end
  end
end
