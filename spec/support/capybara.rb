# frozen_string_literal: true

# Recommended by Playwright documentation
Capybara.default_max_wait_time = 30

# This is to prevent the animation from running in the system tests which can make the tests flaky.
Capybara.disable_animation = true
Capybara.register_driver(:playwright_headless_chrome) do |app|
  Capybara::Playwright::Driver.new(
    app,
    browser_type: :chromium, # :chromium (default) or :firefox, :webkit
    headless: true # true for headless mode (default), false for headful mode.
  )
end

RSpec.configure do |config|
  config.prepend_before(:example, type: :system) do |example|
    # If you can't use Cyperful, a headed test can be helpful for authoring system specs.
    if ENV['CYPERFUL'] || example.metadata[:headed_test]
      # Cyperful only supports Selenium + Chrome
      driven_by :selenium, using: :chrome, screen_size: [1400, 1400]
    elsif example.metadata[:rack_test]
      # Rack tests are faster than Selenium & Playwright, but they don't support JavaScript
      driven_by :rack_test
    elsif example.metadata[:dropzone]
      # Playwright does not implement uploading files via dropping
      driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
    else
      driven_by :playwright_headless_chrome
    end
  end

  # This will output the browser console logs after each system test
  config.after(:each, type: :system) do |example|
    next if example.metadata[:rack_test] || ENV['CYPERFUL'].present? ||
            Capybara.page.driver.is_a?(Capybara::Playwright::Driver)

    Rails.logger.info('Browser log entries from system spec run include:')
    Capybara.page.driver.browser.logs.get(:browser).each do |log_entry|
      Rails.logger.info("* #{log_entry}")
    end
  end
end
