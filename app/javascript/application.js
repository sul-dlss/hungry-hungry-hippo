// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails'
import 'controllers'

// This is to help with breaking out of a turbo frame.
Turbo.StreamActions.full_page_redirect = function () { // eslint-disable-line no-undef
  document.location = this.getAttribute('target')
}

// This is to redirect a turbo frame.
Turbo.StreamActions.frame_redirect = function () { // eslint-disable-line no-undef
  const frame = document.querySelector(`turbo-frame#${this.getAttribute('frameTarget')}`)
  frame.src = this.getAttribute('target')
}

// This is to reload a turbo frame.
Turbo.StreamActions.frame_reload = function () { // eslint-disable-line no-undef
  const frame = document.querySelector(`turbo-frame#${this.getAttribute('frameTarget')}`)
  frame.reload()
}
