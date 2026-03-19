# frozen_string_literal: true

# Module to make Selenium-driven system tests more resilient to transient WebDriver errors during test teardown.
module SeleniumTeardownResilience
  TRANSIENT_ERROR_SNIPPETS = [
    'No dialog is showing',
    'no such alert',
    'aborted by navigation',
    'Not attached to an active page'
  ].freeze

  module_function

  def transient_error?(error)
    message = error.message.to_s
    TRANSIENT_ERROR_SNIPPETS.any? { |snippet| message.include?(snippet) }
  end

  # In parallel Selenium runs, alert cleanup can race with navigation and raise
  # transient WebDriver errors that are safe to ignore during reset.
  def accept_unhandled_reset_alert
    super
  rescue Selenium::WebDriver::Error::WebDriverError => e
    raise unless SeleniumTeardownResilience.transient_error?(e)
  end
end

Capybara::Selenium::Driver.prepend(SeleniumTeardownResilience)

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
    begin
      Capybara.page.driver.browser.logs.get(:browser).each do |log_entry|
        Rails.logger.info("* #{log_entry}")
      end
    rescue Selenium::WebDriver::Error::WebDriverError => e
      raise unless SeleniumTeardownResilience.transient_error?(e)

      Rails.logger.info("Skipped browser console log capture: #{e.message.lines.first.chomp}")
    end
  end
end
