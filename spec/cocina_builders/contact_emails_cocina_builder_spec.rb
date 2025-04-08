# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactEmailsCocinaBuilder do
  subject(:contact_email_params) do
    described_class.call(contact_emails:)
  end

  let(:contact_emails) do
    [
      ContactEmailForm.new(email: 'fredkroll@stanford.edu'),
      ContactEmailForm.new(email: ''),
      ContactEmailForm.new(email: 'fredkroll@stanford.edu')
    ]
  end

  it 'maps to cocina params' do
    expect(contact_email_params).to eq([
                                         {
                                           value: 'fredkroll@stanford.edu',
                                           type: 'email',
                                           displayLabel: 'Contact'
                                         }
                                       ])
  end
end
