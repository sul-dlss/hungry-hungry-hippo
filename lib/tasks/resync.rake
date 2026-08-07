# frozen_string_literal: true

namespace :resync do
  desc 'Synchronize all works with their cocina objects'
  task works: :environment do
    Work.where.not(druid: nil).find_each do |work|
      cocina_object = Sdr::Repository.find(druid: work.druid)
      WorkModelSynchronizer.call(work:, cocina_object:, raise: false)
      puts "Synchronized #{work.druid}"
    rescue StandardError => e
      puts "Error synchronizing #{work.druid}: #{e.message}"
    end
  end
end
