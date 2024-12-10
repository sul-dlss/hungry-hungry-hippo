# frozen_string_literal: true

# Presenter for the Purl (persistent) link to the provided druid.
class PurlLinkPresenter
  include ActionView::Helpers::UrlHelper

  # @param [druid] The druid to link to
  # @param [label] The label for the link, default to nil
  def initialize(druid:, label: nil)
    @druid = druid
    @label = label
  end

  def link
    link_to(@label, Sdr::Purl.from_druid(druid: @druid)) if @druid # No druid yet, so H3 is depositing.
  end
end
