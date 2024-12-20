# frozen_string_literal: true

module ApplicationHelper
  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end
end
