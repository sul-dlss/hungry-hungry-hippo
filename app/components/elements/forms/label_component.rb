# frozen_string_literal: true

module Elements
  module Forms
    # Component for rendering a form label.
    class LabelComponent < ApplicationComponent
      def initialize(form:, field_name:, label_text: nil, default_label_class: 'form-label', hidden_label: false, # rubocop:disable Metrics/ParameterLists
                     classes: [], tooltip: nil)
        @form = form
        @label_text = label_text
        @field_name = field_name
        @hidden_label = hidden_label
        @default_label_class = default_label_class
        @classes = classes
        @tooltip = tooltip
        super()
      end

      attr_reader :field_name, :form

      def label_text
        return field_name if @label_text.blank?

        @label_text
      end

      def classes
        merge_classes(@default_label_class, @classes, @hidden_label ? 'visually-hidden' : nil)
      end

      def tooltip?
        tooltip.present?
      end

      def tooltip
        # The tooltip can include a trailing \n that isn't rendered in the HTML but does make for ugly source markup
        @tooltip&.chomp
      end

      def tooltip_template
        <<~HTML.squish
          <div class="tooltip tooltip-shift-right" role="tooltip">
            <div class="tooltip-arrow"></div>
            <div class="tooltip-inner text-start"></div>
          </div>
        HTML
      end

      def tooltip_data
        {
          bs_html: true,
          bs_template: tooltip_template,
          bs_toggle: 'tooltip',
          bs_title: tooltip,
          bs_trigger: 'click focus',
          tooltips_target: 'icon'
        }
      end
    end
  end
end
