# frozen_string_literal: true

require Rails.root.join('lib/blanks/association_proxy_enumerable_methods')

Rails.application.config.to_prepare do
  next if Blanks::AssociationProxy < Blanks::AssociationProxyEnumerableMethods

  Blanks::AssociationProxy.prepend(Blanks::AssociationProxyEnumerableMethods)
end
