# frozen_string_literal: true

# Form for an Article work
class ArticleWorkForm < BaseWorkForm
  include FilesRequired

  before_validation do
    # Removes blank keywords.
    # This has the effect of not requiring any keywords.
    self.keywords = keywords.reject(&:empty?)
  end

  before_validation do
    # Removes blank contact emails.
    # This has the effect of not requiring any contact emails.
    self.contact_emails = contact_emails.reject(&:empty?)
  end

  validates :article_version_identification,
            presence: { message: I18n.t('works.edit.fields.version_identification.validation') },
            on: :deposit

  # This is necessary for proper routing based on Work subclasses.
  def self.model_name
    ActiveModel::Name.new(self, nil, 'Work')
  end
end
