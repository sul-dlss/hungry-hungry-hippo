# frozen_string_literal: true

RSpec.configure do |config|
  # Add :default_per_page2 context to set Kaminari's default per page to 2
  config.before(:context, :default_per_page2) do
    Kaminari.configure do |pagination_config|
      @original_default_per_page = pagination_config.default_per_page
      pagination_config.default_per_page = 2
    end
  end

  config.after(:context, :default_per_page2) do
    Kaminari.configure do |pagination_config|
      pagination_config.default_per_page = @original_default_per_page if defined?(@original_default_per_page)
    end
  end
end
