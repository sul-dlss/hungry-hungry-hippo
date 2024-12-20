# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Manage authors for a work deposit' do
  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let(:version_status) do
    VersionStatus.new(status:
    instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: false, accessioning?: true,
                                                                         openable?: false, version: 1))
  end

  before do
    # Stubbing out for Deposit Job
    allow(Sdr::Repository).to receive(:register) do |args|
      cocina_params = args[:cocina_object].to_h
      cocina_params[:externalIdentifier] = druid
      cocina_params[:description][:purl] = Sdr::Purl.from_druid(druid:)
      cocina_params[:structural] = { isMemberOf: [collection_druid_fixture] }
      cocina_params[:administrative] = { hasAdminPolicy: Settings.apo }
      cocina_object = Cocina::Models.build(cocina_params)
      (@registered_cocina_object = Cocina::Models.with_metadata(cocina_object, 'abc123'))
    end
    allow(Sdr::Repository).to receive(:accession)

    # Stubbing out for show page
    allow(Sdr::Repository).to receive(:find).with(druid:).and_invoke(->(_arg) { @registered_cocina_object })
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)

    create(:collection, user:, druid: collection_druid_fixture)

    sign_in(user)
  end

  it 'manages authors' do
    visit new_work_path(collection_druid: collection_druid_fixture)

    expect(page).to have_css('h1', text: 'Untitled deposit')

    # Filling in title
    find('.nav-link', text: 'Title & contact').click
    fill_in('work_title', with: title_fixture)
    # fill_in('Contact email', with: contact_emails_fixture.first['email'])

    # Go to authors tab
    find('.nav-link', text: 'Authors').click
    expect(page).to have_text('Author(s) to include in citation')

    # There is a single author form
    form_instances = all('.form-instance')
    expect(form_instances.count).to eq(1)
    expect(form_instances[0]).to have_no_css('.move-up')
    expect(form_instances[0]).to have_no_css('.move-down')

    # Fill in the author form
    within form_instances[0] do
      select('Creator', from: 'Role')
      fill_in('First name', with: 'Jane')
      fill_in('Last name', with: 'Stanford')
    end

    click_link_or_button('Add another author')

    # There are now two author forms
    form_instances = all('.form-instance')
    expect(form_instances.count).to eq(2)
    expect(form_instances[0]).to have_no_css('.move-up')
    expect(form_instances[0]).to have_css('.move-down')
    expect(form_instances[1]).to have_css('.move-up')
    expect(form_instances[1]).to have_no_css('.move-down')

    # Fill in the second author form
    within form_instances[1] do
      find('label', text: 'Organization').click
      select('Author', from: 'Role')
      fill_in('Organization name', with: 'Stanford University')
    end

    click_link_or_button('Add another author')
    form_instances = all('.form-instance')
    expect(form_instances.count).to eq(3)
    expect(form_instances[0]).to have_no_css('.move-up')
    expect(form_instances[0]).to have_css('.move-down')
    expect(form_instances[1]).to have_css('.move-up')
    expect(form_instances[1]).to have_css('.move-down')
    expect(form_instances[2]).to have_css('.move-up')
    expect(form_instances[2]).to have_no_css('.move-down')

    # Move down the first author form
    within form_instances.first do
      click_link_or_button('Move down')
    end

    form_instances = all('.form-instance')
    expect(form_instances.pluck('data-index')).to eq %w[1 0 2]
    expect(form_instances[0]).to have_no_css('.move-up')
    expect(form_instances[0]).to have_css('.move-down')
    expect(form_instances[1]).to have_css('.move-up')
    expect(form_instances[1]).to have_css('.move-down')
    expect(form_instances[2]).to have_css('.move-up')
    expect(form_instances[2]).to have_no_css('.move-down')

    # Move up the last author form
    within form_instances.last do
      click_link_or_button('Move up')
    end

    form_instances = all('.form-instance')
    expect(form_instances.pluck('data-index')).to eq %w[1 2 0]

    # Delete the (empty) second author form
    within form_instances[1] do
      click_link_or_button('Clear')
    end

    form_instances = all('.form-instance')
    expect(form_instances.count).to eq(2)
    expect(form_instances[0]).to have_no_css('.move-up')
    expect(form_instances[0]).to have_css('.move-down')
    expect(form_instances[1]).to have_css('.move-up')
    expect(form_instances[1]).to have_no_css('.move-down')

    click_link_or_button('Save as draft')

    # Waiting page may be too fast to catch so not testing.
    # On show page
    expect(page).to have_css('h1', text: title_fixture)

    within('table#authors-table') do
      expect(page).to have_css('td', text: 'Jane Stanford')
      expect(page).to have_css('td', text: 'Stanford University')
    end
  end
end
