# frozen_string_literal: true

# Imports a work from a JSON export from H2.
class WorkImporter
  def self.call(...)
    new(...).call
  end

  def initialize(work_hash:)
    @work_hash = work_hash
  end

  def call
    check_for_folio_id!
    check_apo!

    ::Work.transaction do
      unless WorkRoundtripper.call(work_form:, cocina_object:, content:)
        raise HydrusImportError if hydrus?

        raise ImportError, "Work #{druid} cannot be roundtripped"
      end

      work
    end
  end

  private

  attr_reader :work_hash

  def work
    @work ||= ::Work.find_or_create_by!(druid:) do |work|
      work.user = user
      work.title = Cocina::Parser.title_for(cocina_object:)
      work.object_updated_at = cocina_object.modified
      work.version = Cocina::Parser.version_for(cocina_object:)
      work.collection = collection
    end
  end

  def cocina_object
    # TODO: Remove the caching
    @cocina_object ||= Rails.cache.fetch(druid, expires_in: 1.year) do
      Sdr::Repository.find(druid:)
    end
  end

  def collection
    @collection ||= Collection.find_by!(druid: Cocina::Parser.collection_druid_for(cocina_object:))
  end

  def work_form
    @work_form ||= Form::WorkMapper.call(cocina_object:, doi_assigned: false, agree_to_terms: true,
                                         version_description: '', collection:)
  end

  def user
    @user ||= UserImporter.call(user_json: work_hash['owner'])
  end

  def content
    @content ||= Contents::Builder.call(cocina_object:, user:)
  end

  def druid
    work_hash['druid']
  end

  def check_apo!
    raise UnexpectedApoImportError if cocina_object.administrative.hasAdminPolicy != Settings.apo
  end

  def check_for_folio_id!
    raise CatalogedImportError if cocina_object.identification.catalogLinks.present?
  end

  def hydrus?
    cocina_object.identification.sourceId.starts_with?('Hydrus:item') ||
      cocina_object.description.note.any? { |note| note.type == 'summary' }
  end
end
