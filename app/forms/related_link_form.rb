# frozen_string_literal: true

# Form for a related link
class RelatedLinkForm < ApplicationForm
  attribute :text, :string
  validates :text,
            presence: { message: I18n.t('collection_form.fields.related_links.text.validations.blank') },
            if: ->(link) { link.url.present? }
  attribute :url, :string
  validates :url,
            url: { message: I18n.t('collection_form.fields.related_links.url.validations.invalid') },
            unless: ->(link) { link.url.blank? && link.text.blank? }
end
