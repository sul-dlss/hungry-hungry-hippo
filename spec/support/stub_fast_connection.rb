# frozen_string_literal: true

RSpec.shared_context('with FAST connection') do
  before do
    stub_request(:get, "#{Settings.autocomplete_lookup.url}?query=#{query}#{other_params}")
      .with(headers: lookup_headers)
      .to_return(status: lookup_status, body: lookup_response_body, headers: {})
  end

  let(:lookup_status) { 200 }
  let(:lookup_headers) do
    {
      'Accept' => 'application/json',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'User-Agent' => 'Stanford Self-Deposit (Hungry Hungry Hippo)'
    }
  end
  let(:other_params) do
    '&rows=20&sort=usage+desc&queryIndex=suggestall&queryReturn=idroot,suggestall,tag&suggest=autoSubject'
  end
  let(:lookup_response_body) do
    {
      response: {
        docs: [
          {
            idroot: [
              'fst01144120'
            ],
            tag: 150,
            suggestall: [
              'Tea'
            ]
          },
          {
            idroot: [
              'fst01762507'
            ],
            tag: 150,
            suggestall: [
              'Tea Party movement'
            ]
          },
          {
            idroot: [
              'fst01144165'
            ],
            tag: 150,
            suggestall: [
              'Tea making paraphernalia'
            ]
          },
          {
            idroot: [
              'fst01144178'
            ],
            tag: 150,
            suggestall: [
              'Tea tax (American colonies)'
            ]
          },
          {
            idroot: [
              'fst01144179'
            ],
            tag: 150,
            suggestall: [
              'Tea trade'
            ]
          },
          {
            idroot: [
              'fst01144131'
            ],
            tag: 150,
            suggestall: [
              'Tea--Health aspects'
            ]
          },
          {
            idroot: [
              'fst01144144'
            ],
            tag: 150,
            suggestall: [
              'Tea--Social aspects'
            ]
          },
          {
            idroot: [
              'fst01144148'
            ],
            tag: 150,
            suggestall: [
              'Tea--Therapeutic use'
            ]
          },
          {
            idroot: [
              'fst01144712'
            ],
            tag: 150,
            suggestall: [
              'Tearooms'
            ]
          },
          {
            idroot: [
              'fst00537796'
            ],
            tag: 110,
            suggestall: [
              'East India Company'
            ]
          }
        ]
      }
    }.to_json
  end
end
