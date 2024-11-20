# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ModelSync::Work do
  let(:druid) { druid_fixture }
  let(:work) { create(:work, druid:) }
  let(:cocina_object) { build(:dro_with_metadata, id: druid, title: title_fixture) }

  it 'updates the work' do
    # TODO: Test collections
    expect { described_class.call(work: work, cocina_object: cocina_object) }
      .to change { work.reload.title }.to(title_fixture)
  end
end
