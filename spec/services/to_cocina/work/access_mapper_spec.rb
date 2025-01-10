# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ToCocina::Work::AccessMapper do
  subject(:access) { described_class.call(work_form:) }

  context 'when stanford access' do
    let(:work_form) { WorkForm.new(access: 'stanford') }

    it 'maps to cocina' do
      expect(access).to match(
        view: 'stanford',
        download: 'stanford',
        useAndReproductionStatement: String
      )
    end
  end

  context 'when world access' do
    let(:work_form) { WorkForm.new }

    it 'maps to cocina' do
      expect(access).to match(
        view: 'world',
        download: 'world',
        useAndReproductionStatement: String
      )
    end
  end

  context 'when license' do
    let(:work_form) { WorkForm.new(license: 'http://creativecommons.org/licenses/by/3.0/us/') }

    it 'maps to cocina' do
      expect(access).to match(
        view: 'world',
        download: 'world',
        license: 'http://creativecommons.org/licenses/by/3.0/us/',
        useAndReproductionStatement: String
      )
    end
  end

  context 'when none license' do
    let(:work_form) { WorkForm.new(license: '') }

    it 'maps to cocina' do
      expect(access).to match(
        view: 'world',
        download: 'world',
        useAndReproductionStatement: String
      )
    end
  end
end
