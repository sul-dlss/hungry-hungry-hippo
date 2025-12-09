# frozen_string_literal: true

require 'open-uri'

# Controller to handle GitHub webhooks for repository events.
class GithubWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  allow_unauthenticated_access
  skip_verify_authorized

  before_action :verify_signature

  def create
    event = request.headers['X-GitHub-Event']
    if event == 'release'
      payload = JSON.parse(request.body.read)
      handle_release(payload)
    end
    head :ok
  end

  private

  def verify_signature
    return if Rails.env.test? # Skip verification in test if needed, or ensure secret is set

    request.body.rewind
    payload_body = request.body.read
    signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), Settings.github.webhook_secret,
                                                  payload_body)}"

    return if Rack::Utils.secure_compare(signature, request.headers['X-Hub-Signature-256'] || '')

    head :unauthorized
  end

  def handle_release(payload)
    return unless payload['action'] == 'published'

    # see https://docs.github.com/en/webhooks/webhook-events-and-payloads?actionType=published#release

    repo_id = payload['repository']['id'].to_s
    repo_name = payload['repository']['full_name']
    repo_description = payload['repository']['description']
    repo_zipball = payload['release']['zipball_url'] # URL to download the release as a zip
    integration = CollectionGithubRepo.find_by(github_repo_id: repo_id)
    return unless integration

    collection = integration.collection
    # TODO: this should all happen in a job to be async
    # since the repo dowwnload may take a while
    # Create a new work draft
    content = Content.create!(user: collection.user)

    # Download and attach the repository zipball
    zip_filename = "#{repo_name.tr('/', '-')}-#{payload['release']['tag_name']}.zip"
    URI.open(repo_zipball) do |file|
      content_file = content.content_files.create!(
        filepath: zip_filename,
        file_type: :attached,
        size: file.size,
        label: "Repository zipball for release #{payload['release']['tag_name']}"
      )
      content_file.file.attach(io: file, filename: zip_filename, content_type: 'application/zip')
    end

    work = Work.create!(collection:, title: repo_name, user: collection.user)
    content.update(work:)
    work.deposit_persist! # Sets the deposit state
    work_form = WorkForm.new(
      collection_druid: collection.druid,
      title: repo_name,
      abstract: repo_description,
      content_id: content.id,
      license: collection.license,
      access: collection.stanford_access? ? 'stanford' : 'world',
      agree_to_terms: collection.user.agree_to_terms?,
      contact_emails_attributes: [{ email: collection.user.email_address }],
      work_type: collection.work_type,
      work_subtypes: collection.work_subtypes,
      works_contact_email: collection.works_contact_email
    )
    work_form.max_release_date = collection.max_release_date if collection.depositor_selects_release_option?
    work_form.creation_date = work.created_at.to_date
    DepositWorkJob.perform_later(work:, work_form:, deposit: false, request_review: false,
                                 current_user: collection.user)
  end
end
