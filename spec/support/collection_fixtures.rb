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
      'sunetid' => 'stepking'
    }
  ]
end

def collection_depositor_fixture
  [
    {
      'sunetid' => 'joehill'
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
