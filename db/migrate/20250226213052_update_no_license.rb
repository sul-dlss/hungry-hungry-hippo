# frozen_string_literal: true

class UpdateNoLicense < ActiveRecord::Migration[8.0]
  def change
    Collection.where(license: '').update_all(license: License::NO_LICENSE_ID)
  end
end
