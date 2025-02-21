# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FilePath do
  describe '#path_parts' do
    context 'when nil' do
      it 'returns empty array' do
        expect(described_class.parts(nil)).to eq []
      end
    end

    context 'when file has no path' do
      it 'returns empty array' do
        expect(described_class.parts('file.txt')).to eq []
      end
    end

    context 'when file has a path' do
      it 'returns the path parts' do
        expect(described_class.parts('path/to/file.txt')).to eq %w[path to]
      end
    end
  end

  describe '#basename' do
    context 'when nil' do
      it 'returns nil' do
        expect(described_class.basename(nil)).to be_nil
      end
    end

    context 'when file has no path' do
      it 'returns nil' do
        expect(described_class.basename('file.txt')).to eq 'file'
      end
    end

    context 'when file has a path' do
      it 'returns the path' do
        expect(described_class.basename('path/to/file.txt')).to eq 'file'
      end
    end
  end

  describe '#extname' do
    context 'when nil' do
      it 'returns nil' do
        expect(described_class.extname(nil)).to be_nil
      end
    end

    context 'when file has no path' do
      it 'returns nil' do
        expect(described_class.extname('file.txt')).to eq 'txt'
      end
    end

    context 'when file has a path' do
      it 'returns the path' do
        expect(described_class.extname('path/to/file.txt')).to eq 'txt'
      end
    end
  end

  describe '#filename' do
    context 'when nil' do
      it 'returns nil' do
        expect(described_class.filename(nil)).to be_nil
      end
    end

    context 'when file has no path' do
      it 'returns filename' do
        expect(described_class.filename('file.txt')).to eq 'file.txt'
      end
    end

    context 'when file has a path' do
      it 'returns the path' do
        expect(described_class.filename('path/to/file.txt')).to eq 'file.txt'
      end
    end
  end
end
