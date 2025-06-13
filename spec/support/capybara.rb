# frozen_string_literal: true

# This is to prevent the animation from running in the system tests which can make the tests flaky.
Capybara.disable_animation = true
Capybara.default_max_wait_time = 15 # Capybara default is 2
Capybara.register_driver(:selenium_headless_chrome_lockstep) do |app|
  # The following option is recommended by the capybara-lockstep gem
  options = Selenium::WebDriver::Chrome::Options.new(unhandled_prompt_behavior: 'ignore')
  options.add_argument('--window-size=1400,1400')
  options.add_argument('--disable-search-engine-choice-screen')
  options.add_argument('--headless')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options:)
end

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
      driven_by :selenium_headless_chrome_lockstep
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
