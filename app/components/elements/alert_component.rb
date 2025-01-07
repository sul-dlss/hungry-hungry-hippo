# frozen_string_literal: true

module Elements
  # Component for rendering an alert.
  class AlertComponent < ApplicationComponent
    # Variants are :danger, :success, :note, :info, :warning
    def initialize(title: nil, variant: :info, dismissible: false, value: nil, data: {}, classes: []) # rubocop:disable Metrics/ParameterLists
      raise ArgumentError, 'Invalid variant' unless %i[danger success note info warning].include?(variant.to_sym)

      @title = title
      @variant = variant
      @dismissible = dismissible
      @value = value
      @data = data
      @classes = classes
      super()
    end

    attr_reader :title, :variant, :value, :data

    def classes
      merge_classes(%w[alert d-flex shadow-sm align-items-center], variant_class, dismissible_class, @classes)
    end

    def variant_class
      "alert-#{variant}"
    end

    def dismissible_class
      'alert-dismissible' if dismissible?
    end

    def dismissible?
      @dismissible
    end

    def icon
      helpers.public_send(:"#{variant}_icon")
    end
  end
end
