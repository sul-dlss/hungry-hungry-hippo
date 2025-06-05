# frozen_string_literal: true

# Presenter for SDR events.
# Note that this is a SimpleDelegator, so all methods available on the event are also available on this presenter.
class EventPresenter < SimpleDelegator
  def initialize(event:)
    super(event)
  end

  def label
    I18n.t("events.#{event_type}", default: event_type.humanize)
  end

  def who
    data['who']
  end

  def description
    return data['comments'] if data['comments'].present?

    # Some events just have the cocina object as the data. Don't want to display the description in that case.
    data['description'] unless data.key?('cocinaVersion')
  end

  def timestamp
    Time.zone.parse(super).to_fs(:long)
  end
end
