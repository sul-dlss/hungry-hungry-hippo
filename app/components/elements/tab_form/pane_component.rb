# frozen_string_literal: true

module Elements
  module TabForm
    # Component for a tab pane.
    # Based on https://getbootstrap.com/docs/5.3/components/navs-tabs/#javascript-behavior
    class PaneComponent < ApplicationComponent
      def initialize(tab_name:, form_id: nil, label: nil, selected: false, render_footer: true, help_text: nil) # rubocop:disable Metrics/ParameterLists
        @tab_name = tab_name
        @label = label
        @selected = selected
        # Provide the form_id to associate the save draft button with the main
        # form if this pane is outside the main form.
        @form_id = form_id
        @render_footer = render_footer
        @help_text = help_text
        super()
      end

      attr_reader :tab_name, :selected, :label, :form_id, :help_text

      def classes
        merge_classes(%w[tab-pane fade h-100], selected ? 'show active' : nil)
      end

      def id
        "#{tab_name}-pane"
      end

      def tab_id
        "#{tab_name}-tab"
      end

      def render_footer?
        @render_footer
      end
    end
  end
end
