# frozen_string_literal: true

module Admin
  # Validates that a collection is targetable for a work to be moved into it.
  class MoveFormValidator < ActiveModel::Validator
    def validate(record)
      @record = record

      validate_collection_druid_present
      return if errors?

      validate_collection_found
      return if errors?

      validate_not_already_part_of_collection
      return if errors?

      # the work is embargoed but the collection is set for immediate release only
      validate_release_option
      # the depositor of the item chose not to get a DOI but the collection requires DOI assignment
      validate_doi_option
      # the work has a license that is not allowed by the collection setting
      validate_license
      # the work is set for Stanford visibility but the collection requires world visibility
      validate_access
    end

    private

    def errors?
      errors[:collection_druid].present?
    end

    delegate :collection, :errors, :work_form, :collection_druid, to: :@record

    def validate_collection_druid_present
      errors.add(:collection_druid, 'can\'t be blank') if collection_druid.blank?
    end

    def validate_collection_found
      errors.add(:collection_druid, 'not found') if collection.nil?
    end

    def validate_not_already_part_of_collection
      return unless collection_druid == work_form.collection_druid

      errors.add(:collection_druid,
                 'already part of this collection')
    end

    def validate_release_option
      return unless work_form.release_option == 'delay' && collection.release_option == 'immediate'

      errors.add(:collection_druid,
                 'work is embargoed but collection is immediate release only')
    end

    def validate_doi_option
      return unless work_form.doi_option == 'no' && collection.doi_option == 'yes'

      errors.add(:collection_druid,
                 'work is not set for DOI assignment but collection requires DOI assignment')
    end

    def validate_license
      return unless collection.license_option == 'required' && work_form.license != collection.license

      errors.add(:collection_druid, 'work has a license that is not allowed by the collection')
    end

    def validate_access
      return unless collection.access == 'world' && work_form.access == 'stanford'

      errors.add(:collection_druid,
                 'work is set for Stanford visibility but the collection requires world visibility')
    end
  end
end
