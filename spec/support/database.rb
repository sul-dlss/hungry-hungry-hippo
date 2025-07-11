# frozen_string_literal: true

def truncate_db
  ActiveRecord::Base.connection.disable_referential_integrity do
    tables = ActiveRecord::Base.connection.tables - %w[ar_internal_metadata schema_migrations]
    tables.each do |table|
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} CASCADE;")
    end
  end
end
