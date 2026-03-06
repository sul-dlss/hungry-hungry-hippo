# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Articles::Edit::LookupTableComponent, type: :component do
  let(:component) { described_class.new(article_work_form:, extracted_abstract: nil, form:) }

  let(:form) { ActionView::Helpers::FormBuilder.new(nil, ArticleForm.new, vc_test_view_context, {}) }

  let(:abstract) { abstract_fixture }

  let(:article_work_form) do
    ArticleWorkForm.new(
      title: title_fixture,
      abstract:,
      publication_date_attributes: { year: 2025, month: 8, day: 13 },
      related_works: [RelatedWorkForm.new(identifier: '10.10/doi')],
      contributors_attributes: [
        {
          first_name: 'Yufeng',
          last_name: 'Song',
          person_role: 'author',
          orcid: '0009-0001-6788-1717',
          affiliations_attributes: [
            {
              institution: 'Department of Pediatrics, University of Virginia',
              uri: 'https://ror.org/0153tk833'
            }
          ]
        },
        {
          first_name: 'Frances',
          last_name: 'Mehl',
          person_role: 'author',
          orcid: '0009-0005-9929-3185'
        },
        {
          first_name: 'Lyndsey M.',
          last_name: 'Muehling',
          person_role: 'author',
          affiliations_attributes: [
            {
              institution: 'Department of Medicine, University of Virginia',
              uri: 'https://ror.org/0153tk833'
            }
          ]
        },
        {
          first_name: 'Glenda',
          last_name: 'Canderan',
          person_role: 'author'
        }
      ]
    )
  end

  context 'when an abstract from CrossRef is available' do
    it 'renders the article details table' do
      render_inline(component)

      table = page.find('table#article-table[aria-label="Details for the article"]')
      rows = table.all('tr')
      expect(rows.length).to eq(5)
      expect(rows[0]).to have_css('th', text: 'DOI')
      expect(rows[0]).to have_css('td', text: '10.10/doi')
      expect(rows[1]).to have_css('th', text: 'Title')
      expect(rows[1]).to have_css('td', text: title_fixture)
      expect(rows[2]).to have_css('th', text: 'Authors')
      expect(rows[2])
        .to have_css('td',
                     text: 'Yufeng Song https://orcid.org/0009-0001-6788-1717 (Department of Pediatrics, ' \
                           'University of Virginia), Frances Mehl https://orcid.org/0009-0005-9929-3185, Lyndsey ' \
                           'M. Muehling (Department of Medicine, University of Virginia), Glenda Canderan')
      expect(rows[3]).to have_css('th', text: 'Publication date')
      expect(rows[3]).to have_css('td', text: 'August 13, 2025')
      expect(rows[4]).to have_css('th', text: 'Abstract')
      expect(rows[4]).to have_css('td', text: abstract_fixture)
    end
  end

  context 'when an abstract from CrossRef is not available and abstract extraction is not enabled' do
    let(:abstract) { nil }

    before do
      allow(Settings.extract_abstracts).to receive(:enabled).and_return(false)
    end

    it 'renders the article details table with an empty abstract' do
      render_inline(component)

      table = page.find('table#article-table[aria-label="Details for the article"]')
      rows = table.all('tr')

      expect(rows[4]).to have_css('th', text: 'Abstract')
      expect(rows[4]).to have_css('td', exact_text: '')
    end
  end

  context 'when an abstract from CrossRef is not available and abstract extraction is enabled' do
    let(:abstract) { nil }

    it 'renders the article details table with extracted abstract turbo frame' do
      render_inline(component)

      table = page.find('table#article-table[aria-label="Details for the article"]')
      rows = table.all('tr')

      expect(rows[4]).to have_css('th', text: 'Abstract')
      expect(rows[4]).to have_css('turbo-frame#extract-abstract[src="/abstracts/new?doi=10.10%2Fdoi"]')
    end
  end
end
