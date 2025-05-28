// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails'
import 'controllers'
import 'ahoy'

// This is to help with breaking out of a turbo frame.
Turbo.StreamActions.full_page_redirect = function () { // eslint-disable-line no-undef
  document.location = this.getAttribute('target')
}

// Add data-ahoy-track to a link to track clicks. The link_to_new_tab helper will add this automatically.
ahoy.trackClicks('[data-ahoy-track]') // eslint-disable-line no-undef
