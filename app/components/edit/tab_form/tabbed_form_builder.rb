# frozen_string_literal: true

module Edit
  module TabForm
    # A FormBuilder for use with Edit::TabForm::TabListComponent-based forms.
    #
    # TabListComponent doesn't render a <form> tag itself -- the real <form> is rendered
    # separately by the caller, and fields are associated with it via the HTML `form`
    # attribute rather than DOM nesting (since panes aren't necessarily inside the <form>).
    # This builder automatically sets that `form` attribute on every field it builds, so
    # callers don't need to pass `form: form_id` explicitly at every call site.
    #
    # It also makes `id` (used above to derive the `form` attribute) available on builders
    # created via `fields_for`, by falling back to the parent builder's `id`. Rails'
    # `fields_for` doesn't otherwise propagate the `html: { id: }` option to nested builders.
    class TabbedFormBuilder < ActionView::Helpers::FormBuilder
      FIELD_METHODS = %i[text_field email_field textarea text_area hidden_field file_field radio_button checkbox
                         date_field].freeze

      FIELD_METHODS.each do |field_method|
        define_method(field_method) do |*args, &block|
          # These methods take a plain trailing options Hash (not real keyword arguments), and
          # callers pass it either as `key: value` pairs or as a literal Hash -- both arrive here
          # as a positional Hash, so it has to be merged in place rather than via **kwargs.
          args << {} unless args.last.is_a?(Hash)
          args[-1] = { form: id }.merge(args.last)
          super(*args, &block)
        end
      end

      def select(method, choices = nil, options = {}, html_options = {}, &)
        html_options[:form] ||= id
        super
      end

      def id
        super || options[:parent_builder]&.id
      end
    end
  end
end
