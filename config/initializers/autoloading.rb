# frozen_string_literal: true

# Namespaces have to exist so they can be registered as a custom namespace: https://guides.rubyonrails.org/v8.0/autoloading_and_reloading_constants.html#custom-namespaces
module Synchronizers; end

Rails.autoloaders.main.push_dir(
  Rails.root.join('app/synchronizers'), namespace: Synchronizers
)
