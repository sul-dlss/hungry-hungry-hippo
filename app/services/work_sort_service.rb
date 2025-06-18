# frozen_string_literal: true

# Supports ordering works for display
class WorkSortService
  def self.call(works:, sort_by:)
    new(works:, sort_by:).call
  end

  def initialize(works:, sort_by:)
    @works = works
    @sort_by = sort_by
  end

  attr_reader :works, :sort_by

  # @return [Array<WorkPresenter>] objects ordered by the specified sort criteria
  def call
    case sort_by
    when 'status asc'
      presenters(works).sort_by(&:status_message)
    when 'status desc'
      presenters(works).sort_by(&:status_message).reverse
    else
      # use the sort_by order clause
      presenters(works.order(sort_by))
    end
  end

  private

  def statuses
    @statuses ||= Sdr::Repository.statuses(
      druids: works.where.not(druid: nil).pluck(:druid)
    )
  end

  def presenters(works)
    works.map do |work|
      WorkPresenter.new(work:,
                        version_status: statuses.fetch(work.druid, VersionStatus::NilStatus.new),
                        work_form: WorkForm.new(druid: work.druid))
    end
  end
end
