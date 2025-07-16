# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Manage contributors for a work deposit' do
  let(:druid) { druid_fixture }
  let(:user) { create(:user) }
  let(:version_status) { build(:first_accessioning_version_status) }
  let(:affiliation_query) { { search: 'Stanford University' } }
  let(:affiliation_ror) { [{ 'id' => 'https://ror.org/00f54p054', 'name' => 'Stanford University Affiliation' }] }

  before do
    # Stubbing out for Deposit Job
    allow(Sdr::Repository).to receive(:register) do |args|
      cocina_params = args[:cocina_object].to_h
      cocina_params[:externalIdentifier] = druid
      cocina_params[:description][:purl] = Sdr::Purl.from_druid(druid:)
      cocina_params[:structural] = { isMemberOf: [collection_druid_fixture] }
      cocina_params[:administrative] = { hasAdminPolicy: Settings.apo }
      cocina_object = Cocina::Models.build(cocina_params)
      @registered_cocina_object = Cocina::Models.with_metadata(cocina_object, 'abc123')
    end
    allow(Sdr::Repository).to receive(:accession)

    # Stubbing out for show page
    allow(Sdr::Repository).to receive(:find).with(druid:).and_invoke(->(_arg) { @registered_cocina_object })
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    allow(Doi).to receive(:assigned?).with(druid:).and_return(false)
    allow(Sdr::Event).to receive(:list).and_return([])

    # Stubbing out ROR
    allow(RorService).to receive(:call).with(affiliation_query).and_return(affiliation_ror)
  end

  context 'without required contributors' do
    before do
      create(:collection, user:, druid: collection_druid_fixture)

      allow(Current).to receive(:orcid).and_return('0000-0002-5902-3077')

      stub_request(:get, 'https://pub.orcid.org/v3.0/0000-0002-5902-3077/personal-details')
        .with(
          headers: { 'Accept' => 'application/json' }
        )
        .to_return(status: 200,
                   body: '{"last-modified-date":{"value":1460760329525},"name":{"created-date":{"value":1460760329525},"last-modified-date":{"value":1460760329525},"given-names":{"value":"Amy E."},"family-name":{"value":"Hodge"},"credit-name":null,"source":null,"visibility":"public","path":"0000-0002-5902-3077"},"other-names":{"last-modified-date":{"value":1406092755312},"other-name":[{"created-date":{"value":1406092755312},"last-modified-date":{"value":1406092755312},"source":{"source-orcid":{"uri":"https://orcid.org/0000-0002-5902-3077","path":"0000-0002-5902-3077","host":"orcid.org"},"source-client-id":null,"source-name":{"value":"Amy E. Hodge"},"assertion-origin-orcid":null,"assertion-origin-client-id":null,"assertion-origin-name":null},"content":"A. Hodge, A.E. Hodge","visibility":"public","path":"/0000-0002-5902-3077/other-names/242944","put-code":242944,"display-index":0}],"path":"/0000-0002-5902-3077/other-names"},"biography":null,"path":"/0000-0002-5902-3077/personal-details"}', # rubocop:disable Layout/LineLength
                   headers: { 'Content-Type': 'application/json;charset=UTF-8' })

      stub_request(:get, 'https://pub.orcid.org/v3.0/0000-0001-7756-243X/personal-details')
        .with(
          headers: { 'Accept' => 'application/json' }
        )
        .to_return(status: 200,
                   body: '{"last-modified-date":{"value":1581186663825},"name":{"created-date":{"value":1581186663824},"last-modified-date":{"value":1581186663825},"given-names":{"value":"Michael A."},"family-name":{"value":"Keller"},"credit-name":null,"source":null,"visibility":"public","path":"0000-0001-7756-243X"},"other-names":{"last-modified-date":null,"other-name":[],"path":"/0000-0001-7756-243X/other-names"},"biography":null,"path":"/0000-0001-7756-243X/personal-details"}', # rubocop:disable Layout/LineLength
                   headers: { 'Content-Type': 'application/json;charset=UTF-8' })

      stub_request(:get, 'https://pub.orcid.org/v3.0/0000-0001-7756-0000/personal-details')
        .with(
          headers: { 'Accept' => 'application/json' }
        )
        .to_return(status: 404)

      sign_in(user)
    end

    it 'manages contributors' do
      visit new_work_path(collection_druid: collection_druid_fixture)

      expect(page).to have_css('h1', text: 'Untitled deposit')

      # Filling in title
      find('.nav-link', text: 'Title and contact').click
      fill_in('work_title', with: title_fixture)
      fill_in('Contact email', with: contact_emails_fixture.first['email'])

      # Go to contributors tab
      find('.nav-link', text: 'Authors / Contributors').click
      expect(page).to have_css('.h4', text: 'Authors / Contributors')

      # There is a single contributor form
      form_instances = all('.form-instance')
      expect(form_instances.count).to eq(2)
      expect(form_instances[0]).to have_no_css('.move-up')
      expect(form_instances[0]).to have_no_css('.move-down')

      # Fill in the contributor form
      within form_instances[0] do
        expect(page).to have_button('Clear')
        within('.orcid-section') do
          find('label', text: 'Enter name manually').click
        end
        select('Creator', from: 'Role')
        fill_in('First name', with: 'Jane')
        fill_in('Last name', with: 'Stanford')
        fill_in('Institution', with: 'Stanford University')
        find('li.list-group-item', text: 'Stanford University').click
        fill_in('Department/Center', with: 'Department of History')
      end

      click_link_or_button('Add another contributor')

      # There are now two contributor forms
      form_instances = all('.form-instance')
      expect(form_instances.count).to eq(4)
      expect(form_instances[0]).to have_no_css('.move-up')
      expect(form_instances[0]).to have_css('.move-down')
      expect(form_instances[2]).to have_css('.move-up')
      expect(form_instances[2]).to have_no_css('.move-down')

      # Fill in the second contributor form
      within form_instances[2] do
        find('label', text: 'Organization').click
        select('Author', from: 'Role')
        fill_in('Organization name', with: 'Stanford Research Institute')
      end

      click_link_or_button('Add another contributor')
      form_instances = all('.form-instance')
      expect(form_instances.count).to eq(5)
      expect(form_instances[0]).to have_no_css('.move-up')
      expect(form_instances[0]).to have_css('.move-down')
      expect(form_instances[2]).to have_css('.move-up')
      expect(form_instances[2]).to have_css('.move-down')
      expect(form_instances[3]).to have_css('.move-up')
      expect(form_instances[3]).to have_no_css('.move-down')

      # Move down the first contributor form
      within form_instances.first do
        click_link_or_button('Move down')
      end

      form_instances = all('.form-instance')
      expect(form_instances.pluck('data-index')).to eq %w[1 0 0 2 0]
      expect(form_instances[0]).to have_no_css('.move-up')
      expect(form_instances[0]).to have_css('.move-down')
      expect(form_instances[1]).to have_css('.move-up')
      expect(form_instances[1]).to have_css('.move-down')
      expect(form_instances[3]).to have_css('.move-up')
      expect(form_instances[3]).to have_no_css('.move-down')

      # Move up the last contributor form
      within form_instances[3] do
        click_link_or_button('Move up')
      end

      form_instances = all('.form-instance')
      expect(form_instances.pluck('data-index')).to eq %w[1 2 0 0 0]

      # Delete the (empty) second contributor form
      within form_instances[1] do
        first('button', text: 'Clear').click
      end

      form_instances = all('.form-instance')
      expect(form_instances.count).to eq(5)
      expect(form_instances[0]).to have_no_css('.move-up')
      expect(form_instances[0]).to have_css('.move-down')
      expect(form_instances[1]).to have_css('.move-up')
      expect(form_instances[3]).to have_no_css('.move-down')

      # Add a degree granting institution that is Stanford.
      click_link_or_button('Add another contributor')
      form_instances = all('.form-instance')
      within form_instances[5] do
        find('label', text: 'Organization').click
        expect(page).to have_no_text('Is Stanford the institution?')
        select('Degree granting institution', from: 'Role')
        expect(page).to have_text('Is Stanford the institution?')
        within('.stanford-degree-granting-institution-section') do
          expect(page).to have_field('Yes', checked: true)
        end
        fill_in('Department / Institute / Center', with: 'Department of Philosophy')
      end

      # Add a degree granting institution that is not Stanford.
      click_link_or_button('Add another contributor')
      form_instances = all('.form-instance')
      within form_instances[6] do
        find('label', text: 'Organization').click
        select('Degree granting institution', from: 'Role')
        within('.stanford-degree-granting-institution-section') do
          find('label', text: 'No').click
        end
        fill_in('Organization name', with: 'Foothill College')
      end

      # Add a contributor with an ORCID
      click_link_or_button('Add another contributor')
      form_instances = all('.form-instance')
      within form_instances[7] do
        expect(page).to have_field('First name', disabled: true)
        expect(page).to have_field('Last name', disabled: true)

        # Invalid ORCID
        fill_in('ORCID iD', with: '0000-0001-7756-243Y')
        expect(page).to have_css('.invalid-feedback', text: 'invalid ORCID iD')

        # Not found ORCID
        fill_in('ORCID iD', with: '0000-0001-7756-0000')
        expect(page).to have_css('.invalid-feedback', text: 'not found')

        # Use my ORCID
        click_link_or_button('Use my ORCID')
        expect(page).to have_field('ORCID iD', with: '0000-0002-5902-3077')
        expect(page).to have_field('First name', with: 'Amy E.')
        expect(page).to have_field('Last name', with: 'Hodge')

        fill_in('ORCID iD', with: 'https://orcid.org/0000-0001-7756-243X')
        expect(page).to have_field('First name', with: 'Michael A.')
        expect(page).to have_field('Last name', with: 'Keller')
        expect(page).to have_content('Name associated with this ORCID iD is Michael A. Keller.')

        fill_in('ORCID iD', with: '')
        expect(page).to have_field('First name', with: '', disabled: true)
        expect(page).to have_field('Last name', with: '', disabled: true)
        expect(page).to have_no_content('Name associated with this ORCID iD is Michael A. Keller.')

        fill_in('ORCID iD', with: 'https://orcid.org/0000-0001-7756-243X')
      end

      click_link_or_button('Save as draft')

      # Waiting page may be too fast to catch so not testing.
      # On show page
      expect(page).to have_css('h1', text: title_fixture)

      within('table#contributors-table') do
        within('tbody tr:nth-child(1)') do
          expect(page).to have_css('td:nth-child(1)', text: 'Stanford Research Institute')
          expect(page).to have_css('td:nth-child(3)', text: 'Author')
        end
        within('tbody tr:nth-child(2)') do
          expect(page).to have_css('td:nth-child(1)', text: 'Jane Stanford')
          expect(page).to have_css('td:nth-child(3)', text: 'Creator')
        end
        within('tbody tr:nth-child(3)') do
          expect(page).to have_css('td:nth-child(1)', text: 'Department of Philosophy, Stanford University')
          expect(page).to have_css('td:nth-child(3)', text: 'Degree granting institution')
        end
        within('tbody tr:nth-child(4)') do
          expect(page).to have_css('td:nth-child(1)', text: 'Foothill College')
          expect(page).to have_css('td:nth-child(3)', text: 'Degree granting institution')
        end
        within('tbody tr:nth-child(5)') do
          expect(page).to have_css('td:nth-child(1)', text: 'Michael A. Keller')
          expect(page).to have_css('td:nth-child(2)', text: 'https://orcid.org/0000-0001-7756-243X')
          expect(page).to have_css('td:nth-child(3)', text: 'Author')
        end
      end
    end
  end

  context 'with required contributors' do
    let(:required_person) { create(:person_contributor) }
    let(:required_organization) { create(:organization_contributor) }
    let(:required_stanford_organization) { create(:organization_contributor, :stanford) }

    before do
      create(:collection, user:, druid: collection_druid_fixture,
                          contributors: [required_person, required_organization, required_stanford_organization])

      sign_in(user)
    end

    it 'manages contributors' do
      visit new_work_path(collection_druid: collection_druid_fixture)

      expect(page).to have_css('h1', text: 'Untitled deposit')

      # Go to contributors tab
      find('.nav-link', text: 'Authors / Contributors').click
      expect(page).to have_css('.h4', text: 'Authors / Contributors')

      # There is a single contributor form
      form_instances = all('.form-instance')
      expect(form_instances.count).to eq(3)

      within(form_instances[0]) do
        expect(page).to have_text('Required author / contributor')
        expect(page).to have_no_button('Clear')
        expect(page).to have_text("#{required_person.first_name} #{required_person.last_name} (Author) will be " \
                                  'included in the list of authors and contributors for this work.')
      end

      within(form_instances[1]) do
        expect(page).to have_text('Required author / contributor')
        expect(page).to have_no_button('Clear')
        expect(page).to have_text("#{required_organization.organization_name} (Funder) will be included in the list " \
                                  'of authors and contributors for this work.')
      end

      within(form_instances[2]) do
        expect(page).to have_text('Required author / contributor')
        expect(page).to have_no_button('Clear')
        expect(page).to have_text('Stanford University (Degree Granting Institution), Department of Philosophy ' \
                                  '(Department) will be included in the list ' \
                                  'of authors and contributors for this work.')
      end

      # Add a contributor
      click_link_or_button('Add another contributor')
      form_instances = all('.form-instance')
      expect(form_instances.count).to eq(5)
      within(form_instances[3]) do
        within('.orcid-section') do
          find('label', text: 'Enter name manually').click
        end
        select('Creator', from: 'Role')
        fill_in('First name', with: 'Jane')
        fill_in('Last name', with: 'Stanford')
      end

      # Validate to make sure that the required contributors are still there
      click_link_or_button('Save as draft')
      expect(page).to have_css('.alert-danger', text: 'Required fields have not been filled out.')

      # Go to contributors tab
      find('.nav-link', text: 'Authors / Contributors').click
      expect(page).to have_css('.h4', text: 'Authors / Contributors')

      # There is a single contributor form
      form_instances = all('.form-instance')
      expect(form_instances.count).to eq(4)

      within(form_instances[0]) do
        expect(page).to have_text('Required author / contributor')
        expect(page).to have_text("#{required_person.first_name} #{required_person.last_name} (Author) will be include")
      end

      within(form_instances[1]) do
        expect(page).to have_text('Required author / contributor')
        expect(page).to have_text("#{required_organization.organization_name} (Funder) will be included")
      end

      within(form_instances[2]) do
        expect(page).to have_text('Required author / contributor')
        expect(page).to have_text('Stanford University (Degree Granting Institution), ' \
                                  'Department of Philosophy (Department) will be included')
      end

      within(form_instances[3]) do
        expect(page).to have_no_text('Required author / contributor')
        expect(page).to have_field('First name', with: 'Jane')
      end

      # Filling in title
      find('.nav-link', text: 'Title and contact').click
      fill_in('work_title', with: title_fixture)
      fill_in('Contact email', with: contact_emails_fixture.first['email'])

      click_link_or_button('Save as draft')

      # Waiting page may be too fast to catch so not testing.
      # On show page
      expect(page).to have_css('h1', text: title_fixture)

      within('table#contributors-table') do
        within('tbody tr:nth-child(1)') do
          expect(page).to have_css('td:nth-child(1)',
                                   text: "#{required_person.first_name} #{required_person.last_name}")
          expect(page).to have_css('td:nth-child(2)', text: '0001-0002-0003-0004')
          expect(page).to have_css('td:nth-child(3)', text: 'Author')
        end
        within('tbody tr:nth-child(2)') do
          expect(page).to have_css('td:nth-child(1)', text: required_organization.organization_name)
          expect(page).to have_css('td:nth-child(3)', text: 'Funder')
        end
        within('tbody tr:nth-child(4)') do
          expect(page).to have_css('td:nth-child(1)', text: 'Jane Stanford')
        end
      end
    end
  end
end
