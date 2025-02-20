class SortContentFilesBasenameNumerically < ActiveRecord::Migration[8.0]
  def up
    execute "CREATE COLLATION numeric (provider = icu, locale = 'en-u-kn')"
  end

  def down
    execute "DROP COLLATION numeric"
  end
end
