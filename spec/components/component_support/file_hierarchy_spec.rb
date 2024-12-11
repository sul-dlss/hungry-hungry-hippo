# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComponentSupport::FileHierarchy do
  describe '#path_parts_diff' do
    it 'returns the difference between two paths' do
      expect(described_class.path_parts_diff(last_path_parts: ['dir1'], path_parts: ['dir1'])).to eq([])
      expect(described_class.path_parts_diff(last_path_parts: ['dir1'], path_parts: ['dir2'])).to eq(['dir2'])
      expect(described_class.path_parts_diff(last_path_parts: ['dir1'],
                                             path_parts: %w[dir2
                                                            dir3])).to eq(%w[dir2 dir3])
      expect(described_class.path_parts_diff(
               last_path_parts: %w[dir1 dir2], path_parts: ['dir3']
             )).to eq(['dir3'])
      expect(described_class.path_parts_diff(last_path_parts: %w[dir1 dir2],
                                             path_parts: %w[dir1
                                                            dir3])).to eq(['dir3'])
    end
  end
end
