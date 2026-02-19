# frozen_string_literal: true

# Form for a GitHub repository work
class GithubRepositoryWorkForm < CompleteBaseWorkForm
  # This is necessary for proper routing based on Work subclasses.
  def self.model_name
    ActiveModel::Name.new(self, nil, 'Work')
  end
end
