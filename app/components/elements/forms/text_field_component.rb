# frozen_string_literal: true

module Elements
  module Forms
    # Component for form text fields
    class TextFieldComponent < FieldComponent
      # This is the default `size` attribute of the `<input>` element. See https://www.w3schools.com/TAGs/att_input_size.asp
      DEFAULT_SIZE = 20

      def initialize(maxlength: nil, size: nil, **args)
        @maxlength = maxlength
        @size = size
        args[:container_classes] = merge_classes('field-container', args[:container_classes])
        args[:input_classes] =
          merge_classes(args[:readonly] ? 'form-control-plaintext' : 'form-control', args[:input_classes])
        super(**args)
      end

      attr_reader :maxlength, :rows

      # If `maxlength` is set on this component and a size is not, the size of
      # the input element will default (in HTML) to the value of the `maxlength`
      # attribute. In that case, we want to inject the default size back into
      # the input element.
      def size
        return if maxlength.blank?

        DEFAULT_SIZE
      end
    end
  end
end
