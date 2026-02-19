# frozen_string_literal: true

# Form for an Article work
class ArticleWorkForm < BaseWorkForm
  before_validation do
    # Removes blank keywords.
    # This has the effect of not requiring any keywords.
    self.keywords = keywords.reject(&:empty?)
  end

  before_validation do
    # Removes blank contributors.
    # This has the effect of not requiring any contributors.
    self.contributors = contributors.reject(&:empty?)
  end

  before_validation do
    # Removes blank contact emails.
    # This has the effect of not requiring any contact emails.
    self.contact_emails = contact_emails.reject(&:empty?)
  end

  # This is necessary for proper routing based on Work subclasses.
  def self.model_name
    ActiveModel::Name.new(self, nil, 'Work')
  end
end
