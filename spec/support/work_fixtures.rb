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

def related_links_fixture
  [
    {
      'text' => 'Stanford University',
      'url' => 'https://www.stanford.edu/'
    }
  ]
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
