# frozen_string_literal: true

module ViewComponent
  # View Components silently ignore within calls.
  # See https://github.com/ViewComponent/view_component/issues/1910
  module TestHelpers
    def within(...)
      raise "`within` doesn't work in component tests. Use `page.find` instead."
    end
  end
end
