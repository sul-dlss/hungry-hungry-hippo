# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:example, type: :system) do
    Kaminari.configure do |pagination_config|
      pagination_config.default_per_page = 2
    end
  end
end
