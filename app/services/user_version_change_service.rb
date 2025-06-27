# frozen_string_literal: true

# Determines if a new user version is required based on changes in the structural metadata of a Cocina object.
class UserVersionChangeService
  def self.call(...)
    new(...).call
  end

  def initialize(original_cocina_object:, new_cocina_object:)
    @original_cocina_object = original_cocina_object
    @new_cocina_object = new_cocina_object
  end

  # @return [Boolean] true if the change requires a new user version
  def call
    contains_hash_for(original_cocina_object.structural) != contains_hash_for(new_cocina_object.structural)
  end

  private

  attr_reader :original_cocina_object, :new_cocina_object

  def contains_hash_for(structural)
    structural.to_h[:contains].tap do |contains_hash|
      contains_hash.each do |file_set_hash|
        file_set_hash.delete(:label)
        file_set_hash[:structural][:contains].each do |file_hash|
          file_hash.delete(:label)
          file_hash.delete(:access)
        end
      end
    end
  end
end
