# frozen_string_literal: true

RSpec.configure do |config|
  config.prepend_before(:example, type: :system) do |example|
    # If you can't use Cyperful, a headed test can be helpful for authoring system specs.
    if ENV['CYPERFUL'] || example.metadata[:headed_test]
      # Cyperful only supports Selenium + Chrome
      driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
    elsif example.metadata[:rack_test]
      # Rack tests are faster than Selenium, but they don't support JavaScript
      driven_by :rack_test
    else
      driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
    end
  end

  # This will output the browser console logs after each system test
  config.after(:each, type: :system) do |example|
    next if example.metadata[:rack_test] || ENV['CYPERFUL'].present?

    Rails.logger.info('Browser log entries from system spec run include:')
    Capybara.page.driver.browser.logs.get(:browser).each do |log_entry|
      Rails.logger.info("* #{log_entry}")
    end
  end
end

# This is to prevent the animation from running in the system tests which can make the tests flaky.
Capybara.disable_animation = true
