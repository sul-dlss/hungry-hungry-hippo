class CustomRightsStatementDefault < ActiveRecord::Migration[8.0]
  def change
    rename_column :collections, :custom_rights_statement_custom_instructions, :custom_rights_statement_instructions
  end
end
