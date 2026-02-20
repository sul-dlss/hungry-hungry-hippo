# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Articles::Edit::LookupTableComponent, type: :component do
  let(:component) { described_class.new(article_work_form: article_form) }

  let(:article_form) do
    ArticleWorkForm.new(
      title: title_fixture,
      abstract: abstract_fixture,
      publication_date_attributes: { year: 2025, month: 8, day: 13 },
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

  it 'renders the article details table' do
    render_inline(component)

    table = page.find('table#article-table[aria-label="Details for the article"]')
    rows = table.all('tr')
    expect(rows.length).to eq(4)
    expect(rows[0]).to have_css('th', text: 'Title')
    expect(rows[0]).to have_css('td', text: title_fixture)
    expect(rows[1]).to have_css('th', text: 'Authors')
    expect(rows[1])
      .to have_css('td', text: 'Yufeng Song https://orcid.org/0009-0001-6788-1717 (Department of Pediatrics, ' \
                               'University of Virginia), Frances Mehl https://orcid.org/0009-0005-9929-3185, Lyndsey ' \
                               'M. Muehling (Department of Medicine, University of Virginia), Glenda Canderan')
    expect(rows[2]).to have_css('th', text: 'Publication date')
    expect(rows[2]).to have_css('td', text: 'August 13, 2025')
    expect(rows[3]).to have_css('th', text: 'Abstract')
    expect(rows[3]).to have_css('td', text: abstract_fixture)
  end
end
