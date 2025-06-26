# frozen_string_literal: true

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
  'druid:qt691tp6756',
  # Version mismatches
  'druid:xt984kp6950',
  'druid:px088wv9627',
  # Already migrated to H3
  'druid:db160pg5444',
  # Not migrating
  'druid:sy932cg0335'
].freeze

# These collections will be imported, but will not be editable.
SKIP_ROUNDTRIP_COLLECTIONS = [
  'druid:md001qd8892',
  'druid:xf974wp1364',
  'druid:db700wz4340'
].freeze

namespace :import do
  desc 'Import collections from json'
  # See https://github.com/sul-dlss/hungry-hungry-hippo/wiki/Migration-plan for generating collections.json
  # Importing is idempotent, so you can run this multiple times.
  # It will raise an error if the collection cannot be roundtripped.
  # Skipping roundtripping is useful for local testing, when collections are needed for test_works task.
  task :collections, %i[skip_roundtrip filename] => :environment do |_t, args|
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
      skip_roundtrip = args[:skip_roundtrip] == 'true' || SKIP_ROUNDTRIP_COLLECTIONS.include?(druid)
      CollectionImporter.call(collection_hash:, cocina_object:,
                              skip_roundtrip:)
    end
  end

  desc 'Import works from json'
  # See https://github.com/sul-dlss/hungry-hungry-hippo/wiki/Migration-plan for generating works.json
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
  # See https://github.com/sul-dlss/hungry-hungry-hippo/wiki/Migration-plan for generating collections_cocina.jsonl
  # It will raise an error if the collection cannot be roundtripped.
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
  # rubocop:disable Layout/LineLength
  # IMPORTANT: Enable feature flags in H2.
  # For example: SETTINGS__MERGE_STANFORD_AND_ORGANIZATION=true SETTINGS__DOCUMENT_TYPE=true SETTINGS__NO_CITATION_STATUS_NOTE=true bin/rails c -e p
  # See https://github.com/sul-dlss/hungry-hungry-hippo/wiki/Migration-plan for generating works_cocina.jsonl
  # It will raise an error if the work cannot be roundtripped or the collection cannot be found.
  # rubocop:enable Layout/LineLength
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
