# frozen_string_literal: true

# Namespaces have to exist so they can be registered as a custom namespace: https://guides.rubyonrails.org/v8.0/autoloading_and_reloading_constants.html#custom-namespaces

# Generate Cocina from scalars
module Generators; end
# Import hash data (froma JSON export) to DB-persisted models
module Importers; end
# Send messages to the expected recipients at the expected time
module Messengers; end
# Roundtrip Cocina objects to ensure they can be converted to a form instance and back without lossiness
module Roundtrippers; end
# Synchronize Cocina to DB-persisted models
module Synchronizers; end

Rails.autoloaders.main.push_dir(Rails.root.join('app/generators'), namespace: Generators)
Rails.autoloaders.main.push_dir(Rails.root.join('app/importers'), namespace: Importers)
Rails.autoloaders.main.push_dir(Rails.root.join('app/messengers'), namespace: Messengers)
Rails.autoloaders.main.push_dir(Rails.root.join('app/roundtrippers'), namespace: Roundtrippers)
Rails.autoloaders.main.push_dir(Rails.root.join('app/synchronizers'), namespace: Synchronizers)
