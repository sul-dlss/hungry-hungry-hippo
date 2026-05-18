# frozen_string_literal: true

module Blanks
  # Monkeypatch extension to support render-time prepopulation of nested associations.
  module Prepopulation
    def prepopulate! # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity, Metrics/CyclomaticComplexity
      self.class.associations.each do |association_name, association|
        options = self.class.nested_attributes_options[association_name] || {}

        case association[:type]
        when :has_many
          prepopulate_count = options[:prepopulate_count].to_i
          prepopulate_count = 1 if options[:prepopulate_if_empty] && prepopulate_count.zero?

          rows_to_add = [0, prepopulate_count - public_send(association_name).size].max
          rows_to_add.times { public_send(association_name).build }
        when :has_one
          next unless options[:prepopulate_if_empty]
          next if public_send(association_name).present?

          public_send("build_#{association_name}")
        end
      end

      self.class.associations.each_key do |association_name|
        Array(public_send(association_name)).each do |nested_form|
          nested_form.prepopulate! if nested_form.respond_to?(:prepopulate!)
        end
      end

      self
    end
  end
end
