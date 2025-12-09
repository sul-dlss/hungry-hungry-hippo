# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering the Globus button with the appropriate data action.
    class GlobusButtonComponent < SdrViewComponents::Forms::ButtonComponent
      def initialize(confirm: false, **args)
        @confirm = confirm
        super(data: data_action, **args)
      end

      private

      # Determine the appropriate data action based on whether confirmation is needed
      def data_action
        return { action: 'dropzone-files#disableDropzoneConfirm' } if @confirm

        { action: 'dropzone-files#disableDropzone' }
      end
    end
  end
end
