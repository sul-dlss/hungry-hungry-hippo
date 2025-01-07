class UpdateCollections < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :release_option, :string
    add_column :collections, :release_duration, :string
    add_column :collections, :access, :string
    add_column :collections, :doi_option, :string, default: 'yes'
    add_column :collections, :license_option, :string, default: 'required', null: false
    add_column :collections, :license, :string
    add_column :collections, :custom_rights_statement_option, :string
    add_column :collections, :provided_custom_rights_statement, :string
    add_column :collections, :custom_rights_statement_custom_instructions, :string
    add_column :collections, :email_when_participants_changed, :boolean, default: true, null: false
    add_column :collections, :email_depositors_status_changed, :boolean, default: true, null: false
    add_column :collections, :review_enabled, :boolean, default: false, null: false
  end
end
