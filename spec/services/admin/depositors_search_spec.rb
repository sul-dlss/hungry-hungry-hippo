# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::DepositorsSearch do
  subject(:selected_works) { described_class.call(form:) }

  let(:druid_list) { works.pluck(:druid) }
  let(:form) { instance_double(Admin::DepositorsSearchForm, druid_list:) }
  let(:works) { create_list(:work, 3, :with_druid) }

  describe '.call' do
    it 'returns a list of hashes with work druids and depositor IDs' do
      works.each do |work|
        expect(selected_works).to include({ id: work.druid, values: [work.druid, work.user.sunetid] })
      end
    end
  end
end
