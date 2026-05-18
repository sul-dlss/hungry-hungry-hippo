# frozen_string_literal: true

require Rails.root.join('lib/blanks/base_empty')

Rails.application.config.to_prepare do
  next if Blanks::Base < Blanks::BaseEmpty

  Blanks::Base.prepend(Blanks::BaseEmpty)
end
