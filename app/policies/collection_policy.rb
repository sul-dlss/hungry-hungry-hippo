# frozen_string_literal: true

class CollectionPolicy < ApplicationPolicy
  pre_check :collection_creator?
  # TODO: Add a rule for collection managers & depositors
  # manage? will be based on the managers added to a collection
  # display? will be based on the depositors added to a collection
  # alias_rule :show?, :update?, :edit?, :wait?, to: :manage?

  def collection_creator?
    allow! if Current.groups.include?(Settings.authorization_workgroup_names.collection_creators)
  end
end
