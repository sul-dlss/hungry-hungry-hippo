# frozen_string_literal: true

REQUIRED_FIELD_MARK = "\u00A0* (required)"
REQUIRED_TAB_MARK = " *\n(contains required fields)"

def with_required_field_mark(label)
  "#{label}#{REQUIRED_FIELD_MARK}"
end

def with_required_tab_mark(label)
  "#{label}#{REQUIRED_TAB_MARK}"
end
