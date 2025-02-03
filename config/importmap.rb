# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application'
pin '@hotwired/turbo-rails', to: 'turbo.min.js'
pin '@hotwired/stimulus', to: 'stimulus.min.js'
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js'
pin 'stimulus-autocomplete'
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin '@popperjs/core', to: 'https://cdn.skypack.dev/@popperjs/core@2.11.8'
pin 'bootstrap', to: 'https://cdn.skypack.dev/bootstrap@5.3.3'
# Pins for dropzone
pin 'dropzone' # @6.0.0
pin 'just-extend' # @5.1.1
pin 'stimulus-datepicker' # @1.0.9
