# frozen_string_literal: true

def collection_druid_fixture
  'druid:cc234dd5678'
end

def collection_bare_druid_fixture
  'cc234dd5678'
end

def collection_title_fixture
  'My Collection'
end

def collection_source_id_fixture
  'hydrus:collection-1'
end

def collection_description_fixture
  'My first collection for testing'
end

def collection_manager_fixture
  [
    {
      'sunetid' => 'stepking',
      'name' => 'Stephen King'
    }
  ]
end

def collection_depositor_fixture
  [
    {
      'sunetid' => 'joehill',
      'name' => 'Joseph Hill'
    }
  ]
end

def collection_reviewer_fixture
  [
    {
      'sunetid' => 'rbachman',
      'name' => 'Richard Bachman'
    }
  ]
end

def release_option_fixture
  'depositor_selects'
end

def release_duration_fixture
  'one_year'
end

def access_fixture
  'depositor_selects'
end

def doi_option_fixture
  'yes'
end

def collection_license_fixture
  'https://creativecommons.org/licenses/by/4.0/legalcode'
end

def works_contact_email_fixture
  'collection.manager@stanford.example.edu'
end

def related_links_fixture
  [
    {
      'text' => 'Stanford University',
      'url' => 'https://www.stanford.edu/'
    },
    {
      'text' => 'Hewatt Transect',
      'url' => 'https://sul-purl-stage.stanford.edu/qx938nv4212'
    }
  ]
end
