# frozen_string_literal: true

require Rails.root.join('lib/blanks/contextual_nested_validation')

Rails.application.config.to_prepare do
  Blanks::Base.prepend(Blanks::ContextualNestedValidation) unless Blanks::Base < Blanks::ContextualNestedValidation
end
