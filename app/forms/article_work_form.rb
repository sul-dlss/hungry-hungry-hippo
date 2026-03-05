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

  before_validation do
    # Force doi_option to be 'no' for all ArticleWorkForm instances
    # since we do not assign DOIs for Article works.
    self.doi_option = 'no'
  end

  validates :article_version_identification,
            presence: { message: I18n.t('validations.select.required') },
            on: :deposit

  # This is necessary for proper routing based on Work subclasses.
  def self.model_name
    ActiveModel::Name.new(self, nil, 'Work')
  end
end
