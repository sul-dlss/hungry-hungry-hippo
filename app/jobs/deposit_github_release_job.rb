# frozen_string_literal: true

require 'tempfile'

# Job to process a GitHub release deposit.
class DepositGithubReleaseJob < ApplicationJob
  include ActionView::Helpers::DateHelper

  queue_as :github

  def perform(github_release:) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
    @github_release = github_release
    set_hb_context
    if github_release.completed? ||
       github_release.started? ||
       older_incomplete_release_exists? ||
       check_publish_wait! ||
       check_version_status!
      return
    end

    github_release.update!(status: 'started', status_details: nil)

    return if check_release_zip_exists!

    Tempfile.create(['github-release', '.zip'], binmode: true) do |tempfile|
      downloader.download_to(tempfile)
      create_content_file(tempfile)
    end

    github_repository.deposit_persist! # Sets the deposit state
    perform_deposit

    github_release.completed!
  rescue StandardError => e
    github_release.update!(status: 'failed', status_details: "error processing release: #{e.message}")
    raise
  end

  private

  attr_reader :github_release

  delegate :github_repository, to: :github_release
  delegate :druid, :collection, :user, to: :github_repository

  def older_incomplete_release_exists?
    GithubRelease.where(github_repository:)
                 .where.not(status: 'completed')
                 .exists?(['published_at < ?', github_release.published_at])
  end

  # @return [Boolean] true if the release is still within the wait period after publishing
  def check_publish_wait!
    return false unless github_release.published_at > publish_wait

    github_release.update!(status_details: "waiting #{time_ago_in_words(publish_wait)} after publishing")

    true
  end

  def publish_wait
    Settings.github.publish_wait.seconds.ago
  end

  def check_version_status! # rubocop:disable Metrics/AbcSize
    if version_status.open? && !version_status.closeable?
      github_release.update!(status_details: 'version is open but not closeable')
      Honeybadger.notify('Version is open but not closeable')
      return true
    end

    if !version_status.open? && !version_status.openable?
      github_release.update!(status_details: 'version is not openable')
      Honeybadger.notify('Version is not openable')
      return true
    end

    false
  end

  def version_status
    @version_status ||= Sdr::Repository.status(druid:)
  end

  def set_hb_context
    Honeybadger.context(github_release_id: github_release.id,
                        github_repository_id: github_repository.id,
                        druid:,
                        release_name: github_release.release_name)
  end

  def downloader
    @downloader ||= Github::ReleaseDownloader.new(zip_url: github_release.zip_url)
  end

  def cocina_object
    @cocina_object ||= Sdr::Repository.find(druid:)
  end

  def work_form
    @work_form ||= Form::WorkMapper.call(cocina_object:,
                                         doi_assigned: doi_assigned?,
                                         agree_to_terms: user.agree_to_terms?,
                                         version_description: github_release.release_name,
                                         collection:,
                                         work_form_class: GithubRepositoryWorkForm).tap do |form|
                                           form.content_id = content.id
                                         end
  end

  def doi_assigned?
    DoiAssignedService.call(cocina_object:, work: github_repository)
  end

  def filename
    "#{github_release.release_tag}.zip"
  end

  def content
    @content ||= Content.create!(user:, work: github_repository)
  end

  def create_content_file(tempfile)
    content_file = ContentFile.create(file_type: :attached,
                                      size: tempfile.size,
                                      label: '',
                                      content:,
                                      mime_type: 'application/zip',
                                      filepath: filename)

    content_file.file.attach(io: File.open(tempfile.path), filename:, content_type: 'application/zip')
  end

  def check_release_zip_exists!
    return false if downloader.exist?

    github_release.update!(status: 'completed', status_details: 'version zip missing')
    true
  end

  def perform_deposit
    # Running synchronously instead of as a job.
    DepositWorkJob.perform_now(work: github_repository, work_form:, deposit: true, request_review: false,
                               current_user: user)
  end
end
