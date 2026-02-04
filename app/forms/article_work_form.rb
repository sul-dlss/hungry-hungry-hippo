class ArticleWorkForm < BaseWorkForm
  before_validation do
    # Removes blank keywords.
    # This has the effect of not requiring any keywords.
    # blank_keywords = keywords.select(&:empty?)
    self.keywords = keywords.reject(&:empty?)
  end

  before_validation do
    # Removes blank contact emails.
    # This has the effect of not requiring any contact emails.
    self.contact_emails = contact_emails.reject(&:empty?)
  end

  attribute :doi_option, :string, default: 'no'

  attribute :work_type, :string, default: 'Text'
  attribute :work_subtypes, array: true, default: -> { ['Article'] }
end
