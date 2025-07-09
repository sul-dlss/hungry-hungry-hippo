# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserVersionChangeService do
  include WorkMappingFixtures

  subject(:changed?) { described_class.call(original_cocina_object:, new_cocina_object:) }

  let(:original_cocina_object) { dro_with_structural_fixture }

  context 'when structural is identical' do
    let(:new_cocina_object) { dro_with_structural_fixture }

    it 'returns false' do
      expect(changed?).to be false
    end
  end

  context 'when file is added' do
    let(:new_cocina_object) do
      dro_fixture.new(structural: {
                        contains: [
                          {
                            type: 'https://cocina.sul.stanford.edu/models/resources/file',
                            externalIdentifier: fileset_external_identifier_fixture,
                            label: file_label_fixture,
                            version: 2,
                            structural: {
                              contains: [
                                {
                                  type: 'https://cocina.sul.stanford.edu/models/file',
                                  externalIdentifier: file_external_identifier_fixture,
                                  label: file_label_fixture,
                                  filename: filename_fixture,
                                  size: file_size_fixture,
                                  version: 2,
                                  hasMimeType: mime_type_fixture,
                                  sdrGeneratedText: false,
                                  correctedForAccessibility: false,
                                  hasMessageDigests: [
                                    {
                                      type: 'md5',
                                      digest: md5_fixture
                                    },
                                    {
                                      type: 'sha1',
                                      digest: sha1_fixture
                                    }
                                  ],
                                  access: {
                                    view: 'dark',
                                    download: 'none',
                                    controlledDigitalLending: false
                                  },
                                  administrative: {
                                    publish: true,
                                    sdrPreserve: true,
                                    shelve: true
                                  }
                                }
                              ]
                            }
                          },
                          {
                            type: 'https://cocina.sul.stanford.edu/models/resources/file',
                            externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/jc185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de85',
                            label: 'My new file',
                            version: 2,
                            structural: {
                              contains: [
                                {
                                  type: 'https://cocina.sul.stanford.edu/models/file',
                                  externalIdentifier: 'https://cocina.sul.stanford.edu/fileSet/jc185hz2713-f6bafda8-5719-4f77-bd76-02aaa542de85/my_new_file.txt',
                                  label: 'My new file',
                                  filename: 'my_dir/my_new_file.txt',
                                  size: file_size_fixture,
                                  version: 2,
                                  hasMimeType: mime_type_fixture,
                                  sdrGeneratedText: false,
                                  correctedForAccessibility: false,
                                  hasMessageDigests: [
                                    {
                                      type: 'md5',
                                      digest: md5_fixture
                                    },
                                    {
                                      type: 'sha1',
                                      digest: sha1_fixture
                                    }
                                  ],
                                  access: {
                                    view: 'dark',
                                    download: 'none',
                                    controlledDigitalLending: false
                                  },
                                  administrative: {
                                    publish: true,
                                    sdrPreserve: true,
                                    shelve: true
                                  }
                                }
                              ]
                            }
                          }
                        ],
                        isMemberOf: [collection_druid_fixture]
                      })
    end

    it 'returns true' do
      expect(changed?).to be true
    end
  end

  context 'when file is removed' do
    let(:new_cocina_object) do
      dro_fixture.new(structural: {
                        contains: [],
                        isMemberOf: [collection_druid_fixture]
                      })
    end

    it 'returns true' do
      expect(changed?).to be true
    end
  end

  context 'when file description is changed' do
    let(:new_cocina_object) do
      dro_fixture.new(structural: {
                        contains: [
                          {
                            type: 'https://cocina.sul.stanford.edu/models/resources/file',
                            externalIdentifier: fileset_external_identifier_fixture,
                            label: 'My changed label',
                            version: 2,
                            structural: {
                              contains: [
                                {
                                  type: 'https://cocina.sul.stanford.edu/models/file',
                                  externalIdentifier: file_external_identifier_fixture,
                                  label: 'My changed label',
                                  filename: filename_fixture,
                                  size: file_size_fixture,
                                  version: 2,
                                  hasMimeType: mime_type_fixture,
                                  sdrGeneratedText: false,
                                  correctedForAccessibility: false,
                                  hasMessageDigests: [
                                    {
                                      type: 'md5',
                                      digest: md5_fixture
                                    },
                                    {
                                      type: 'sha1',
                                      digest: sha1_fixture
                                    }
                                  ],
                                  access: {
                                    view: 'dark',
                                    download: 'none',
                                    controlledDigitalLending: false
                                  },
                                  administrative: {
                                    publish: true,
                                    sdrPreserve: true,
                                    shelve: true
                                  }
                                }
                              ]
                            }
                          }
                        ],
                        isMemberOf: [collection_druid_fixture]
                      })
    end

    it 'returns false' do
      expect(changed?).to be false
    end
  end

  context 'when file is hidden' do
    let(:new_cocina_object) { dro_with_structural_fixture(hide: true) }

    it 'returns true' do
      expect(changed?).to be true
    end
  end

  context 'when access is changed' do
    let(:new_cocina_object) do
      dro_fixture.new(structural: {
                        contains: [
                          {
                            type: 'https://cocina.sul.stanford.edu/models/resources/file',
                            externalIdentifier: fileset_external_identifier_fixture,
                            label: file_label_fixture,
                            version: 2,
                            structural: {
                              contains: [
                                {
                                  type: 'https://cocina.sul.stanford.edu/models/file',
                                  externalIdentifier: file_external_identifier_fixture,
                                  label: file_label_fixture,
                                  filename: filename_fixture,
                                  size: file_size_fixture,
                                  version: 2,
                                  hasMimeType: mime_type_fixture,
                                  sdrGeneratedText: false,
                                  correctedForAccessibility: false,
                                  hasMessageDigests: [
                                    {
                                      type: 'md5',
                                      digest: md5_fixture
                                    },
                                    {
                                      type: 'sha1',
                                      digest: sha1_fixture
                                    }
                                  ],
                                  access: {
                                    view: 'world',
                                    download: 'world',
                                    controlledDigitalLending: false
                                  },
                                  administrative: {
                                    publish: true,
                                    sdrPreserve: true,
                                    shelve: true
                                  }
                                }
                              ]
                            }
                          }
                        ],
                        isMemberOf: [collection_druid_fixture]
                      })
    end

    it 'returns false' do
      expect(changed?).to be false
    end
  end

  context 'when collection has changed' do
    let(:new_cocina_object) do
      dro_with_structural_fixture.new(structural: {
                                        contains: dro_with_structural_fixture.structural.contains,
                                        isMemberOf: ['druid:bb123cc4567']
                                      })
    end

    it 'returns false' do
      expect(changed?).to be false
    end
  end

  context 'when original cocina object is nil' do
    let(:original_cocina_object) { nil }
    let(:new_cocina_object) { dro_with_structural_fixture }

    it 'returns true' do
      expect(changed?).to be true
    end
  end
end
