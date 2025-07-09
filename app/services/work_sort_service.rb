# frozen_string_literal: true

# Supports ordering and paginating works for display
class WorkSortService
  def self.call(...)
    new(...).call
  end

  def initialize(works:, sort_by:, page:)
    @works = works
    @sort_by = sort_by
    @page = page
  end

  attr_reader :works, :sort_by, :page

  # @return [Kaminari::PaginatableArray<WorkPresenter>] objects ordered by the specified sort criteria
  def call # rubocop:disable Metrics/AbcSize
    # if status asc or status desc
    work_presenters = if ['status asc', 'status desc'].include?(sort_by)
                        # Need to get all statuses for all works, since the status is being used for sorting.
                        statuses = statuses_for(works)
                        presenters_from(works:, statuses:).sort_by(&:status_message).tap do |presenters|
                          presenters.reverse! if sort_by == 'status desc'
                        end
                      else
                        # Making this more efficient by only getting statuses for the page.
                        # The rest of the statuses are nil, which is fine since they aren't being displayed.
                        # Returning a Kaminari array so that pagination works.
                        sorted_works = works.order(sort_by)
                        works_page = sorted_works.page(page)
                        statuses = statuses_for(works_page)
                        presenters_from(works: sorted_works, statuses:)
                      end
    Kaminari.paginate_array(work_presenters).page(page)
  end

  private

  def statuses_for(works)
    Sdr::Repository.statuses(
      druids: works.where.not(druid: nil).pluck(:druid)
    )
  end

  def presenters_from(works:, statuses:)
    works.map do |work|
      WorkPresenter.new(work:,
                        version_status: statuses.fetch(work.druid, VersionStatus::NilStatus.new),
                        work_form: WorkForm.new(druid: work.druid))
    end
  end
end
