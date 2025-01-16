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

  context 'when not embargoed' do
    let(:work_form) { WorkForm.new(release_option: 'immediate') }

    it 'maps to cocina' do
      expect(access).not_to have_key(:embargo)
    end
  end

  context 'when embargoed' do
    let(:work_form) { WorkForm.new(release_option: 'delay', release_date: Date.new(2025, 1, 11)) }

    it 'maps to cocina' do
      expect(access).to match(
        view: 'citation-only',
        download: 'none',
        useAndReproductionStatement: String,
        embargo: {
          view: 'world',
          download: 'world',
          releaseDate: '2025-01-11T00:00:00+00:00'
        }
      )
    end
  end
end
