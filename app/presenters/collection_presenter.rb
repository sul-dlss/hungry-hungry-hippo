# frozen_string_literal: true

# Presents a collection
class CollectionPresenter < FormPresenter
  def initialize(collection:, collection_form:, version_status:)
    @collection = collection
    super(form: collection_form, version_status:)
  end

  attr_reader :collection

  def participants(role)
    collection.send(role).pluck(:email_address).join(', ')
  end
end
