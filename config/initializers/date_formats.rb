# frozen_string_literal: true

Date::DATE_FORMATS[:edtf] = ->(date) { date.edtf }
