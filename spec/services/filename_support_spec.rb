# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FilenameSupport do
  describe '#path' do
    context 'when nil' do
      it 'returns nil' do
        expect(described_class.path(filepath: nil)).to be_nil
      end
    end

    context 'when file has no path' do
      it 'returns nil' do
        expect(described_class.path(filepath: 'file.txt')).to be_nil
      end
    end

    context 'when file has a path' do
      it 'returns the path' do
        expect(described_class.path(filepath: 'path/to/file.txt')).to eq('path/to')
      end
    end
  end

  describe '#path_parts' do
    context 'when nil' do
      it 'returns empty array' do
        expect(described_class.path_parts(filepath: nil)).to eq []
      end
    end

    context 'when file has no path' do
      it 'returns empty array' do
        expect(described_class.path_parts(filepath: 'file.txt')).to eq []
      end
    end

    context 'when file has a path' do
      it 'returns the path parts' do
        expect(described_class.path_parts(filepath: 'path/to/file.txt')).to eq %w[path to]
      end
    end
  end

  describe '#basename' do
    context 'when nil' do
      it 'returns nil' do
        expect(described_class.basename(filepath: nil)).to be_nil
      end
    end

    context 'when file has no path' do
      it 'returns nil' do
        expect(described_class.basename(filepath: 'file.txt')).to eq 'file'
      end
    end

    context 'when file has a path' do
      it 'returns the path' do
        expect(described_class.basename(filepath: 'path/to/file.txt')).to eq 'file'
      end
    end
  end

  describe '#extname' do
    context 'when nil' do
      it 'returns nil' do
        expect(described_class.extname(filepath: nil)).to be_nil
      end
    end

    context 'when file has no path' do
      it 'returns nil' do
        expect(described_class.extname(filepath: 'file.txt')).to eq 'txt'
      end
    end

    context 'when file has a path' do
      it 'returns the path' do
        expect(described_class.extname(filepath: 'path/to/file.txt')).to eq 'txt'
      end
    end
  end

  describe '#filename' do
    context 'when nil' do
      it 'returns nil' do
        expect(described_class.filename(filepath: nil)).to be_nil
      end
    end

    context 'when file has no path' do
      it 'returns filename' do
        expect(described_class.filename(filepath: 'file.txt')).to eq 'file.txt'
      end
    end

    context 'when file has a path' do
      it 'returns the path' do
        expect(described_class.filename(filepath: 'path/to/file.txt')).to eq 'file.txt'
      end
    end
  end
end
