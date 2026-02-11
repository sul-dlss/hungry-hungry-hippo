# frozen_string_literal: true

# Form for a GitHub repository work
class GithubRepositoryWorkForm < BaseWorkForm
  # This is necessary for proper routing based on Work subclasses.
  def self.model_name
    ActiveModel::Name.new(self, nil, 'Work')
  end

  def default_tab
    :title
  end

  def render_tabs
    %i[title contributors abstract types license related_content citation]
  end
end
