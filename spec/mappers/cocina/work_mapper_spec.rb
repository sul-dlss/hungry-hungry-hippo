# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cocina::WorkMapper, type: :mapping do
  subject(:cocina_object) { described_class.call(work_form:, content:, source_id: source_id_fixture) }

  let(:content) { content_fixture }
  let(:work_form) { work_form_fixture }

  context 'with a new work' do
    let(:work_form) { new_work_form_fixture }
    let(:content) { new_content_fixture }

    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(request_dro_with_structural_fixture)
    end
  end

  context 'with a work' do
    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(dro_with_structural_and_metadata_fixture)
    end
  end

  context 'with an immediate release work' do
    let(:work_form) do
      work_form_fixture.tap do |form|
        form.release_option = 'immediate'
      end
    end

    let(:expected_cocina_object) do
      cocina_attrs = dro_with_structural_and_metadata_fixture.to_h
      cocina_attrs[:access][:view] = 'stanford'
      cocina_attrs[:access][:download] = 'stanford'
      cocina_attrs[:access].delete(:embargo)
      file_access = cocina_attrs.dig(:structural, :contains, 0, :structural, :contains, 0, :access)
      file_access[:view] = 'stanford'
      file_access[:download] = 'stanford'

      cocina_object = Cocina::Models.build(cocina_attrs)
      Cocina::Models.with_metadata(cocina_object, work_form.lock)
    end

    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(expected_cocina_object)
    end
  end

  context 'with a work with a hidden file' do
    let(:content) { content_fixture(hide: true) }

    it 'maps to cocina' do
      expect(cocina_object).to equal_cocina(dro_with_structural_and_metadata_fixture(hide: true))
    end
  end

  context 'with a work with a new file' do
    let(:content) { new_content_fixture }

    before do
      allow(SecureRandom).to receive(:uuid).and_return('abc123', 'bcd234')
    end

    it 'maps to cocina' do
      # The external identifiers will be different.
      expect(cocina_object.structural.contains[0].externalIdentifier).to eq 'https://cocina.sul.stanford.edu/fileSet/bc123df4567-abc123'
      expect(cocina_object.structural.contains[0].structural.contains[0].externalIdentifier).to eq 'https://cocina.sul.stanford.edu/file/bc123df4567-bcd234'
    end
  end

  context 'with a work with a PDF file and a hidden file' do
    let(:content) { new_pdf_content_fixture }

    before do
      create(:content_file, label: 'My hidden file', hide: true, content:)
    end

    it 'maps to cocina' do
      expect(cocina_object.type).to eq 'https://cocina.sul.stanford.edu/models/document'
      fileset1 = cocina_object.structural.contains.find { |fileset| fileset.label == 'My file' }
      expect(fileset1.type).to eq 'https://cocina.sul.stanford.edu/models/resources/document'
      fileset2 = cocina_object.structural.contains.find { |fileset| fileset.label == 'My hidden file' }
      expect(fileset2.type).to eq 'https://cocina.sul.stanford.edu/models/resources/file'
    end
  end

  context 'with a work with a PDF file and non-hidden, not PDF file' do
    let(:content) { new_pdf_content_fixture }

    before do
      create(:content_file, label: 'My hidden file', content:)
    end

    it 'maps to cocina' do
      expect(cocina_object.type).to eq 'https://cocina.sul.stanford.edu/models/object'
      fileset1 = cocina_object.structural.contains.find { |fileset| fileset.label == 'My file' }
      expect(fileset1.type).to eq 'https://cocina.sul.stanford.edu/models/resources/file'
      fileset2 = cocina_object.structural.contains.find { |fileset| fileset.label == 'My hidden file' }
      expect(fileset2.type).to eq 'https://cocina.sul.stanford.edu/models/resources/file'
    end
  end

  context 'with a work with a PDF file hierarchical structure' do
    let(:content) { new_pdf_content_with_hierarchy_fixture }

    it 'maps to cocina' do
      expect(cocina_object.type).to eq 'https://cocina.sul.stanford.edu/models/object'
      fileset1 = cocina_object.structural.contains.find { |fileset| fileset.label == 'My file' }
      expect(fileset1.type).to eq 'https://cocina.sul.stanford.edu/models/resources/file'
      fileset2 = cocina_object.structural.contains.find { |fileset| fileset.label == 'My sub file' }
      expect(fileset2.type).to eq 'https://cocina.sul.stanford.edu/models/resources/file'
    end
  end

  context 'with a work with a hidden PDF file' do
    let(:content) { new_pdf_content_fixture(hide: true) }

    it 'maps to cocina' do
      expect(cocina_object.type).to eq 'https://cocina.sul.stanford.edu/models/object'
      expect(cocina_object.structural.contains[0].type).to eq 'https://cocina.sul.stanford.edu/models/resources/file'
    end
  end

  context 'with a work in a collection declaring a required contact email' do
    it 'includes the collection contact email in the work contact email mapping' do
      expect(cocina_object.description.access.accessContact.last.value).to eq(works_contact_email_fixture)
    end
  end
end
