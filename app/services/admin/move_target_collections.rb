# frozen_string_literal: true

module Admin
  # Returns a list of collections that the item can be moved to
  # based on the item's current settings and the collection settings
  # Items can't be moved if certain conflicts exist:
  # -- the item is embargoed but the collection is set for immediate release only
  # -- the depositor of the item chose not to get a DOI but the collection requires DOI assignment
  # -- the item has a license that is not allowed by the collection setting
  # -- the item is set for Stanford visibility but the collection requires world visibility
  class MoveTargetCollections
    def self.call(...)
      new(...).call
    end

    def initialize(work_form:)
      @work_form = work_form
    end

    def call # rubocop:disable Metrics/AbcSize
      collection = Collection.where.not(druid: work_form.collection_druid)
      if work_form.release_option == 'delay'
        # Collection cannot be immediate release only
        collection = collection.where.not(release_option: 'immediate')
      end
      if work_form.doi_option == 'no'
        # Collection cannot require DOI assignment
        collection = collection.where.not(doi_option: 'yes')
      end
      if work_form.access == 'stanford'
        # Collection cannot require world visibility
        collection = collection.where.not(access: 'world')
      end
      if work_form.license.present?
        # Collection cannot require a different license
        collection = collection.where.not(license_option: 'required')
                               .or(collection.required_license_option.where(license: work_form.license))
      end
      collection.order(:title)
    end

    private

    attr_reader :work_form
  end
end
