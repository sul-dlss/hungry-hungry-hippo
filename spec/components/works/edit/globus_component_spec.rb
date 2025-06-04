# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Edit::GlobusComponent, type: :component do
  let(:content_obj) { create(:content) }
  let(:destination_path) { 'jstanford/new' }

  it 'renders globus links' do
    render_inline(described_class.new(content_obj:, globus_destination_path: destination_path))

    expect(page).to have_link('Your computer', href: 'https://app.globus.org/file-manager?destination_id=fake7087-d32d-4588-8517-b2d0d32d53b8&destination_path=/uploads/jstanford/new')
    expect(page).to have_link('Google Drive', href: 'https://app.globus.org/file-manager?destination_id=fake7087-d32d-4588-8517-b2d0d32d53b8&destination_path=/uploads/jstanford/new&origin_id=e1c8858b-d5aa-4e36-b97e-95913047ec2b')
    expect(page).to have_link('Sherlock', href: 'https://app.globus.org/file-manager?destination_id=fake7087-d32d-4588-8517-b2d0d32d53b8&destination_path=/uploads/jstanford/new&origin_id=6881ae2e-db26-11e5-9772-22000b9da45e')
    expect(page).to have_link('Oak', href: 'https://app.globus.org/file-manager?destination_id=fake7087-d32d-4588-8517-b2d0d32d53b8&destination_path=/uploads/jstanford/new&origin_id=8b3a8b64-d4ab-4551-b37e-ca0092f769a7')
    expect(page).to have_link('Microsoft OneDrive', href: 'https://app.globus.org/file-manager?destination_id=fake7087-d32d-4588-8517-b2d0d32d53b8&destination_path=/uploads/jstanford/new&origin_id=9beecf19-601f-47b9-a15b-a0f34845abb1')
    expect(page).to have_button('Globus file transfer complete')
  end
end
