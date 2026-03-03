# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create an article deposit using abstract extract' do
  let(:druid) { druid_fixture }
  let(:user) { create(:user) }

  let(:doi) { '10.1038/sj.clpt.6100048' }
  let(:abstract) { 'This is an abstract.' }

  before do
    create(:collection, user:, title: collection_title_fixture, druid: collection_druid_fixture, depositors: [user],
                        article_deposit_enabled: true, license_option: 'depositor_selects')

    allow(CrossrefService).to receive(:call).with(doi:)
                                            .and_return({ title: title_fixture,
                                                          contributors_attributes: [{ first_name: 'A.',
                                                                                      last_name: 'User' }],
                                                          related_works_attributes:
                                                                     [{ identifier: "https://doi.org/#{doi}" }] })
    allow(ExtractAbstractService).to receive(:call).and_return(abstract)

    # Stubbing out for Deposit Job
    allow(Sdr::Repository).to receive(:register) do |args|
      cocina_params = args[:cocina_object].to_h
      cocina_params[:externalIdentifier] = druid
      cocina_params[:description][:purl] = Sdr::Purl.from_druid(druid:)
      cocina_params[:description][:note] << { type: 'version identification', value: 'Author accepted version' }
      cocina_params[:structural] = { isMemberOf: [collection_druid_fixture] }
      cocina_params[:administrative] = { hasAdminPolicy: Settings.apo }
      cocina_object = Cocina::Models.build(cocina_params)
      @registered_cocina_object = Cocina::Models.with_metadata(cocina_object, 'abc123')
    end
    allow(Sdr::Repository).to receive(:accession)

    # Stubbing out for show page
    allow(Sdr::Repository).to receive(:find).with(druid:).and_invoke(->(_arg) { @registered_cocina_object })
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(build(:first_accessioning_version_status))
    allow(Sdr::Repository).to receive(:latest_user_version).with(druid:).and_return(1)
    allow(Sdr::Event).to receive(:list).and_return([])

    sign_in(user)
  end

  context 'when extracting succeeds' do
    it 'creates and deposits an article', :dropzone do
      visit dashboard_path

      click_link_or_button(I18n.t('collections.buttons.labels.deposit_article'))

      expect(page).to have_css('h1', text: 'Article deposit')

      fill_in 'identifier_field', with: doi
      click_link_or_button('Look up')

      click_link_or_button('Get abstract from file using AI')
      expect(page).to have_css('.invalid-feedback', text: 'Upload your article as a PDF to use this feature.')

      # Adding a file (not PDF)
      find('.dropzone').drop('spec/fixtures/files/hippo.png')
      expect(page).to have_css('table#content-table td', text: 'hippo.png')

      click_link_or_button('Get abstract from file using AI')
      expect(page).to have_css('.invalid-feedback', text: 'Upload your article as a PDF to use this feature.')

      find('.dropzone').drop('spec/fixtures/files/Strategies_for_Digital_Library_Migration.pdf')
      expect(page).to have_css('table#content-table td', text: 'Strategies_for_Digital_Library_Migration.pdf')

      click_link_or_button('Get abstract from file using AI')
      expect(page).to have_css('p', text: abstract)

      # Setting version description
      select('Author accepted version', from: 'Which version are you depositing?')

      # Setting license
      expect(page).to have_select('License', selected: 'CC-BY-4.0 Attribution International')
      select('CC-BY-NC-4.0 Attribution-NonCommercial International', from: 'License')

      # Deposit
      click_link_or_button('Deposit')

      # Waiting page may be too fast to catch so not testing.
      # On show page
      expect(page).to have_css('h1', text: title_fixture)
      expect(page).to have_css('.status', text: 'Depositing')
      expect(page).to have_css('.alert-success', text: 'Deposit successfully submitted')

      # Details
      within('#description-table') do
        expect(page).to have_css('td', text: abstract)
      end
    end
  end

  context 'when extracting fails' do
    before do
      allow(ExtractAbstractService).to receive(:call).and_return(nil)
    end

    it 'shows an error message' do
      visit dashboard_path

      click_link_or_button(I18n.t('collections.buttons.labels.deposit_article'))

      expect(page).to have_css('h1', text: 'Article deposit')

      fill_in 'identifier_field', with: doi
      click_link_or_button('Look up')

      find('.dropzone').drop('spec/fixtures/files/Strategies_for_Digital_Library_Migration.pdf')
      expect(page).to have_css('table#content-table td', text: 'Strategies_for_Digital_Library_Migration.pdf')

      click_link_or_button('Get abstract from file using AI')
      expect(page).to have_css('.invalid-feedback', text: 'We were not able to extract your abstract.')
      expect(page).to have_no_button('Get abstract from file using AI')
    end
  end

  context 'when user clears the extracted abstract' do
    it 'creates and deposits an article without the abstract', :dropzone do
      visit dashboard_path

      click_link_or_button(I18n.t('collections.buttons.labels.deposit_article'))

      expect(page).to have_css('h1', text: 'Article deposit')

      fill_in 'identifier_field', with: doi
      click_link_or_button('Look up')

      find('.dropzone').drop('spec/fixtures/files/Strategies_for_Digital_Library_Migration.pdf')
      expect(page).to have_css('table#content-table td', text: 'Strategies_for_Digital_Library_Migration.pdf')

      click_link_or_button('Get abstract from file using AI')
      expect(page).to have_css('p', text: abstract)

      click_link_or_button('Clear abstract')
      expect(page).to have_no_css('p', text: abstract)

      # Setting version description
      select('Author accepted version', from: 'Which version are you depositing?')

      # Setting license
      expect(page).to have_select('License', selected: 'CC-BY-4.0 Attribution International')
      select('CC-BY-NC-4.0 Attribution-NonCommercial International', from: 'License')

      # Deposit
      click_link_or_button('Deposit')

      # Waiting page may be too fast to catch so not testing.
      # On show page
      expect(page).to have_css('h1', text: title_fixture)
      expect(page).to have_css('.status', text: 'Depositing')
      expect(page).to have_css('.alert-success', text: 'Deposit successfully submitted')

      # Details
      within('#description-table') do
        expect(page).to have_no_css('td', text: abstract)
      end
    end
  end
end
