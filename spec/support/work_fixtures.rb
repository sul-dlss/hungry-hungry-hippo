# frozen_string_literal: true

def title_fixture
  'My title'
end

def source_id_fixture
  'h3:object-1'
end

def druid_fixture
  'druid:bc123df4567'
end

def lock_fixture
  'abc123'
end

def abstract_fixture
  'This is what my work is about.'
end

def citation_fixture
  'Dr. Pepper et al., 2024. https://purl.stanford.edu/bc123df4567'
end

def related_links_fixture
  [
    {
      'text' => 'Stanford University',
      'url' => 'https://www.stanford.edu/'
    }
  ]
end

def related_works_fixture
  [
    {
      'relationship' => 'part of',
      'identifier' => nil,
      'citation' => 'Here is a valid citation.',
      'use_citation' => true
    },
    {
      'relationship' => 'has part',
      'identifier' => 'doi:10.7710/2162-3309.1059',
      'citation' => nil,
      'use_citation' => false
    }
  ]
end

def contact_emails_fixture
  [
    {
      'email' => 'aperson@example.com'
    },
    {
      'email' => 'anotherperson@example.com'
    }
  ]
end

def keywords_fixture
  [
    {
      'text' => 'Biology',
      'uri' => 'http://id.worldcat.org/fast/832383/',
      'cocina_type' => 'topic'
    },
    {
      'text' => 'MyBespokeKeyword',
      'uri' => nil,
      'cocina_type' => nil
    }
  ]
end

def license_fixture
  'https://creativecommons.org/licenses/by/4.0/legalcode'
end

def license_label_fixture
  'CC-BY-4.0'
end

def filename_fixture
  'my_file.txt'
end

def file_label_fixture
  'My file'
end

def file_size_fixture
  204_615
end

def mime_type_fixture
  'text/plain'
end

def md5_fixture
  '46b763ec34319caa5c1ed090aca46ef2'
end

def sha1_fixture
  'd4f94915b4c6a3f652ee7de8aae9bcf2c37d93ea'
end

def file_external_identifier_fixture
  'https://cocina.sul.stanford.edu/file/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74/my_file.text'
end

def fileset_external_identifier_fixture
  'https://cocina.sul.stanford.edu/fileSet/kb185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de74'
end

def publication_date_fixture
  {
    'year' => 2024,
    'month' => 6,
    'day' => 10
  }
end

def work_type_fixture
  'Image'
end

def work_subtypes_fixture
  %w[CAD Map]
end

def authors_fixture
  [
    {
      'role_type' => 'person',
      'person_role' => 'author',
      'organization_role' => nil,
      'first_name' => 'Jane',
      'last_name' => 'Stanford',
      'with_orcid' => true,
      'orcid' => '0001-0002-0003-0004',
      'organization_name' => nil
    },
    {
      'role_type' => 'organization',
      'person_role' => nil,
      'organization_role' => 'host_institution',
      'with_orcid' => false,
      'orcid' => nil,
      'first_name' => nil,
      'last_name' => nil,
      'organization_name' => 'Stanford University Libraries'
    }
  ]
end

def person_contributor_fixture
  {
    surname: 'Stanford',
    forename: 'Jane',
    role: 'author',
    primary: true,
    orcid: '0001-0002-0003-0004'
  }
end

def organization_contributor_fixture
  {
    role: 'host_institution',
    org_name: 'Stanford University Libraries',
    primary: false
  }
end
