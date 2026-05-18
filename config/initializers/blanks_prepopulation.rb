# frozen_string_literal: true

require Rails.root.join('lib/blanks/prepopulation')

Rails.application.config.to_prepare do
  Blanks::Base.include(Blanks::Prepopulation) unless Blanks::Base < Blanks::Prepopulation
end
