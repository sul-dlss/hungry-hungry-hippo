# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cocina::WorkIdentificationMapper do
  subject(:identification) { described_class.call(work_form:, source_id:) }

  let(:source_id) { source_id_fixture }
  let(:druid) { druid_fixture }
  let(:doi) { doi_fixture }

  context 'when not persisted' do
    let(:work_form) { WorkForm.new }

    it 'maps to cocina' do
      expect(identification).to match(
        sourceId: source_id
      )
    end
  end

  context 'when persisted' do
    context 'when doi_option is assigned' do
      let(:work_form) { WorkForm.new(doi_option: 'assigned', druid:) }

      it 'maps to cocina' do
        expect(identification).to match(
          sourceId: source_id,
          doi:
        )
      end
    end

    context 'when doi_option is yes' do
      let(:work_form) { WorkForm.new(doi_option: 'yes', druid:) }

      it 'maps to cocina' do
        expect(identification).to match(
          sourceId: source_id,
          doi:
        )
      end
    end

    context 'when doi_option is no' do
      let(:work_form) { WorkForm.new(doi_option: 'no', druid:) }

      it 'maps to cocina' do
        expect(identification).to match(
          sourceId: source_id
        )
      end
    end
  end
end
