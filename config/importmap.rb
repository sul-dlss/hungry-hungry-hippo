# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin 'stimulus-autocomplete'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'sdr_view_components/tab_error_controller', to: 'sdr_view_components/tab_error_controller.js'
pin 'sdr_view_components/tab_link_controller', to: 'sdr_view_components/tab_link_controller.js'
pin 'sdr_view_components/tab_nav_controller', to: 'sdr_view_components/tab_nav_controller.js'
pin '@popperjs/core', to: 'https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8'
pin 'bootstrap', to: 'https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/+esm'
pin 'ahoy', to: 'ahoy.js'
# Pins for dropzone
pin 'dropzone' # @6.0.0
pin 'just-extend' # @5.1.1
pin 'local-time' # @3.0.3
