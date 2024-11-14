# frozen_string_literal: true

module Elements
  # Component for rendering an alert.
  class AlertComponent < ApplicationComponent
    # Variants are :danger, :success, :note, :info, :warning
    def initialize(title: nil, variant: :info, dismissible: false)
      raise ArgumentError, 'Invalid variant' unless %i[danger success note info warning].include?(variant)

      @title = title
      @variant = variant
      @dismissible = dismissible
      super()
    end

    attr_reader :title, :variant

    def classes
      merge_classes(%w[alert d-flex shadow-sm align-items-center], variant_class, dismissible_class)
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
