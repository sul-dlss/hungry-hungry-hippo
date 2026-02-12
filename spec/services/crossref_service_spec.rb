# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CrossrefService, :vcr do
  subject(:attrs) { described_class.call(doi:) }

  context 'when the DOI exists' do
    let(:doi) { '10.1128/mbio.01735-25' }

    it 'maps to form attributes' do
      expect(attrs)
        .to match(
          {
            title: 'ACE-2-like enzymatic activity in COVID-19 convalescents with persistent pulmonary symptoms associated with immunoglobulin', # rubocop:disable Layout/LineLength
            abstract: "ABSTRACT\n\nMany difficult-to-understand clinical features characterize COVID-19 and post-acute sequelae of COVID-19 (PASC or long COVID [LC]). These can include blood pressure instability, hyperinflammation, coagulopathies, and neuropsychiatric complaints. The pathogenesis of these features remains unclear. The SARS-CoV-2 Spike protein receptor-binding domain (RBD) binds angiotensin converting enzyme 2 (ACE2) on the surface of host cells to initiate infection. We hypothesized that some people convalescing from COVID-19 may produce anti-RBD antibodies that resemble ACE2 sufficiently to have ACE2-like catalytic activity, that is, they are ACE2-like proteolytic abzymes that may help mediate the pathogenesis of COVID-19 and LC. In previous work, we showed that some people with acute COVID-19 had immunoglobulin-associated ACE2-like proteolytic activity, suggesting that some people with COVID-19 indeed produced ACE2-like abzymes. However, it remained unknown whether ACE2-like abzymes were seen only in acute COVID-19 or whether ACE2-like abzymes could also be identified in people convalescing from COVID-19. Here, we show that some people convalescing from COVID-19 attending a clinic for people with persistent pulmonary symptoms also have ACE2-like abzymes and that the presence of ACE2-like catalytic activity correlates with alterations in blood pressure in an exercise test.\n\nIMPORTANCE\n\nPatients who have had COVID-19 can sometimes have troublesome symptoms, termed post-acute sequelae of COVID-19 (PASC) or long COVID (LC), which can include problems with blood pressure regulation, gastrointestinal problems, inflammation, blood clotting, and symptoms like “brain fog.” The proximate causes for these problems are not known, which makes these problems difficult to treat definitively. We previously found that some acute COVID-19 patients make antibodies against SARS-CoV-2, the virus that causes COVID-19, that act like an enzyme, angiotensin converting enzyme 2 (ACE2). ACE2 normally helps regulate blood pressure and serves as the receptor for SARS-CoV-2 in the body. We show that patients convalescing from COVID-19 also make antibodies that act like ACE2 and that the presence of those antibodies correlates with problems in blood pressure regulation. The findings provide a new opening to potentially understanding the causes of LC, and so provide direction for the development of new treatments.", # rubocop:disable Layout/LineLength
            related_works_attributes: [
              {
                relationship: 'is version of record',
                identifier: 'https://doi.org/10.1128/mbio.01735-25'
              }
            ],
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
                orcid: '0009-0005-9929-3185',
                affiliations_attributes: [
                  {
                    institution: 'Department of Pediatrics, University of Virginia',
                    uri: 'https://ror.org/0153tk833'
                  }
                ]
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
                person_role: 'author',
                affiliations_attributes: [
                  {
                    institution: 'Department of Medicine, University of Virginia',
                    uri: 'https://ror.org/0153tk833'
                  }
                ]
              },
              {
                first_name: 'Kyle',
                last_name: 'Enfield',
                person_role: 'author',
                affiliations_attributes: [
                  {
                    institution: 'Department of Medicine, University of Virginia',
                    uri: 'https://ror.org/0153tk833'
                  }
                ]
              },
              {
                first_name: 'Jie',
                last_name: 'Sun',
                person_role: 'author',
                affiliations_attributes: [
                  {
                    institution: 'Beirne B. Carter Center for Immunology Research, University of Virginia',
                    uri: 'https://ror.org/0153tk833'
                  },
                  {
                    institution: 'Division of Infectious Disease and International Health, Department of Medicine, University of Virginia', # rubocop:disable Layout/LineLength
                    uri: 'https://ror.org/0153tk833'
                  }
                ]
              },
              {
                first_name: 'Michael T.',
                last_name: 'Yin',
                person_role: 'author',
                affiliations_attributes: [
                  {
                    institution: 'Columbia University Vagelos College of Physicians and Surgeons',
                    uri: 'https://ror.org/0530xmm89'
                  }
                ]
              },
              {
                first_name: 'Sarah J.',
                last_name: 'Ratcliffe',
                person_role: 'author',
                affiliations_attributes: [
                  {
                    institution: 'Division of Biostatistics, Department of Public Health Sciences, University of Virginia', # rubocop:disable Layout/LineLength
                    uri: 'https://ror.org/0153tk833'
                  }
                ]
              },
              {
                first_name: 'Jeffrey M.',
                last_name: 'Wilson',
                person_role: 'author',
                affiliations_attributes: [
                  {
                    institution: 'Division of Allergy and Clinical Immunology, Department of Medicine, University of Virginia', # rubocop:disable Layout/LineLength
                    uri: 'https://ror.org/0153tk833'
                  }
                ]
              },
              {
                first_name: 'Alexandra',
                last_name: 'Kadl',
                person_role: 'author',
                affiliations_attributes: [
                  {
                    institution: 'Department of Medicine, University of Virginia',
                    uri: 'https://ror.org/0153tk833'
                  },
                  {
                    institution: 'Department of Pharmacology, University of Virginia',
                    uri: 'https://ror.org/0153tk833'
                  }
                ]
              },
              {
                first_name: 'Judith A.',
                last_name: 'Woodfolk',
                person_role: 'author',
                affiliations_attributes: [
                  {
                    institution: 'Division of Allergy and Clinical Immunology, Department of Medicine, University of Virginia', # rubocop:disable Layout/LineLength
                    uri: 'https://ror.org/0153tk833'
                  },
                  {
                    institution: 'Department of Pharmacology, University of Virginia',
                    uri: 'https://ror.org/0153tk833'
                  }
                ]
              },
              {
                first_name: 'Steven L.',
                last_name: 'Zeichner',
                person_role: 'author',
                orcid: '0000-0002-8922-9260',
                affiliations_attributes: [
                  {
                    institution: 'Department of Pediatrics, University of Virginia',
                    uri: 'https://ror.org/0153tk833'
                  },
                  {
                    institution: 'Department of Microbiology, Immunology, and Cancer Biology, University of Virginia',
                    uri: 'https://ror.org/0153tk833'
                  }
                ]
              }
            ]
          }
        )
    end
  end

  context 'when the DOI does not exist' do
    let(:doi) { '10.1234/nonexistent' }

    it 'raises NotFound' do
      expect { attrs }.to raise_error(CrossrefService::NotFound, "DOI '10.1234/nonexistent' not found in Crossref")
    end
  end

  context 'when the Crossref API request fails' do
    let(:doi) { '10.1128/mbio.01735-25' }

    before do
      stub_request(:get, "https://api.crossref.org/works/doi/#{doi}")
        .to_return(status: 500, body: 'Internal Server Error')
    end

    it 'raises Error' do
      expect { attrs }.to raise_error(CrossrefService::Error, 'DOI lookup failed: 500 Internal Server Error')
    end
  end
end
