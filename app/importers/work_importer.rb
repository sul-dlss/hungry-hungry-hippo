# frozen_string_literal: true

# Imports a work from a JSON export from H2.
class WorkImporter
  def self.call(...)
    new(...).call
  end

  def initialize(work_hash:, cocina_object:)
    @work_hash = work_hash
    @cocina_object = cocina_object
  end

  def call
    ::Work.transaction do
      unless WorkRoundtripper.call(work_form:, cocina_object:, content:)
        raise ImportError, "Work #{druid} cannot be roundtripped"
      end

      create_work
      add_project_tags
    end
  end

  private

  attr_reader :work_hash, :cocina_object

  # rubocop:disable Metrics/AbcSize
  def create_work
    ::Work.find_or_create_by!(druid:) do |work|
      work.user = user
      work.title = Cocina::Parser.title_for(cocina_object:)
      work.object_updated_at = cocina_object.modified
      work.version = Cocina::Parser.version_for(cocina_object:)
      work.collection = collection
      work.last_deposited_at = work_hash['head']['published_at']
      work.created_at = work_hash['created_at']
    end
  end
  # rubocop:enable Metrics/AbcSize

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

  def add_project_tags
    Dor::Services::Client.object(druid).administrative_tags.create(tags: ['Project : H3'])
  end
end
